---
name: gof-index
description: >
  Use when choosing or naming a classic design pattern. A thin index of the Gang-of-Four
  catalog with house stances (favored / avoided / adapted) — the model already knows the
  mechanics; this records WHICH to reach for and which to avoid, and why.
id: gof-index
category: gof-behavioral
invocation: model
aliases: [gang-of-four, design-patterns]
triggers: [design pattern, gof, factory, strategy, observer, singleton, decorator, adapter]
source: base
status: active
visibility: public
---

# Gang-of-Four Index — with house stances

The 23 GoF patterns are in every model's weights; re-documenting them is waste (and
duplication). This index exists to record **which to reach for, which to avoid, and the
house adaptations** — the part the model doesn't have. Reference patterns by name; the
model supplies the mechanics.

Stance legend: **✓ favored** · **~ adapted** · **✗ avoided**

## Creational

| Pattern | Stance | Note |
|---|---|---|
| Factory Method | ✓ | Default for "construct a family member by key." Keep the factory dumb — a lookup, not logic. |
| Abstract Factory | ~ | Only when *families* of related objects vary together; otherwise it's ceremony. |
| Builder | ✓ | For >3 optional params. Prefer it over telescoping constructors / kwargs soup. |
| Prototype | ✗ | Rarely; deep-copy semantics are a footgun. Prefer explicit construction. |
| **Singleton** | ✗ | **Avoid.** Global mutable state in disguise; wrecks testability. Use DI / a passed-in instance / a module-level value with no hidden lifecycle. |

## Structural

| Pattern | Stance | Note |
|---|---|---|
| Adapter | ✓ | The honest way to bridge a mismatched interface. Name it `XAdapter`. |
| Decorator | ✓ | Compose behavior over inheritance. Great for cross-cutting (logging, caching, retry). |
| Facade | ✓ | Put one in front of any subsystem an agent/caller shouldn't need to understand. |
| Composite | ~ | Trees only; don't force flat data into it. |
| Proxy | ~ | Lazy-load / access-control / remote — keep the proxy's surface identical to the real thing. |
| Bridge | ✗ | Usually over-engineering; prefer composition without the formal split. |
| Flyweight | ✗ | Micro-optimization; reach for it only under measured memory pressure. |

## Behavioral

| Pattern | Stance | Note |
|---|---|---|
| Strategy | ✓ | **Top pick.** Swappable algorithm behind one interface — the antidote to `if/elif` ladders and inheritance. |
| Observer | ~ | As an event bus, yes; but prefer an explicit queue/stream over hidden callback webs — debuggability. |
| State | ✓ | When behavior varies by an explicit lifecycle (see the ADR status lifecycle). Make states data, not subclasses, when small. |
| Command | ✓ | Reifies an action → undo/redo, queueing, audit. Pairs with an append-only log. |
| Template Method | ~ | Fine, but Strategy (composition) usually beats it (inheritance). |
| Chain of Responsibility | ✓ | Pipelines/middleware — matches the pipeline() fan-out shape. |
| Iterator | ✓ | Use the language's native iteration; don't hand-roll. |
| Mediator | ~ | Prevents object spaghetti, but can become a god-object — watch its size. |
| Memento | ~ | Snapshot/restore (checkpointing); keep the snapshot opaque to the originator. |
| Visitor | ✗ | Double-dispatch ceremony; prefer pattern-matching / a tagged union where the language allows. |
| Interpreter | ✗ | Reach for a real parser/library; almost never hand-build. |

## House meta-stances

- **Composition over inheritance** — nearly always. Strategy/Decorator > Template/Bridge.
- **Make state data, not class hierarchies**, when the set is small and known.
- **Name the pattern in code and PRs** so reviewers share the vocabulary — but don't
  pattern-wash simple code; a function is not a Command.
