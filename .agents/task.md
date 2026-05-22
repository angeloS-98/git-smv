# Git-SMV Miglioramenti v1.1 — Lista delle Attività

Questo documento traccia l'avanzamento dell'implementazione del piano delineato in `implementation_plan.md`.

## 1. Isolamento scope dei comandi

- `[x]` Aggiornare `git-smv` per fare il dispatch alle funzioni `cmd_<nome>()`.
- `[x]` Avvolgere in `cmd_add()` lo script `lib/commands/add.sh`.
- `[x]` Avvolgere in `cmd_bump()` lo script `lib/commands/bump.sh`.
- `[x]` Avvolgere in `cmd_diff()` lo script `lib/commands/diff.sh`.
- `[x]` Avvolgere in `cmd_help()` lo script `lib/commands/help.sh`.
- `[x]` Avvolgere in `cmd_init()` lo script `lib/commands/init.sh`.
- `[x]` Avvolgere in `cmd_lock()` lo script `lib/commands/lock.sh`.
- `[x]` Avvolgere in `cmd_remove()` lo script `lib/commands/remove.sh`.
- `[x]` Avvolgere in `cmd_status()` lo script `lib/commands/status.sh`.
- `[x]` Avvolgere in `cmd_sync()` lo script `lib/commands/sync.sh`.

## 2. Logging Strutturato

- `[x]` Aggiungere `smv_has_color()`, `smv_log_info()`, `smv_log_ok()`, `smv_log_warn()`, `smv_log_error()` in `lib/common.sh`.
- `[x]` Aggiornare i messaggi `echo`, `warn` o `die` esistenti per usare il logging strutturato dove sensato.

## 3. Test Harness

- `[x]` Aggiornare `t/test-lib.sh` con `test_must_fail`, `test_cmp`, e helper per test.
- `[ ]` Estendere i test esistenti: `t0001`, `t0002` (lock), `t0003` (sync), `t0004` (bump), `t0005` (add/remove), `t0006` (diff/status).

## 4. Nuovi Comandi

- `[x]` Implementare `lib/commands/check.sh` e i test `t0010`.
- `[x]` Implementare `lib/commands/install.sh` e i test `t0011`.
- `[x]` Implementare `lib/commands/upgrade.sh` e i test `t0012`.
- `[x]` Implementare `lib/commands/list.sh` e i test `t0013`.
- `[x]` Implementare `lib/commands/purge.sh` e i test `t0014`.
- `[x]` Aggiornare l'USAGE di `git-smv` con i nuovi comandi.

## 5. Build e Makefile

- `[ ]` Verificare il Makefile (il glob copre già i comandi).
- `[ ]` Risolvere eventuali errori emersi con `make lint` (`shellcheck`).
- `[ ]` Eseguire la suite di test completa `make test` per verificare che non ci siano regressioni.
