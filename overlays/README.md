# overlays/ — private, per-profile pattern layers

Overlays hold patterns that are **not part of the public base** — LAN-only, or specific to
a particular egress target. They layer on top of `base/` for a given release profile and
**never travel to the public mirror**.

## Naming — no real entity names

Name an overlay with the **generic profile handle** you chose in
`~/.config/patterns/profiles/<handle>.conf` (e.g. `overlays/<handle>/`). Do **not** name a
directory (or a pattern's `visibility`) after a real client/employer/host — that identifier
belongs only in the profile's local scrublist, never in the repo tree.

## Privacy

Overlay contents are **git-ignored by default** (see `.gitignore`) so private patterns
can't be committed by accident. Version them in a separate private repo if you want history,
or keep them local. `bin/release.sh` composes `base` + the profile's overlay at release
time and refuses to let any *other* overlay ride along.

Each pattern here sets `visibility: <handle>` in its frontmatter; `bin/generate.py
--visibility <handle>` includes it, and only that handle's release does.
