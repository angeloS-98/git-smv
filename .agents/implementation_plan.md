# git-smv — Piano di miglioramento v1.1

Questo piano copre le quattro aree di miglioramento identificate nella sessione di analisi:
isolamento dello scope dei comandi, logging strutturato, potenziamento del test harness,
e implementazione di cinque nuovi sottocomandi (`check`, `install`, `upgrade`, `list`, `purge`).

---

## Decisioni di Design Concordate

> [!NOTE]
> Le seguenti scelte sono state concordate tramite l'intervista interattiva:
> - **Isolamento scope**: Riscrivere ogni comando racchiudendo la logica in una funzione dedicata `cmd_<nome_comando>()` nell'entrypoint per evitare collisioni di variabili.
> - **Colorazione Log**: Rispetta la configurazione colore nativa di Git (`git config --get-colorbool color.ui`) combinata con `$NO_COLOR`.
> - **`git smv check`**: Verifica lo sfasamento tra `.gitsmv` (`resolved`) e il gitlink registrato nell'indice di Git. Supporta un flag opzionale `--worktree` per controllare anche lo stato locale.
> - **`git smv install` senza lockfile**: Se `.gitsmv` non esiste, viene prima inizializzato automaticamente eseguendo `git smv init --from-gitmodules` prima di procedere.
> - **`git smv upgrade`**: Esegue `git fetch` sul remote del sottomodulo (default `origin`, personalizzabile tramite `--remote`). Richiede il sottomodulo esplicito o il flag `--all`.

---

## Open Questions

> [!IMPORTANT]
> **Compatibilità POSIX**: Tutti i nuovi script devono girare su `/bin/sh` senza bashismi
> (no array, no `local`, no `[[`, no process substitution `<()`).
> Il lint con `shellcheck --shell=sh` deve passare senza errori.

---

## Proposed Changes

### Componente 1 — Isolamento scope dei comandi

Il dispatcher in `git-smv` usa `. "$command_path"` (source) nel processo principale. Il fix è incapsulare ciascun comando in una funzione dedicata all'interno dello script e richiamarla dall'entrypoint.

#### [MODIFY] [git-smv](file:///home/angelo/agents/cursor/git-smv/git-smv)

Il dispatch viene modificato da:
```sh
. "$command_path"
```
a:
```sh
. "$command_path"
cmd_${cmd} "$@"
```

---

#### [MODIFY] Ogni script in [lib/commands/](file:///home/angelo/agents/cursor/git-smv/lib/commands)

Ogni `*.sh` viene modificato avvolgendo l'intera esecuzione in una funzione `cmd_<nome_comando>()`:

```sh
# esempio: lib/commands/lock.sh
cmd_lock() {
    require_work_tree
    cd_to_toplevel
    smv_ensure_gitsmv_file
    require_gitsmv_file
    # ... logica esistente ...
}
```

File coinvolti:
- `add.sh`, `bump.sh`, `diff.sh`, `help.sh`, `init.sh`, `lock.sh`, `remove.sh`, `status.sh`, `sync.sh`

---

### Componente 2 — Logging strutturato con colori opzionali

#### [MODIFY] [lib/common.sh](file:///home/angelo/agents/cursor/git-smv/lib/common.sh)

Aggiunta di funzioni di logging con colori ANSI che rispettano la configurazione di Git e `$NO_COLOR`:

```sh
smv_has_color() {
	if test -n "$NO_COLOR"; then
		return 1
	fi
	# Controlla color.ui di Git
	git config --get-colorbool color.ui 2>/dev/null
}

smv_log_info() {
	printf '%s\n' "$*"
}

smv_log_ok() {
	if smv_has_color; then
		printf '\033[32mok: %s\033[0m\n' "$*"
	else
		printf 'ok: %s\n' "$*"
	fi
}

smv_log_warn() {
	if smv_has_color; then
		printf '\033[33mwarning: %s\033[0m\n' "$*" >&2
	else
		printf 'warning: %s\n' "$*" >&2
	fi
}

smv_log_error() {
	if smv_has_color; then
		printf '\033[31merror: %s\033[0m\n' "$*" >&2
	else
		printf 'error: %s\n' "$*" >&2
	fi
}
```

---

### Componente 3 — Potenziamento del test harness

#### [MODIFY] [t/test-lib.sh](file:///home/angelo/agents/cursor/git-smv/t/test-lib.sh)

