# Harness Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build every file in the harness repo — content, hooks, settings, and installers — so that a single `curl | bash` command installs a complete Claude Code engineering + accessibility harness into any project.

**Architecture:** The GitHub repo layout mirrors what gets installed. `CLAUDE.md` imports `.harness/principles.md` and `.harness/a11y/A11Y.md` via `@` references. Python 3 hooks fire at `PreToolUse` (Bash) and `Stop` events. Shell/PowerShell installers download from raw GitHub URLs.

**Tech Stack:** Markdown (content), Python 3 (hooks), Bash (install.sh), PowerShell 5+ (install.ps1), JSON (settings.json)

## Global Constraints

- No build step, no npm, no Node.js
- Hooks must be Python 3 — portable across Linux/macOS/Windows WSL
- WCAG standard: 2.2 AA (not 2.1, not AAA)
- `<OWNER>` placeholder in installer URLs — user replaces with their GitHub username before publishing
- `CLAUDE.md` uses `@filename` syntax for file references (Claude Code native)
- All files committed individually per task; commit messages use `feat:` prefix

---

### Task 1: CLAUDE.md — Orchestrator

**Files:**
- Create: `CLAUDE.md`

**Interfaces:**
- Produces: the file Claude Code reads at every session start; references `.harness/principles.md` and `.harness/a11y/A11Y.md`

- [ ] **Step 1: Create CLAUDE.md**

```markdown
# Project Harness

## Engineering Discipline
@.harness/principles.md

## Accessibility
@.harness/a11y/A11Y.md

## Behavioral Rules (always active)

- Before any implementation, save a versioned plan artifact (Principle 04)
- When an agent makes a mistake, codify it in docs/harness/learnings.md (Principle 05)
- Never rubber-stamp. Flag ambiguous requirements before proceeding (Principle 08)
- Treat the context window as a scarce resource. Prune aggressively (Principle 02)
```

Write this content to `CLAUDE.md` in the project root.

- [ ] **Step 2: Verify**

```bash
grep -c "@.harness/principles.md" CLAUDE.md
```

Expected output: `1`

```bash
grep -c "@.harness/a11y/A11Y.md" CLAUDE.md
```

Expected output: `1`

- [ ] **Step 3: Commit**

```bash
git add CLAUDE.md
git commit -m "feat: add CLAUDE.md orchestrator"
```

---

### Task 2: .harness/principles.md — Engineering Principles

**Files:**
- Create: `.harness/principles.md`

**Interfaces:**
- Consumed by: `CLAUDE.md` via `@.harness/principles.md`
- Produces: AI-facing rule set for all 10 engineering principles

- [ ] **Step 1: Create .harness/principles.md**

Create the file at `.harness/principles.md` with this exact content:

```markdown
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
```

- [ ] **Step 2: Verify**

```bash
grep -c "^## P" .harness/principles.md
```

Expected output: `10`

- [ ] **Step 3: Commit**

```bash
git add .harness/principles.md
git commit -m "feat: add engineering principles (10 principles)"
```

---

### Task 3: .harness/a11y/A11Y.md — Accessibility Rules Matrix

**Files:**
- Create: `.harness/a11y/A11Y.md`

**Interfaces:**
- Consumed by: `CLAUDE.md` via `@.harness/a11y/A11Y.md`
- Produces: AI-facing accessibility ruleset, WCAG 2.2 AA mapped

- [ ] **Step 1: Create .harness/a11y/A11Y.md**

```markdown
# Accessibility Rules

Reference: https://github.com/fecarrico/A11Y.md
Standard: WCAG 2.2 AA

---

## Philosophy

- **Human-Centric:** These rules exist to ensure genuine autonomy for users with disabilities — not checkbox compliance.
- **AI-Ready:** Rules are written deterministically to constrain AI coding agents and prevent inaccessible patterns from being generated.
- **Certifiable:** Every rule is mapped to a WCAG 2.2 AA success criterion for audit traceability.

---

## Interactive Elements [WCAG 2.1.1, 2.1.2, 4.1.2]

- All interactive elements MUST be natively interactive HTML (`<button>`, `<a>`, `<input>`, `<select>`) — never `<div>`, `<span>`, or `<li>` with click handlers
- All interactive elements MUST be keyboard operable (focusable with Tab, activatable with Enter/Space)
- No keyboard trap: users MUST be able to navigate away from any focused element using keyboard alone
- Every interactive element MUST have an accessible name: visible label, `aria-label`, or `aria-labelledby`
- Disabled elements SHOULD use the `disabled` attribute unless focusable-while-disabled behavior is intentionally required

---

## Focus Management [WCAG 2.4.3, 2.4.7, 2.4.11]

- Focus order MUST follow a logical reading sequence (left-to-right, top-to-bottom in LTR layouts)
- Focus MUST always be visible — never `outline: none` or `outline: 0` without an equivalent custom focus indicator
- Custom focus indicators MUST have at least 3:1 contrast against adjacent colors and enclose the component with at least 2px offset
- When a modal opens, focus MUST move to the modal container or its first focusable element
- When a modal closes, focus MUST return to the element that triggered it
- Dynamic content insertions (toasts, alerts) MUST NOT steal focus unless they require immediate user action

---

## Forms [WCAG 1.3.1, 3.3.1, 3.3.2, 4.1.2]

- Every `<input>`, `<select>`, and `<textarea>` MUST have a programmatically associated `<label>` via `for`/`id` or `aria-labelledby` — placeholder text alone is NOT a label
- Required fields MUST be identified visually AND programmatically (`required` or `aria-required="true"`)
- Error messages MUST be associated with their field via `aria-describedby`
- Error messages MUST be announced to screen readers via an `aria-live="polite"` region or by moving focus to the error
- Form validation MUST NOT rely on color alone to indicate state — pair color with icon, text, or pattern
- Autocomplete attributes MUST be used for personal data fields (`name`, `email`, `tel`, etc.) per HTML spec

---

## Modals and Overlays [WCAG 2.1.1, 2.1.2, 4.1.2]

- When a modal is open, focus MUST be trapped inside it — Tab and Shift+Tab cycle only through focusable elements within the modal
- Escape key MUST close all dismissible modals and overlays
- Modal root element MUST have `role="dialog"` and `aria-modal="true"`
- Modal MUST have an accessible name via `aria-labelledby` pointing to the modal title, or `aria-label`
- Background content MUST be inert (`inert` attribute or `aria-hidden="true"` on app root) while a modal is open
- Non-modal overlays (tooltips, dropdowns) MUST also be closeable via Escape

---

## Images and Media [WCAG 1.1.1, 1.2.1]

- Informative images MUST have descriptive `alt` text that conveys the same information as the image
- Decorative images MUST have `alt=""` (empty string, not omitted) so screen readers skip them
- Complex images (charts, graphs, diagrams) MUST have either adjacent long-description text or `aria-describedby` pointing to a detailed description
- Icon-only buttons MUST have `aria-label` describing the action, not the icon name
- SVG elements used as images MUST have `role="img"` and `aria-label` or `<title>` as first child
- Video content MUST have captions; audio-only content MUST have transcripts

---

## Color and Contrast [WCAG 1.4.1, 1.4.3, 1.4.11]

- Normal text (under 18pt or 14pt bold): minimum 4.5:1 contrast ratio against background
- Large text (18pt+ or 14pt+ bold): minimum 3:1 contrast ratio against background
- UI components (input borders, button outlines, icons): minimum 3:1 contrast against adjacent colors
- Information MUST NOT be conveyed by color alone — always pair with text, icon, or pattern
- Placeholder text MUST meet 4.5:1 contrast (it is text, not decorative)

---

## Navigation and Structure [WCAG 1.3.1, 2.4.1, 2.4.6, 3.1.1]

- Page MUST have a skip-to-main-content link as the first focusable element
- Page MUST use landmark regions: `<header>`, `<nav>`, `<main>`, `<footer>` or equivalent ARIA roles
- Heading hierarchy MUST be logical: one `<h1>` per page, headings MUST NOT skip levels (h1 → h3 without h2)
- `<html>` element MUST have a `lang` attribute matching the page language
- Navigation patterns (tabs, accordions, trees) MUST implement the correct ARIA Authoring Practices Guide pattern
- Dynamic page title MUST update to reflect current view in single-page applications

---

## Responsive and Adaptive [WCAG 1.4.4, 1.4.10, 1.4.12]

- Text MUST be resizable up to 200% without loss of content or functionality
- Content MUST reflow at 320px viewport width without horizontal scrolling (except content requiring 2D layout)
- Text spacing MUST be adjustable (line height 1.5×, letter spacing 0.12em, word spacing 0.16em) without loss of content
- Touch targets MUST be at least 24×24px (WCAG 2.2 AA minimum); aim for 44×44px

---

## Status and Live Regions [WCAG 4.1.3]

- Success messages, error summaries, and loading states MUST be announced via `aria-live` regions
- Use `aria-live="polite"` for non-urgent updates (success messages, item counts)
- Use `aria-live="assertive"` only for critical alerts requiring immediate attention
- `role="status"` for polite updates, `role="alert"` for assertive — never both on the same element
```

