# Pattern-library directive

Paste this one block into each tool's always-on base config so agents *consult* the
library at design time (dot-claude `CLAUDE.md`, dot-copilot `copilot-instructions.md`,
dot-cursor an `alwaysApply` rule, dot-droid/opencode `AGENTS.md`). It's the cheap,
universal layer of the three (directive · retrieval · review-enforcement).

---

## Design-pattern discipline

Before designing a non-trivial component, or coining a new mechanism/abstraction:

- **Consult the pattern library first.** On the LAN, query it via `kb-mcp` (`search` the
  pattern corpus). Off-LAN, check the installed skills / `patterns/` you have.
- **Name the pattern you apply** ("this is Strategy" / "this is the data-diode black/white/
  gray") in your plan and PR, so reviewers share the vocabulary.
- **Don't reinvent what the library already names.** If an applicable pattern exists,
  reuse it; if you deviate, say why.
- **If you coin something reusable, flag it for capture** ("this looks like a reusable
  pattern → draft a library entry") rather than letting it evaporate.

Prefer the house stances in the GoF index (composition over inheritance; Strategy over
if-ladders; avoid Singleton/Visitor) unless there's a stated reason.