Aggiunte rispetto all'implementazione attuale:

| Funzione | Descrizione |
|---|---|
| `test_must_fail` | Asserisce che il comando fallisce (exit != 0) |
| `test_cmp` | Confronta due file con diff leggibile |
| `test_path_is_file` | Asserisce l'esistenza di un file |
| `test_path_is_dir` | Asserisce l'esistenza di una directory |
| `test_output_contains` | Cerca una stringa nell'output del comando |
| `test_create_submodule_upstream` | Helper per creare repo upstream fake |

---

#### [NEW] Test per ogni sottocomando esistente

| File | Comandi coperti |
|---|---|
| `t/t0001-smv-init.sh` | gia presente — sara esteso |
| `t/t0002-smv-lock.sh` | `lock --all`, `lock <path>` |
| `t/t0003-smv-sync.sh` | `sync --all`, `sync --dry-run`, `sync --force` |
| `t/t0004-smv-bump.sh` | `bump --ref`, `bump --to-latest`, `bump --version` |
| `t/t0005-smv-add-remove.sh` | `add`, `remove`, `remove --keep-dir` |
| `t/t0006-smv-diff-status.sh` | `diff`, `diff --porcelain`, `status -v` |

---

#### [NEW] Test per i nuovi comandi

| File | Comandi coperti |
|---|---|
| `t/t0010-smv-check.sh` | `check` (CI gate) |
| `t/t0011-smv-install.sh` | `install` |
| `t/t0012-smv-upgrade.sh` | `upgrade` |
| `t/t0013-smv-list.sh` | `list` |
| `t/t0014-smv-purge.sh` | `purge` |

---

### Componente 4 — Nuovi sottocomandi

#### [NEW] [lib/commands/check.sh](file:///home/angelo/agents/cursor/git-smv/lib/commands/check.sh)

**Scopo**: Verifica che ogni SHA `resolved` in `.gitsmv` corrisponda all'attuale gitlink registrato nell'indice.
Supporta `--worktree` per verificare lo stato locale del sottomodulo.

```
git smv check [--all] [<path>...] [--porcelain] [-q] [--worktree]
```

---

#### [NEW] [lib/commands/install.sh](file:///home/angelo/agents/cursor/git-smv/lib/commands/install.sh)

**Scopo**: Onboarding automatico. Se `.gitsmv` non esiste, esegue `git smv init --from-gitmodules` prima di procedere con l'installazione e la sincronizzazione.

```
git smv install [--no-sync]
```

---

#### [NEW] [lib/commands/upgrade.sh](file:///home/angelo/agents/cursor/git-smv/lib/commands/upgrade.sh)

**Scopo**: Esegue `git fetch` sul remote del sottomodulo (default `origin` o specificato tramite `--remote`) e aggiorna `resolved` all'ultimo commit del ref configurato.

```
git smv upgrade [--all] [<path>...] [--remote <name>] [--dry-run]
```

---

#### [NEW] [lib/commands/list.sh](file:///home/angelo/agents/cursor/git-smv/lib/commands/list.sh)

**Scopo**: Vista tabellare arricchita di tutti i sottomoduli.

```
git smv list [--porcelain] [--check-remote]
```

---

#### [NEW] [lib/commands/purge.sh](file:///home/angelo/agents/cursor/git-smv/lib/commands/purge.sh)

**Scopo**: Rimuove temporaneamente le directory locali dei sottomoduli senza toccare la configurazione e i file di lock.

```
git smv purge [--all] [<path>...] [--force]
```

---

## Verification Plan

### Automated Tests

```bash
# Lint POSIX compliance su tutti gli script
make lint

# Suite di test completa con TAP reporter
make test
# Test selettivi per i nuovi comandi
cd t && sh t0010-smv-check.sh
cd t && sh t0011-smv-install.sh
cd t && sh t0012-smv-upgrade.sh
cd t && sh t0013-smv-list.sh
cd t && sh t0014-smv-purge.sh
```

### Manual Verification

1. Clonare una repo con sottomoduli e verificare il flusso completo:
   `init -> lock -> check -> install -> upgrade -> list -> purge -> install`.
2. Verificare che `git smv check` ritorni exit code 1 in una pipeline CI
   quando `.gitsmv` e fuori sync con l'indice.
3. Verificare output colori su terminale e assenza di ANSI escape in pipe
   (`git smv list | cat` deve essere pulito).