- [ ] **Step 2: Verify**

```bash
grep -c "^\-\-\-" .harness/a11y/A11Y.md
```

Expected output: `9` (section dividers)

```bash
grep "WCAG" .harness/a11y/A11Y.md | wc -l
```

Expected output: at least `10` (each section header has a WCAG citation)

- [ ] **Step 3: Commit**

```bash
git add .harness/a11y/A11Y.md
git commit -m "feat: add accessibility rules matrix (WCAG 2.2 AA)"
```

---

### Task 4: .harness/a11y/references/ — Domain Guides

**Files:**
- Create: `.harness/a11y/references/forms.md`
- Create: `.harness/a11y/references/navigation.md`
- Create: `.harness/a11y/references/modals.md`
- Create: `.harness/a11y/references/contrast.md`
- Create: `.harness/a11y/references/images.md`

**Interfaces:**
- Consumed by: Claude selectively via `@.harness/a11y/references/<domain>.md` when working in that domain
- Produces: detailed patterns and code examples per domain

- [ ] **Step 1: Create forms.md**

```markdown
# Forms — Accessibility Reference

## Label Patterns

### Visible label (preferred)
```html
<label for="email">Email address</label>
<input type="email" id="email" name="email" required autocomplete="email">
```

### Visually hidden label (when space is constrained)
```html
<label for="search" class="sr-only">Search</label>
<input type="search" id="search" placeholder="Search…">
```

### Group label with fieldset
```html
<fieldset>
  <legend>Shipping address</legend>
  <label for="street">Street</label>
  <input type="text" id="street" name="street" autocomplete="street-address">
</fieldset>
```

## Error Handling

### Inline field error
```html
<label for="email">Email</label>
<input
  type="email"
  id="email"
  aria-describedby="email-error"
  aria-invalid="true"
>
<span id="email-error" role="alert">Enter a valid email address.</span>
```

### Error summary (multi-field forms)
```html
<div role="alert" aria-live="polite">
  <h2>Fix these errors before continuing</h2>
  <ul>
    <li><a href="#email">Email: Enter a valid email address.</a></li>
  </ul>
</div>
```

## Required Fields
```html
<input type="text" id="name" required aria-required="true">

<!-- Explain the convention near the form top -->
<p>Fields marked with <span aria-hidden="true">*</span><span class="sr-only">an asterisk</span> are required.</p>
```

## Autocomplete Tokens
| Field type | Token |
|------------|-------|
| Full name | `name` |
| First name | `given-name` |
| Last name | `family-name` |
| Email | `email` |
| Phone | `tel` |
| Street address | `street-address` |
| City | `address-level2` |
| Postal code | `postal-code` |
| Country | `country` |
| New password | `new-password` |
| Current password | `current-password` |

## Utility: sr-only class
```css
.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0,0,0,0);
  white-space: nowrap;
  border: 0;
}
```
```

- [ ] **Step 2: Create navigation.md**

```markdown
# Navigation — Accessibility Reference

## Skip Link (first focusable element on page)
```html
<a href="#main-content" class="skip-link">Skip to main content</a>

<style>
.skip-link {
  position: absolute;
  top: -40px;
  left: 0;
  background: #000;
  color: #fff;
  padding: 8px;
  z-index: 9999;
}
.skip-link:focus { top: 0; }
</style>
```

## Landmark Structure
```html
<body>
  <a href="#main" class="skip-link">Skip to main content</a>
  <header role="banner">…</header>
  <nav aria-label="Primary">…</nav>
  <main id="main">…</main>
  <nav aria-label="Secondary">…</nav>
  <aside>…</aside>
  <footer role="contentinfo">…</footer>
</body>
```
Multiple `<nav>` elements each need a unique `aria-label`.

## Disclosure Navigation Menu (preferred over ARIA menubar)
```html
<nav aria-label="Primary">
  <ul>
    <li>
      <button aria-expanded="false" aria-controls="products-menu">
        Products
      </button>
      <ul id="products-menu" hidden>
        <li><a href="/products/a">Product A</a></li>
        <li><a href="/products/b">Product B</a></li>
      </ul>
    </li>
  </ul>
</nav>
```

## Breadcrumb
```html
<nav aria-label="Breadcrumb">
  <ol>
    <li><a href="/">Home</a></li>
    <li><a href="/products">Products</a></li>
    <li><a href="/products/a" aria-current="page">Product A</a></li>
  </ol>
