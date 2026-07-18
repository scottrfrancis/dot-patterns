---
name: portable-context-lift
description: >
  Use when moving a project or design out of one agent/chat/environment into another that
  cannot see the origin's history (chat → local IDE agent, one machine → another, tool →
  tool). Pack a self-contained handoff — the decisions, not just the files — plus a
  bootstrap the receiving agent executes to reconstitute the working context.
id: portable-context-lift
category: agent-orchestration
invocation: user
aliases: [lift-kit, handoff-bundle, spec-extraction-handoff]
triggers: [handoff, chat to code, migrate project, cross-tool, new session, "start fresh", context transfer]
source: base
status: active
related: [self-extracting-release-over-narrow-channel]
visibility: public
---

# Portable Context Lift

## Intent

Context dies at boundaries. A chat that designed something can't be read by the coding
agent; a new session starts blind; a teammate inherits files without the *why*. Moving
work across such a boundary needs more than the files — it needs the **decision history**
and a **bootstrap the receiving agent runs** to rebuild the working context, because the
origin's history is unreadable from the destination.

## Structure

1. **Extract the spec where the history lives** — the decisions, requirements, rejected
   options, open questions — because it can only be captured on the origin side. A pile of
   files without the decision history is a thin handoff.
2. **Bundle** spec + files + a **bootstrap script addressed to the receiving agent**
   (executable instructions, not prose for a human) into one artifact.
3. **Emit the handover at pack time**, carrying the exact artifact name/location — the
   receiving session's *entire* initial context is that handover, not memory of the chat.
4. On the receiving side, the agent **runs the bootstrap**: sets up memory (project
   `CLAUDE.md`/`AGENTS.md`), a decision log, session commands, git — reconstituting a
   working project, interactively, in the destination's idioms.
5. **Decision log is append-only** thereafter — the context stays true across sessions.

## House adaptation

- **Decisions > files.** The packed spec is a *decision history* ("we chose X over Y
  because Z; open question: W"), not a feature brochure. If it comes out thin, re-pack.
- **Bootstrap is executed, not read** — one-time setup runs once, interactively, the agent
  checking its own prerequisites; project memory moves out of ritual into loaded config.
- **The handover is emitted by the origin**, not read from a doc — only the origin knows
  the artifact name and the live decisions.
- Manual-mode first on the receiving side (propose → review diff → accept) until the human
  trusts the reconstitution.

## Reference instantiation

The `lift-kit` (chat → Claude Code project): pack extracts `SPEC.md` + files + `bootstrap.md`
into one zip, emits a personalized handover card; the Code session runs the bootstrap.
The `routometer` handoff bundle rode this pattern. Your `handoff`/`pickup` session commands
are the same shape at session granularity.

## Anti-patterns / when NOT

- Same-context continuation (same session, same tool) — just keep working; no lift needed.
- Don't pack raw chat logs and call it a handoff; distill the decisions or the receiving
  agent inherits noise.
