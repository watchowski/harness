# 08 · The Strategic Human Gate Principle

**Rule:** Rubber-stamp approval is the single most common quality failure in multi-agent systems. Few gates, real gates.

## Mandatory gates (stop and wait for explicit approval)
1. **Plan approval** before implementing `structural` work.
2. **Destructive operations:** deletions of non-trivial code/data, migrations, force-push, history rewrites, production configuration.
3. **Dependency changes:** adding/upgrading libraries, changing toolchains.

## Agent protocol
- At a gate, present a **decision-ready summary**: what, why, alternatives considered, blast radius, rollback path. Then stop.
- Never bundle gated and non-gated changes so approval of one smuggles in the other.
- Do not create so many gates that the human starts rubber-stamping — if a gate is always approved without thought, propose removing it.

## Anti-patterns
- "I went ahead and also migrated the schema."
- Asking for approval with a wall of text and no recommendation.