</nav>
```

## Tabs (ARIA Tab Pattern)
```html
<div role="tablist" aria-label="Account settings">
  <button role="tab" aria-selected="true"  aria-controls="profile-tab-panel"  id="profile-tab">Profile</button>
  <button role="tab" aria-selected="false" aria-controls="security-tab-panel" id="security-tab" tabindex="-1">Security</button>
</div>
<div role="tabpanel" id="profile-tab-panel"  aria-labelledby="profile-tab">…</div>
<div role="tabpanel" id="security-tab-panel" aria-labelledby="security-tab" hidden>…</div>
```
Keyboard: Arrow keys move between tabs. Tab moves into the active panel.
```

- [ ] **Step 3: Create modals.md**

```markdown
# Modals — Accessibility Reference

## Modal Structure
```html
<div
  role="dialog"
  aria-modal="true"
  aria-labelledby="modal-title"
  id="confirm-dialog"
>
  <h2 id="modal-title">Confirm deletion</h2>
  <p>This action cannot be undone.</p>
  <button type="button">Cancel</button>
  <button type="button">Delete</button>
</div>
```

## Focus Trap
```javascript
function trapFocus(modalElement) {
  const focusable = modalElement.querySelectorAll(
    'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
  );
  const first = focusable[0];
  const last  = focusable[focusable.length - 1];

  modalElement.addEventListener('keydown', (e) => {
    if (e.key !== 'Tab') return;
    if (e.shiftKey) {
      if (document.activeElement === first) { last.focus();  e.preventDefault(); }
    } else {
      if (document.activeElement === last)  { first.focus(); e.preventDefault(); }
    }
  });
}
```

## Open / Close Pattern
```javascript
let currentTrigger;

function openModal(modal, trigger) {
  currentTrigger = trigger;
  modal.removeAttribute('hidden');
  document.getElementById('app').setAttribute('inert', '');
  trapFocus(modal);
  modal.focus();
  document.addEventListener('keydown', handleEscape);
}

function closeModal(modal) {
  modal.setAttribute('hidden', '');
  document.getElementById('app').removeAttribute('inert');
  document.removeEventListener('keydown', handleEscape);
  currentTrigger?.focus();
}

function handleEscape(e) {
  if (e.key === 'Escape') closeModal(document.getElementById('confirm-dialog'));
}
```

## Background Inert (preferred over aria-hidden)
```html
<!-- app root becomes inert; modal sits outside or above it -->
<div id="app" inert>…page content…</div>
<div role="dialog" aria-modal="true">…modal…</div>
```

## Non-Modal Overlays
- Must close on Escape — do NOT use `role="dialog"` or `aria-modal`
- Tooltip: `role="tooltip"` on overlay + `aria-describedby` on trigger
- Dropdown menu: `role="menu"` on container, `role="menuitem"` on each item
```

- [ ] **Step 4: Create contrast.md**

```markdown
# Contrast — Accessibility Reference

## WCAG 2.2 AA Ratios
| Element type | Minimum ratio |
|---|---|
| Normal text (< 18pt or < 14pt bold) | 4.5:1 |
| Large text (≥ 18pt or ≥ 14pt bold) | 3:1 |
| UI components (input borders, icons, button outlines) | 3:1 |
| Focus indicators | 3:1 against adjacent colors |
| Placeholder text | 4.5:1 (it is text) |
| Disabled controls | No requirement (but aim for readability) |

## Common Failures
| Pattern | Actual ratio | Problem | Fix |
|---|---|---|---|
| #767676 on #fff | 4.48:1 | Fails for normal text | Use #595959 (7.0:1) |
| #1e90ff on #fff | 3.04:1 | Fails for all text sizes | Use #0057b8 (4.6:1) |
| #999 on #fff (placeholder) | 2.85:1 | Fails | Use #767676 minimum |
| White icon on light gray | Varies | Often fails 3:1 | Test rendered values |

## Color-Only Information — Always Pair With:
- Form error state → icon + text label (not just red border)
- Chart data series → pattern fill or direct labels (not just color)
- Required fields → asterisk + legend (not just red text)
- Links in body copy → underline (not just color difference)

## Checking Tools
- Browser: Chrome DevTools → Elements → Accessibility → Contrast ratio
- CLI: `npx @axe-core/cli <url>`
- Design: Figma "Contrast" or "A11y - Color Contrast Checker" plugin
```

- [ ] **Step 5: Create images.md**

```markdown
# Images — Accessibility Reference

## Alt Text Decision Tree

```
Is the image purely decorative (adds no information)?
├─ Yes → alt=""  (empty string — never omit the attribute)
└─ No  → Does adjacent text already say the same thing?
          ├─ Yes → alt=""  (avoid redundancy)
          └─ No  → Write descriptive alt text
```

## Writing Good Alt Text
- Describe **content and purpose**, not visual appearance
- For photos in context: describe what is happening, not physical traits
- For charts: state the key takeaway: "Bar chart showing Q3 revenue up 23% year-over-year"
- For logos: use brand name: "Acme Corporation logo"
- For icon-only buttons: describe the action: "Close dialog"
- Keep under 150 characters; use `aria-describedby` for longer descriptions

## Code Patterns
```html
<!-- Informative image -->
<img src="warning.svg" alt="Warning">

<!-- Decorative image -->
<img src="divider.png" alt="">

<!-- Complex image with long description -->
<img src="org-chart.png" alt="Organisation chart" aria-describedby="org-desc">
<p id="org-desc">The CEO reports to the board. Three VPs report to the CEO: Engineering, Product, and Sales.</p>

<!-- SVG as image -->
<svg role="img" aria-label="Download" xmlns="http://www.w3.org/2000/svg">
  <title>Download</title>
  <path d="…"/>
</svg>

<!-- Icon-only button -->
<button aria-label="Close dialog">
  <svg aria-hidden="true" focusable="false">…</svg>
</button>

<!-- Linked image — alt describes destination -->
<a href="/home">
  <img src="logo.png" alt="Acme Corporation — Home">
</a>
```

## CSS Background Images
Cannot carry alt text. If a background image conveys information:
1. Switch to an `<img>` element, **or**
2. Add `.sr-only` text alongside it, **or**
3. Make it truly decorative and convey the information another way
```

- [ ] **Step 6: Verify all five files exist**

```bash
ls .harness/a11y/references/
```

Expected output lists: `contrast.md  forms.md  images.md  modals.md  navigation.md`

- [ ] **Step 7: Commit**

```bash
git add .harness/a11y/references/
git commit -m "feat: add a11y domain reference guides (forms, nav, modals, contrast, images)"
```

---

### Task 5: A11Y Templates — REPORT.md and EXCEPTIONS.md

**Files:**
- Create: `.harness/a11y/REPORT.md`
- Create: `.harness/a11y/EXCEPTIONS.md`

