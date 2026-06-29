# Engineering Principles

Reference: https://jdforsythe.github.io/10-principles/

---

## P01 — Hardening

> "Every fuzzy LLM step that must behave identically every time must eventually be replaced by a deterministic tool."

LLMs are non-deterministic. When correctness is required — parsing a date, validating a schema, writing to a file — a tool call produces reliable results where prose does not. Reserve LLM judgment for tasks that genuinely require it: ambiguity resolution, creative synthesis, contextual reasoning.

**Do:** Replace "format this date string" with a tool call to a date formatter.
**Don't:** Ask an LLM to consistently produce ISO-8601 output across 10,000 requests.

---

## P02 — Context Hygiene

> "Context is your scarcest resource. Treat it like memory in an embedded system, not disk space on a server."

Every token in context has a cost: slower inference, higher expense, and degraded attention on what matters. Prune stale tool results. Use `@` file references instead of pasting content. Load domain-specific guides only when working in that domain. When a conversation grows long, summarize completed work and discard the raw trace.

**Do:** Reference `.harness/a11y/references/forms.md` only when writing form components.
**Don't:** Load all reference files at session start and leave them in context all day.

---

## P03 — Living Documentation

> "Documentation is context. Stale documentation is poisoned context."

An agent that reads outdated docs will make confident wrong decisions. Every documentation file is a claim about reality. When you change behavior, update the doc in the same commit. When you read a doc and find it wrong, fix it before you proceed. The cost of a stale doc compounds with every agent that trusts it.

**Do:** Update `.harness/a11y/A11Y.md` when a rule is refined based on project experience.
**Don't:** Let `docs/harness/learnings.md` go stale while rules drift.

---

## P04 — Disposable Blueprint

> "Never implement without a saved, versioned plan artifact. And never fall in love with one."

Plans make thinking visible and reviewable — not constrain execution. Save every plan to a file before writing a line of code. Treat the plan as a hypothesis, not a contract. When new information contradicts the plan, update the plan first, then implement. A plan you abandon without updating is a lie waiting to mislead the next agent.

**Do:** Save plans to `docs/superpowers/plans/` and commit before implementing.
**Don't:** Hold the plan mentally and start coding immediately.

---

## P05 — Institutional Memory

> "When an agent makes a mistake, don't just correct it — codify it forever."

Correcting a mistake in place means the next agent will make it again. When Claude produces wrong output and you correct it, that correction is a signal: something in the context failed to prevent the mistake. Document the failure mode and its fix in `docs/harness/learnings.md`. The Stop hook fires at every session end to prompt this.

**Do:** Add an entry to `docs/harness/learnings.md` after any correction: what happened, why, and how to prevent it.
**Don't:** Accept the corrected output and move on — the lesson disappears.

---

## P06 — Specialized Review

> "A generalist reviewer trends toward the median. Specialists find what generalists can't."

A single "review this" prompt produces generic feedback. A reviewer told to look only for security issues finds security issues. A reviewer told to check only type safety finds type errors. Use the code-review skill with explicit focus areas. For accessibility specifically, use the REPORT.md checklist — it forces domain-specific attention that a general review misses.

**Do:** Run separate review passes: one for logic, one for a11y, one for security.
**Don't:** Ask "does this look good?" and trust the answer.

---

## P07 — Observability Imperative

> "If you can't see inside your pipeline, you're trusting it on faith."

Agents that produce output silently are black boxes. Log decisions, not just results. When a tool call produces unexpected output, surface it — don't swallow it. The Stop hook logs session boundaries. Use `docs/harness/learnings.md` as an audit trail for agent decisions that surprised you. What you can't observe, you can't improve.

**Do:** Log unexpected tool outputs and agent decisions to `docs/harness/learnings.md`.
**Don't:** Accept "it worked" without knowing why, especially for consequential operations.

---

## P08 — Strategic Human Gate

> "Rubber-stamp approval is the single most common quality failure in multi-agent systems."

Human review is only valuable if the reviewer is actually reviewing. A gate that always approves is worse than no gate: it creates false confidence while adding latency. If you're approving a plan or diff without reading it, stop. If a gate is always green, remove it or make it meaningful. Flag ambiguous requirements before implementing — don't guess and ask for forgiveness.

**Do:** Stop before implementing an ambiguous requirement and ask for clarification.
**Don't:** Infer intent and implement, then wait for correction.

---

## P09 — Token Economy

> "Tokens are money. Most people are burning it."

Every context load, every tool call, every re-read of a file has a cost. Measure token usage by asking: would I pay for this if it had a dollar sign? Load files once, reference by path when possible. Summarize completed work instead of carrying the full trace. Choose the smallest model capable of the task.

**Do:** Summarize a completed 10-task session into a one-paragraph handoff note.
**Don't:** Re-read the full transcript of a previous session to "remember" what happened.

---

## P10 — Toolkit Principle

> "Knowledge without automation decays. Encode your principles into tools that enforce them automatically."

A principle written in a doc requires a human to remember to apply it. A principle encoded in a hook, a linter, or a skill enforces itself. The pre-commit hook in this harness enforces P06 (a11y review) automatically. The Stop hook enforces P05 (institutional memory) automatically. Every principle you find yourself repeatedly reminding agents about is a candidate for automation.

**Do:** When you correct the same mistake twice, write a hook or add a rule to CLAUDE.md.
**Don't:** Add a "remember to..." comment to a doc and trust it will be read.
