# Critique — Inception (as of 2026-07-14)

## Overall

Solid, clean implementation of the subject's core requirements. Three
custom-built Debian images, no `network: host`, only NGINX exposed,
secrets mounted via Docker secrets instead of baked into images, named
volumes with `driver_opts` bind to `/home/<login>/data/`. The docs
(README, DEV_DOC, USER_DOC) go further than most submissions — they
explain *why* each design choice was made, not just what it does. That
said, there's one real security issue and a handful of rough edges
worth fixing before evaluation.

## Real problem: secrets are committed to git

`.gitignore` lists `.env` and `secrets/`, but both are already tracked:

```
git ls-files | grep -i secret
secrets/db_password.txt
secrets/db_root_password.txt
secrets/wp_admin_password.txt
secrets/wp_user_password.txt
```

`.gitignore` only blocks *new* untracked changes — files added before
the ignore rule (or added with `git add -f`) stay tracked and keep
getting committed. Right now the actual values are just placeholders
(`db_pass`, `wp_admin_pass`, ...), so there's no live credential
exposure, but:

- If these are ever changed to real passwords, they'll go straight
  into git history — and `git rm --cached` later doesn't erase them
  from prior commits.
- It contradicts the project's own README section on secrets vs env
  vars, which correctly explains why hardcoded credentials are bad —
  the same reasoning applies to committing the secret *files*.
- 42 evaluators do sometimes check `git log` / repo contents for
  leaked credentials.

Fix: `git rm --cached srcs/.env secrets/*.txt`, keep the gitignore
rule, and if this repo is ever made public, consider the current
values already "burned" (rotate them, even though they're placeholders).

`.DS_Store` is also tracked — harmless but sloppy; add it to
`.gitignore` and `git rm --cached` it.

## MariaDB entrypoint: password only set on first run

`setup_mariadb.sh` only runs the `ALTER USER` / `CREATE USER` block
inside `if [ ! -d "/var/lib/mysql/mysql" ]`. That's correct for normal
operation, but it means if `DATABASE_PASSWORD_FILE` content ever
changes without wiping the volume (e.g. rotating a secret), the DB
user's password silently stays the old one while `wp-config.php` would
be regenerated with the new one on a fresh WordPress volume — a subtle
mismatch source if the two volumes ever get out of sync (e.g. `fclean`
only wipes `wordpress` data but not `mariadb`, or vice versa via manual
`docker volume rm`). Not a bug per the subject's requirements, just
worth knowing operationally.

## WordPress entrypoint: no explicit `wp core is-installed` check

`setup_wordpress.sh` gates first-run install on
`[ ! -f wp-config.php ]`, which is reasonable, but there's no
verification the DB is actually reachable before `wp core download`
runs its unrelated network fetch — the TCP wait loop only checks
mariadb is listening, not that the DB/user from the entrypoint script
above actually exist yet by the time `wp config create` runs. In
practice `depends_on` + the port-wait loop makes the race very unlikely
since MariaDB creates the user before exiting its bootstrap block, but
it's still two independent startup scripts trusting timing rather than
a real readiness handshake.

## Nitpicks

- `Makefile`'s `up` target unconditionally appends to `/etc/hosts` via
  `sudo tee -a` guarded by a `grep` check computed once at Makefile
  parse time (`DOMAIN_VAL:=$(shell grep ...)`), not at rule execution
  time. If `make up` is run right after `fclean` removed the hosts
  entry in the *same* `make re` invocation, this still works because
  `re: fclean up` are separate recursive rule invocations — but it's
  easy to break if someone merges these into one recipe later.
- No `.dockerignore` — minor, since builds use narrow `COPY` contexts.
- `nginx.conf` has no HTTP→HTTPS redirect or port 80 listener, which
  is fine (subject only requires 443), but means typing `http://` in
  a browser just hangs/refuses rather than redirecting — acceptable,
  just worth knowing for the defense demo.
- `WP_ADMIN_EMAIL=carlaugu@inception.com` / `WP_USER_EMAIL=user@inception.com`
  in `.env` are fake domains — fine for the project, just flagging in
  case it's ever confused for a real contact address during defense.

## What's genuinely good

- Real subject requirements are met correctly: no `latest` tags, no
  `network: host`, no `links:`, containers `restart: unless-stopped`,
  TLSv1.2/1.3 only, PID 1 handled properly (`exec` used before both
  long-running processes in the entrypoints).
- Named volumes with `driver_opts` bind mount is the correct way to
  satisfy "named volumes" + "data lives in `/home/<login>/data`"
  simultaneously — a detail a lot of submissions get wrong.
- Documentation quality (README's VM-vs-Docker, secrets-vs-env,
  network, volumes sections) reads like genuine understanding, not
  copy-paste — this will help a lot at defense time.