**Interfaces:**
- Consumed by: Claude fills REPORT.md before UI PRs; team fills EXCEPTIONS.md for justified deviations
- Produces: pre-merge quality gate and audit trail

- [ ] **Step 1: Create .harness/a11y/REPORT.md**

```markdown
# Accessibility Report

**PR / Feature:** <!-- fill in -->
**Date:** <!-- fill in -->
**Reviewer:** Claude Code

---

## Interactive Elements [WCAG 2.1.1, 4.1.2]

- [ ] All interactive elements use native HTML (`<button>`, `<a>`, `<input>`, `<select>`)
- [ ] All interactive elements are keyboard operable (Tab + Enter/Space)
- [ ] No div/span/li with click handlers used as interactive elements
- [ ] Every interactive element has an accessible name

## Focus Management [WCAG 2.4.3, 2.4.7, 2.4.11]

- [ ] Focus order is logical
- [ ] Focus is always visible (no `outline: none` without custom replacement)
- [ ] Modals trap focus when open and return focus to trigger on close
- [ ] Dynamic content does not steal focus inappropriately

## Forms [WCAG 1.3.1, 3.3.1, 3.3.2]

- [ ] All inputs have programmatically associated labels
- [ ] Required fields marked visually and via `required` / `aria-required`
- [ ] Errors associated with fields via `aria-describedby`
- [ ] Errors announced via `aria-live` or focus movement
- [ ] Autocomplete attributes used for personal data fields

## Modals [WCAG 2.1.1, 4.1.2]

- [ ] Modal has `role="dialog"` and `aria-modal="true"`
- [ ] Modal has accessible name via `aria-labelledby`
- [ ] Escape key closes modal
- [ ] Background is inert while modal is open

## Images [WCAG 1.1.1]

- [ ] Informative images have descriptive alt text
- [ ] Decorative images have `alt=""`
- [ ] Complex images have long descriptions
- [ ] Icon-only buttons have `aria-label`

## Color and Contrast [WCAG 1.4.1, 1.4.3, 1.4.11]

- [ ] Normal text meets 4.5:1 contrast
- [ ] Large text meets 3:1 contrast
- [ ] UI components meet 3:1 contrast
- [ ] Information not conveyed by color alone

## Navigation [WCAG 1.3.1, 2.4.1]

- [ ] Skip link present (if page-level change)
- [ ] Landmark regions used correctly
- [ ] Heading hierarchy is logical

## Status Messages [WCAG 4.1.3]

- [ ] Success/error/loading states announced via `aria-live`

---

## Issues Found

<!-- List any a11y issues discovered and how they were resolved, or "None" -->

## Exceptions

<!-- List any deviations from A11Y.md rules and add them to EXCEPTIONS.md, or "None" -->
```

- [ ] **Step 2: Create .harness/a11y/EXCEPTIONS.md**

```markdown
# Accessibility Exceptions Log

Deviations from `.harness/a11y/A11Y.md` rules must be documented here before the PR merges. Each exception requires justification, an owner, and a target resolution date.

---

## Adding an Exception

Copy the template below, fill in all fields, and add it under **Active Exceptions**.

```markdown
### EXC-<number>: <short description>

| Field | Value |
|---|---|
| **Rule** | [WCAG criterion and the specific rule from A11Y.md] |
| **Location** | [File path and component name] |
| **Justification** | [Why compliance is not currently achievable] |
| **Owner** | [GitHub username or team] |
| **Date logged** | [YYYY-MM-DD] |
| **Target resolution** | [YYYY-MM-DD or "permanent — see justification"] |
```

---

## Active Exceptions

<!-- Add exceptions below this line. Remove when resolved. -->
```

- [ ] **Step 3: Verify**

```bash
grep -c "^\- \[ \]" .harness/a11y/REPORT.md
```

Expected output: at least `20` (checklist items)

- [ ] **Step 4: Commit**

```bash
git add .harness/a11y/REPORT.md .harness/a11y/EXCEPTIONS.md
git commit -m "feat: add a11y templates (REPORT.md, EXCEPTIONS.md)"
```

---

### Task 6: .claude/hooks/ — pre-commit and stop

**Files:**
- Create: `.claude/hooks/pre-commit`
- Create: `.claude/hooks/stop`

**Interfaces:**
- `pre-commit`: registered in `settings.json` as `PreToolUse` hook on `Bash` matcher; receives JSON on stdin
- `stop`: registered in `settings.json` as `Stop` hook; receives JSON on stdin
- Both: exit 0 (non-blocking); output goes to Claude's context

- [ ] **Step 1: Create .claude/hooks/pre-commit**

```python
#!/usr/bin/env python3
"""
PreToolUse hook (Bash matcher).
Fires before every Bash tool call. Checks if the command is a git commit
touching UI files and, if so, reminds Claude to complete REPORT.md.
"""
import sys
import json
import subprocess

def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        sys.exit(0)

    tool_name = data.get("tool_name", "")
    command   = data.get("tool_input", {}).get("command", "")

    if tool_name != "Bash" or "git commit" not in command:
        sys.exit(0)

    try:
        result = subprocess.run(
            ["git", "diff", "--cached", "--name-only"],
            capture_output=True,
            text=True,
            timeout=5
        )
    except Exception:
        sys.exit(0)

    ui_exts = (".html", ".tsx", ".jsx", ".vue", ".svelte", ".css", ".scss", ".sass")
    ui_files = [f for f in result.stdout.splitlines() if f.endswith(ui_exts)]

    if ui_files:
        print("A11Y REMINDER (Principle 06 — Specialized Review):")
        print(f"UI files staged: {', '.join(ui_files)}")
        print("Before committing: complete .harness/a11y/REPORT.md for this change.")
        print("Rules reference: .harness/a11y/A11Y.md")

    sys.exit(0)

if __name__ == "__main__":
    main()
```

- [ ] **Step 2: Create .claude/hooks/stop**

```python
#!/usr/bin/env python3
"""
Stop hook. Fires at the end of each Claude turn.
Prompts institutional memory capture per Principle 05.
"""
import sys
import json

def main():
    try:
        json.load(sys.stdin)  # consume stdin
    except Exception:
        pass

    print("INSTITUTIONAL MEMORY CHECK (Principle 05):")
    print("Did any mistakes, unexpected behaviors, or corrections occur this session?")
    print("If yes — add an entry to docs/harness/learnings.md:")
    print("  1. What happened")
    print("  2. Why it happened")
    print("  3. How to prevent it in future sessions")

    sys.exit(0)

if __name__ == "__main__":
    main()
```

- [ ] **Step 3: Test pre-commit hook with mock UI-file git commit input**

```bash
echo '{"tool_name":"Bash","tool_input":{"command":"git commit -m test"}}' \
  | python3 .claude/hooks/pre-commit
```

Expected: no output (no staged files in test environment)

Test with a simulated UI file staged:
```bash
mkdir -p /tmp/harnesstest && cd /tmp/harnesstest && git init -q && git config user.email "test@test.com" && git config user.name "Test"
touch /tmp/harnesstest/component.tsx && git -C /tmp/harnesstest add component.tsx
echo '{"tool_name":"Bash","tool_input":{"command":"git commit -m test"}}' \
  | python3 /path/to/.claude/hooks/pre-commit
```

Expected output contains: `A11Y REMINDER` and `component.tsx`

- [ ] **Step 4: Test stop hook**

```bash
echo '{"session_id":"test"}' | python3 .claude/hooks/stop
```

Expected output:
```
INSTITUTIONAL MEMORY CHECK (Principle 05):
Did any mistakes, unexpected behaviors, or corrections occur this session?
If yes — add an entry to docs/harness/learnings.md:
  1. What happened
  2. Why it happened
  3. How to prevent it in future sessions
```

- [ ] **Step 5: Make hooks executable**

```bash
chmod +x .claude/hooks/pre-commit .claude/hooks/stop
```

- [ ] **Step 6: Commit**

```bash
git add .claude/hooks/
git commit -m "feat: add pre-commit and stop hooks (Python 3)"
```

---

### Task 7: .claude/settings.json — Hook Registrations

**Files:**
- Create: `.claude/settings.json`

**Interfaces:**
- Consumed by: Claude Code — registers hooks from Task 6
- `pre-commit` registered under `PreToolUse` with `matcher: "Bash"`
- `stop` registered under `Stop`

- [ ] **Step 1: Create .claude/settings.json**

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "python3 .claude/hooks/pre-commit"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "python3 .claude/hooks/stop"
          }
        ]
      }
    ]
  }
}
```

- [ ] **Step 2: Verify valid JSON**

```bash
python3 -c "import json; json.load(open('.claude/settings.json')); print('valid')"
```

Expected output: `valid`

- [ ] **Step 3: Commit**

```bash
git add .claude/settings.json
git commit -m "feat: register pre-commit and stop hooks in settings.json"
```

---

### Task 8: docs/harness/ — Team Documentation

**Files:**
- Create: `docs/harness/overview.md`
- Create: `docs/harness/learnings.md`
- Create: `docs/harness/principles/01-hardening.md` through `10-toolkit.md` (10 files)

**Interfaces:**
- Consumed by: human team members (not AI context — these are not `@` referenced in CLAUDE.md)
- Produces: onboarding docs and principle rationale for the team

- [ ] **Step 1: Create docs/harness/overview.md**

```markdown
# Harness Overview

This project uses a Claude Code harness — a set of persistent context files, hooks, and documentation that shapes how Claude behaves when working in this codebase.

## What It Does

- **Engineering discipline**: Claude follows the 10 principles from [jdforsythe.github.io/10-principles](https://jdforsythe.github.io/10-principles/) at every session
- **Accessibility compliance**: Claude generates WCAG 2.2 AA-compliant code and completes a review checklist before any UI PR merges
- **Institutional memory**: A Stop hook prompts Claude to document mistakes; learnings accumulate in `docs/harness/learnings.md`

## File Map

| File | Who reads it | Purpose |
|---|---|---|
| `CLAUDE.md` | Claude Code | Session entry point — imports all AI-facing rules |
| `.harness/principles.md` | Claude Code | 10 engineering principles |
| `.harness/a11y/A11Y.md` | Claude Code | Accessibility rules |
| `.harness/a11y/references/` | Claude Code (selective) | Domain-specific a11y patterns |
| `.harness/a11y/REPORT.md` | Claude Code + PR reviewer | Pre-merge a11y checklist |
| `.harness/a11y/EXCEPTIONS.md` | Team | Justified deviation log |
| `.claude/settings.json` | Claude Code | Hook registrations |
| `docs/harness/` | Team | Human-readable docs (this folder) |
| `docs/harness/learnings.md` | Claude Code + team | Accumulated lessons from past mistakes |

## Updating the Harness

Re-run the installer to pull updates. Your `EXCEPTIONS.md` and `settings.json` will be protected (you'll be prompted before overwrite).

To add a project-specific rule, edit `CLAUDE.md` directly under a `## Project Rules` section.
```

- [ ] **Step 2: Create docs/harness/learnings.md**

```markdown
# Institutional Learnings

Lessons codified from agent mistakes per Principle 05 — Institutional Memory.

Each entry: what happened, why, and how to prevent it.

---

<!-- Entries added here by the Stop hook after each session -->
```

- [ ] **Step 3: Create docs/harness/principles/01-hardening.md**

```markdown
# P01 — Hardening

> "Every fuzzy LLM step that must behave identically every time must eventually be replaced by a deterministic tool."

## Why This Matters

LLMs are probabilistic. The same prompt can produce different output on different runs. When your workflow depends on consistent, verifiable output — date parsing, JSON transformation, file writing — that dependency is a risk. Tool calls (shell commands, API calls, file operations) are deterministic. They either succeed or they don't, and their output is inspectable.

## In This Project

Claude Code uses tool calls (Bash, Edit, Write, Grep) for every concrete action. The harness hooks are shell scripts with predictable, testable behavior — not prompts asking Claude to "remember to check a11y." That's Principle 10 (Toolkit) applied to Principle 01.

## Watch For

Workflows where Claude is asked to "consistently" produce formatted output — config generation, boilerplate, structured data. These are candidates for deterministic tools.
```

- [ ] **Step 4: Create docs/harness/principles/02-context-hygiene.md**

```markdown
# P02 — Context Hygiene

> "Context is your scarcest resource. Treat it like memory in an embedded system, not disk space on a server."

## Why This Matters

Claude's context window is finite and expensive. Tokens loaded into context slow inference, increase cost, and — critically — dilute attention. A 200k-token context where 80% is stale tool output is worse than a focused 10k-token context.

## In This Project

`CLAUDE.md` is kept short deliberately. Domain reference guides (`.harness/a11y/references/*.md`) are not loaded by default — Claude should reference them selectively when working in that domain. The `@` import syntax loads files when needed, not always.

## Watch For

Letting tool results accumulate in context. Pasting full file contents when a path reference would do. Starting a new session without summarizing where the previous one left off.
```

- [ ] **Step 5: Create docs/harness/principles/03-living-documentation.md**

```markdown
# P03 — Living Documentation

> "Documentation is context. Stale documentation is poisoned context."

## Why This Matters

Every document is a claim. When the claim is wrong, every reader makes wrong decisions confidently. A doc that was accurate six months ago and hasn't been touched since is a liability — especially when it's in Claude's context.

## In This Project

`docs/harness/learnings.md` must stay current — the Stop hook prompts Claude to update it, but the team must review it periodically. When a rule in `A11Y.md` is refined based on project experience, update the file in the same PR that introduces the refinement.

## Watch For

Merging a behavior change without updating the corresponding doc. Letting `learnings.md` go stale. Keeping exception entries in `EXCEPTIONS.md` past their resolution date.
```

- [ ] **Step 6: Create docs/harness/principles/04-disposable-blueprint.md**

```markdown
# P04 — Disposable Blueprint

> "Never implement without a saved, versioned plan artifact. And never fall in love with one."

## Why This Matters

A plan in Claude's working memory is invisible to everyone else and disappears when the session ends. A saved plan in `docs/superpowers/plans/` is reviewable, linkable, and survives session boundaries. Plans also expose assumptions — writing one out reveals what you don't know before you've committed to an approach.

## In This Project

Every significant implementation starts with a plan in `docs/superpowers/plans/YYYY-MM-DD-<feature>.md`, committed before any code is written. When the plan changes mid-implementation, the file is updated to reflect reality.

## Watch For

Starting to implement a task without an agreed, committed plan. Discovering mid-implementation that the approach is wrong and not updating the plan. Treating a completed plan as a contract rather than a record.
```

- [ ] **Step 7: Create docs/harness/principles/05-institutional-memory.md**

```markdown
# P05 — Institutional Memory

> "When an agent makes a mistake, don't just correct it — codify it forever."

## Why This Matters

Corrections that live only in the session transcript are lost when the session ends. The next session — or the next agent — has no access to that history and will make the same mistake. The only correction that matters permanently is one that changes what future agents read.

## In This Project

The Stop hook fires at the end of every Claude turn and asks: did any mistake or unexpected behavior occur? If yes, it should be added to `docs/harness/learnings.md`. That file is part of the persistent context system.

## Watch For

Accepting a corrected output and moving on without asking why the first attempt was wrong. Entries in `learnings.md` that are vague ("Claude got confused about X") rather than actionable ("When X, Claude will Y — prevent this by Z").
```

- [ ] **Step 8: Create docs/harness/principles/06-specialized-review.md**

```markdown
# P06 — Specialized Review

> "A generalist reviewer trends toward the median. Specialists find what generalists can't."

## Why This Matters

A prompt like "review this code" produces feedback shaped by average expectations. A focused prompt — "check only for missing aria attributes" — produces deeper, domain-specific findings. The `REPORT.md` checklist is an operationalization of this principle for accessibility.

## In This Project

Before any UI PR merges, Claude completes `REPORT.md` item by item. The pre-commit hook reminds Claude when UI files are staged. This forces a dedicated a11y review pass separate from the general code review.

## Watch For

Skipping `REPORT.md` for "small" UI changes — accessibility regressions often come from small changes (removing a label, swapping a div for a button, tweaking CSS that breaks focus visibility).
```

- [ ] **Step 9: Create docs/harness/principles/07-observability.md**

```markdown
# P07 — Observability Imperative

> "If you can't see inside your pipeline, you're trusting it on faith."

## Why This Matters

A pipeline that silently succeeds tells you nothing about why it succeeded. When something goes wrong, you have no signal — no record of what happened, no basis for diagnosis. Observability is the foundation of improvement.

## In This Project

`docs/harness/learnings.md` is the project's observability log. The Stop hook creates a natural audit boundary at every session end. Hook output is surfaced in Claude's context — not swallowed — so unexpected behavior is visible.

## Watch For

Hooks that always exit 0 with no output — they're invisible. Long stretches with no new entries in `learnings.md` — either nothing is being learned or the hook isn't prompting effectively.
```

- [ ] **Step 10: Create docs/harness/principles/08-strategic-human-gate.md**

```markdown
# P08 — Strategic Human Gate

> "Rubber-stamp approval is the single most common quality failure in multi-agent systems."

## Why This Matters

Review processes that always approve provide false safety. A developer approving a diff they haven't read is worse than no review — it implies the work was checked when it wasn't. Gates should be positioned where human judgment actually adds value: at ambiguous requirements, at architectural decisions, at PR merge.

## In This Project

Claude flags ambiguous requirements before implementing — not after. The `REPORT.md` checklist is a structured gate that forces a real review, not a "ship it" click.

## Watch For

Prompting Claude with underspecified requirements and accepting the output without reviewing against intent. Merging PRs without reading the diff. Approving a plan in a message without actually evaluating it.
```

- [ ] **Step 11: Create docs/harness/principles/09-token-economy.md**

```markdown
# P09 — Token Economy

> "Tokens are money. Most people are burning it."

## Why This Matters

Token cost compounds. A 200k-context session costs more to infer, takes longer, and produces worse results than a focused 20k-context session. Most projects spend the majority of their token budget re-reading context that hasn't changed, re-deriving decisions that were already made, and carrying stale tool output.

## In This Project

Domain reference files are loaded on demand — not always in context. Completed sessions are summarized before handoff. Plans live in files — not in the prompt — so they don't need to be restated.

## Watch For

Starting every session by re-reading all project files from scratch. Leaving large tool outputs in context after they've been acted on. Using large models for tasks a smaller model handles equally well.
```

- [ ] **Step 12: Create docs/harness/principles/10-toolkit.md**

```markdown
# P10 — Toolkit Principle

> "Knowledge without automation decays. Encode your principles into tools that enforce them automatically."

## Why This Matters

A principle that requires a human to remember to apply it will be forgotten. Rules in documentation are aspirational; rules in hooks are operational. The gap between what a team says it does and what it actually does is often explained by this gap — principles that exist only in docs.

## In This Project

- Principle 05 (Institutional Memory) is enforced by the Stop hook
- Principle 06 (Specialized Review) is enforced by the pre-commit hook reminding Claude to complete `REPORT.md`
- This harness itself is an expression of Principle 10 — the principles are encoded in tools, not just described in text

## Watch For

Identifying a repeated mistake and responding only by adding a note to a doc. The right response is a hook, a skill, or a rule in `CLAUDE.md` — something that fires automatically.
```

- [ ] **Step 13: Verify**

```bash
ls docs/harness/principles/ | wc -l
```

Expected output: `10`

- [ ] **Step 14: Commit**

```bash
git add docs/harness/
git commit -m "feat: add team documentation (overview, learnings, 10 principle docs)"
```

---

### Task 9: install.sh — Unix Installer

**Files:**
- Create: `install.sh`

**Interfaces:**
- Consumed by: curl piping into bash on target user's machine
- Reads: all harness files from raw GitHub URLs (`BASE_URL/<path>`)
- Produces: all harness files in current directory

- [ ] **Step 1: Create install.sh**

```bash
#!/usr/bin/env bash
# Claude Code Harness Installer
# Usage: curl -sSL https://raw.githubusercontent.com/<OWNER>/harness/main/install.sh | bash

set -euo pipefail

OWNER="<OWNER>"
REPO="harness"
BRANCH="main"
BASE="https://raw.githubusercontent.com/$OWNER/$REPO/$BRANCH"

# Colours
GRN='\033[0;32m'; YLW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info() { echo -e "${GRN}[harness]${NC} $1"; }
warn() { echo -e "${YLW}[harness]${NC} $1"; }
err()  { echo -e "${RED}[harness]${NC} $1" >&2; }

echo ""
echo "  Claude Code Harness"
echo "  github.com/$OWNER/$REPO"
echo ""

# Warn if not in git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  warn "Not in a git repository. Proceeding anyway."
fi

# Prompt before overwriting user-edited files; return 0 = proceed, 1 = skip
confirm_overwrite() {
  local file="$1"
  if [ -f "$file" ]; then
    warn "Existing $file found."
    printf "  Overwrite? [y/N] "
    read -r reply
    if [[ ! "$reply" =~ ^[Yy]$ ]]; then
      warn "  Skipping $file"
      return 1
    fi
  fi
  return 0
}

# Download one file, creating parent dirs
fetch() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if curl -sSfL "$BASE/$src" -o "$dst" 2>/dev/null; then
    info "  ✓ $dst"
  else
    err "  ✗ Failed: $src"
    return 1
  fi
}

# Files that always overwrite (user does not edit these)
CONTENT=(
  "CLAUDE.md"
  ".harness/principles.md"
  ".harness/a11y/A11Y.md"
  ".harness/a11y/references/forms.md"
  ".harness/a11y/references/navigation.md"
  ".harness/a11y/references/modals.md"
  ".harness/a11y/references/contrast.md"
  ".harness/a11y/references/images.md"
  ".harness/a11y/REPORT.md"
  ".claude/hooks/pre-commit"
  ".claude/hooks/stop"
  "docs/harness/overview.md"
  "docs/harness/principles/01-hardening.md"
  "docs/harness/principles/02-context-hygiene.md"
  "docs/harness/principles/03-living-documentation.md"
  "docs/harness/principles/04-disposable-blueprint.md"
  "docs/harness/principles/05-institutional-memory.md"
  "docs/harness/principles/06-specialized-review.md"
  "docs/harness/principles/07-observability.md"
  "docs/harness/principles/08-strategic-human-gate.md"
  "docs/harness/principles/09-token-economy.md"
  "docs/harness/principles/10-toolkit.md"
)

# Files that prompt before overwrite (user may have edited these)
PROTECTED=(
  ".harness/a11y/EXCEPTIONS.md"
  ".claude/settings.json"
)

for f in "${CONTENT[@]}";    do fetch "$f" "$f"; done
for f in "${PROTECTED[@]}";  do confirm_overwrite "$f" && fetch "$f" "$f" || true; done

# Make hooks executable
chmod +x .claude/hooks/pre-commit .claude/hooks/stop
info "  ✓ hooks marked executable"

# Seed learnings file if absent
if [ ! -f "docs/harness/learnings.md" ]; then
  mkdir -p docs/harness
  cat > docs/harness/learnings.md << 'EOF'
# Institutional Learnings

Lessons codified from agent mistakes per Principle 05 — Institutional Memory.

---

<!-- Entries added here by the Stop hook after each session -->
EOF
  info "  ✓ docs/harness/learnings.md (created)"
fi

echo ""
info "Harness installed. Open Claude Code in this directory to activate."
echo ""
```

- [ ] **Step 2: Make executable**

```bash
chmod +x install.sh
```

- [ ] **Step 3: Smoke-test installer in a temp directory (dry run — uses local files, not GitHub)**

```bash
TMPDIR=$(mktemp -d)
# Copy all harness files to a local server simulation isn't needed for a dry run.
# Instead, verify the script has no syntax errors:
bash -n install.sh
```

Expected: no output (syntax is valid)

- [ ] **Step 4: Commit**

```bash
git add install.sh
git commit -m "feat: add install.sh (curl-pipeable Unix installer)"
```

---

### Task 10: install.ps1 — Windows PowerShell Installer

**Files:**
- Create: `install.ps1`

**Interfaces:**
- Consumed by: PowerShell 5+ via `irm <url> | iex`
- Same logic as `install.sh` but PowerShell syntax; uses `Invoke-WebRequest`

- [ ] **Step 1: Create install.ps1**

```powershell
# Claude Code Harness Installer (Windows PowerShell)
# Usage: irm https://raw.githubusercontent.com/<OWNER>/harness/main/install.ps1 | iex

$ErrorActionPreference = "Stop"

$Owner  = "<OWNER>"
$Repo   = "harness"
$Branch = "main"
$Base   = "https://raw.githubusercontent.com/$Owner/$Repo/$Branch"

function Write-Info { param($Msg) Write-Host "[harness] $Msg" -ForegroundColor Green  }
function Write-Warn { param($Msg) Write-Host "[harness] $Msg" -ForegroundColor Yellow }
function Write-Err  { param($Msg) Write-Host "[harness] $Msg" -ForegroundColor Red    }

Write-Host ""
Write-Host "  Claude Code Harness"
Write-Host "  github.com/$Owner/$Repo"
Write-Host ""

# Warn if not in git repo
try   { git rev-parse --git-dir 2>$null | Out-Null }
catch { Write-Warn "Not in a git repository. Proceeding anyway." }

function Confirm-Overwrite {
  param($File)
  if (Test-Path $File) {
    Write-Warn "Existing $File found."
    $reply = Read-Host "  Overwrite? [y/N]"
    if ($reply -notmatch '^[Yy]$') {
      Write-Warn "  Skipping $File"
      return $false
    }
  }
  return $true
}

function Get-HarnessFile {
  param($Src, $Dst)
  $dir = Split-Path $Dst -Parent
  if ($dir -and -not (Test-Path $dir)) {
    New-Item -ItemType Directory -Force $dir | Out-Null
  }
  try {
    Invoke-WebRequest -Uri "$Base/$Src" -OutFile $Dst -UseBasicParsing
    Write-Info "  + $Dst"
  } catch {
    Write-Err "  x Failed: $Src"
    throw
  }
}

$ContentFiles = @(
  "CLAUDE.md",
  ".harness/principles.md",
  ".harness/a11y/A11Y.md",
  ".harness/a11y/references/forms.md",
  ".harness/a11y/references/navigation.md",
  ".harness/a11y/references/modals.md",
  ".harness/a11y/references/contrast.md",
  ".harness/a11y/references/images.md",
  ".harness/a11y/REPORT.md",
  ".claude/hooks/pre-commit",
  ".claude/hooks/stop",
  "docs/harness/overview.md",
  "docs/harness/principles/01-hardening.md",
  "docs/harness/principles/02-context-hygiene.md",
  "docs/harness/principles/03-living-documentation.md",
  "docs/harness/principles/04-disposable-blueprint.md",
  "docs/harness/principles/05-institutional-memory.md",
  "docs/harness/principles/06-specialized-review.md",
  "docs/harness/principles/07-observability.md",
  "docs/harness/principles/08-strategic-human-gate.md",
  "docs/harness/principles/09-token-economy.md",
  "docs/harness/principles/10-toolkit.md"
)

$ProtectedFiles = @(
  ".harness/a11y/EXCEPTIONS.md",
  ".claude/settings.json"
)

foreach ($f in $ContentFiles)   { Get-HarnessFile $f $f }
foreach ($f in $ProtectedFiles) { if (Confirm-Overwrite $f) { Get-HarnessFile $f $f } }

# Seed learnings file if absent
if (-not (Test-Path "docs/harness/learnings.md")) {
  New-Item -ItemType Directory -Force "docs/harness" | Out-Null
  @"
# Institutional Learnings

Lessons codified from agent mistakes per Principle 05 — Institutional Memory.

---

<!-- Entries added here by the Stop hook after each session -->
"@ | Set-Content "docs/harness/learnings.md" -Encoding utf8
  Write-Info "  + docs/harness/learnings.md (created)"
}

Write-Host ""
Write-Info "Harness installed. Open Claude Code in this directory to activate."
Write-Host ""
```

- [ ] **Step 2: Syntax-check install.ps1**

```powershell
$errors = $null
[System.Management.Automation.Language.Parser]::ParseFile("install.ps1", [ref]$null, [ref]$errors)
$errors.Count
```

Expected output: `0`

- [ ] **Step 3: Commit**

```bash
git add install.ps1
git commit -m "feat: add install.ps1 (PowerShell Windows installer)"
```

---

### Task 11: README.md — Repository Documentation

**Files:**
- Create: `README.md`

**Interfaces:**
- Consumed by: GitHub repo visitors; users finding the install command
- Produces: install one-liners, file map, requirements, customization notes

- [ ] **Step 1: Create README.md**

```markdown
# Claude Code Harness

A project-level harness for [Claude Code](https://claude.ai/code) that encodes:

- **10 engineering principles** from [jdforsythe.github.io/10-principles](https://jdforsythe.github.io/10-principles/)
- **WCAG 2.2 AA accessibility rules** modeled on [fecarrico/A11Y.md](https://github.com/fecarrico/A11Y.md)

Drop it into any project with one command.

---

## Install

**Linux / macOS / WSL:**
```bash
curl -sSL https://raw.githubusercontent.com/<OWNER>/harness/main/install.sh | bash
```

**Windows (PowerShell 5+):**
```powershell
irm https://raw.githubusercontent.com/<OWNER>/harness/main/install.ps1 | iex
```

Run from the root of your project. Git is recommended but not required.

---

## What Gets Installed

| File | Purpose |
|---|---|
| `CLAUDE.md` | Session entry point — Claude reads this at every session start |
| `.harness/principles.md` | 10 engineering principles with examples |
| `.harness/a11y/A11Y.md` | Accessibility rules matrix (WCAG 2.2 AA) |
| `.harness/a11y/references/` | Domain guides: forms, navigation, modals, contrast, images |
| `.harness/a11y/REPORT.md` | Pre-merge accessibility checklist template |
| `.harness/a11y/EXCEPTIONS.md` | Exception log for justified rule deviations |
| `.claude/settings.json` | Hook event registrations |
| `.claude/hooks/pre-commit` | Reminds Claude to complete `REPORT.md` before UI commits |
| `.claude/hooks/stop` | Prompts institutional memory capture at end of each turn |
| `docs/harness/overview.md` | Team-readable: what the harness is and why |
| `docs/harness/principles/` | Team-readable rationale for each of the 10 principles |
| `docs/harness/learnings.md` | Accumulated lessons from past mistakes (you fill this in) |

---

## How It Works

`CLAUDE.md` is the entry point. Claude Code reads it at the start of every session in this project. It imports `.harness/principles.md` and `.harness/a11y/A11Y.md` via `@` references, so Claude has the full rule set in context without a bloated `CLAUDE.md`.

Two hooks run automatically:
- **pre-commit** (`PreToolUse / Bash`): when Claude stages UI files for a git commit, it's reminded to complete `REPORT.md` first
- **stop** (`Stop`): at the end of every turn, Claude is prompted to document any mistakes in `docs/harness/learnings.md`

---

## Updating

Re-run the installer. Content files update automatically. `EXCEPTIONS.md` and `settings.json` prompt before overwriting (you may have edited them).

---

## Customising

**Add project-specific rules:**
Edit `CLAUDE.md` and add a `## Project Rules` section beneath the existing imports.

**Adjust hooks:**
Edit `.claude/hooks/pre-commit` or `.claude/hooks/stop` directly. They're plain Python 3 scripts.

**Record learnings:**
The Stop hook will prompt Claude, but you can also add entries to `docs/harness/learnings.md` manually. That file is part of Claude's persistent context.

**Log exceptions:**
When a rule in `A11Y.md` can't be met, add an entry to `.harness/a11y/EXCEPTIONS.md` before merging.

---

## Requirements

- [Claude Code](https://claude.ai/code) CLI
- Python 3 (for hooks)
- curl (Linux/macOS install) or PowerShell 5+ (Windows install)
- Git (recommended — the harness is designed to be version-controlled with your project)

---

## License

MIT
```

- [ ] **Step 2: Verify install one-liners are present**

```bash
grep -c "curl -sSL" README.md && grep -c "irm https" README.md
```

Expected: each returns `1`

- [ ] **Step 3: Final commit**

```bash
git add README.md
git commit -m "feat: add README.md with install one-liners and file map"
```

---

## Self-Review Checklist

- [x] **Spec coverage**: All files from the spec structure are covered across Tasks 1–11
- [x] **CLAUDE.md** — Task 1
- [x] **.harness/principles.md (10 principles)** — Task 2
- [x] **.harness/a11y/A11Y.md** — Task 3
- [x] **.harness/a11y/references/ (5 files)** — Task 4
- [x] **.harness/a11y/REPORT.md + EXCEPTIONS.md** — Task 5
- [x] **.claude/hooks/pre-commit + stop** — Task 6
- [x] **.claude/settings.json** — Task 7
- [x] **docs/harness/ (overview + 10 principle docs + learnings)** — Task 8
- [x] **install.sh** — Task 9
- [x] **install.ps1** — Task 10
- [x] **README.md** — Task 11
- [x] **No placeholders** — all file content is complete and literal
- [x] **Type consistency** — no cross-task naming mismatches (all file paths match between installer arrays and creation steps)
- [x] **Hook event names** — `PreToolUse` and `Stop` (correct Claude Code hook events per spec)
- [x] **Protected files** — `EXCEPTIONS.md` and `settings.json` prompt before overwrite in both installers; `CLAUDE.md` overwrites silently (spec changed from original; consistent with "update behavior" section)
