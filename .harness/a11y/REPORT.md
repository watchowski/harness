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
- [ ] No keyboard traps; users can Tab away from any element

## Focus Management [WCAG 2.4.3, 2.4.7, 2.4.11]

- [ ] Focus order is logical (left-to-right, top-to-bottom)
- [ ] Focus is always visible (no `outline: none` without custom replacement)
- [ ] Custom focus indicators have 3:1 contrast and 2px offset
- [ ] Modals trap focus when open and return focus to trigger on close
- [ ] Dynamic content does not steal focus inappropriately

## Forms [WCAG 1.3.1, 3.3.1, 3.3.2]

- [ ] All inputs have programmatically associated labels (via `for`/`id` or `aria-labelledby`)
- [ ] Placeholder text is not used as the only label
- [ ] Required fields marked visually and via `required` / `aria-required`
- [ ] Errors associated with fields via `aria-describedby`
- [ ] Errors announced via `aria-live` or focus movement
- [ ] Autocomplete attributes used for personal data fields

## Modals [WCAG 2.1.1, 4.1.2]

- [ ] Modal has `role="dialog"` and `aria-modal="true"`
- [ ] Modal has accessible name via `aria-labelledby` or `aria-label`
- [ ] Escape key closes modal
- [ ] Background is inert while modal is open (`inert` or `aria-hidden="true"`)
- [ ] Focus trapped inside modal (Tab cycles only within modal)
- [ ] Focus returns to trigger element when modal closes

## Images [WCAG 1.1.1]

- [ ] Informative images have descriptive alt text
- [ ] Decorative images have `alt=""`
- [ ] Complex images have long descriptions or `aria-describedby`
- [ ] Icon-only buttons have `aria-label`
- [ ] SVG images have `role="img"` and accessible label

## Color and Contrast [WCAG 1.4.1, 1.4.3, 1.4.11]

- [ ] Normal text meets 4.5:1 contrast
- [ ] Large text meets 3:1 contrast
- [ ] UI components meet 3:1 contrast
- [ ] Information not conveyed by color alone (pair with icon/text/pattern)
- [ ] Placeholder text meets 4.5:1 contrast

## Navigation [WCAG 1.3.1, 2.4.1]

- [ ] Skip link present as first focusable element
- [ ] Landmark regions used correctly (`<header>`, `<nav>`, `<main>`, `<footer>`)
- [ ] Heading hierarchy is logical (one `<h1>`, no skipped levels)
- [ ] Language attribute set on `<html>` element
- [ ] Dynamic page title updates in single-page applications

## Status Messages [WCAG 4.1.3]

- [ ] Success/error messages announced via `aria-live` regions
- [ ] Status updates use `aria-live="polite"`
- [ ] Critical alerts use `aria-live="assertive"`
- [ ] Loading states announced appropriately

---

## Issues Found

<!-- List any a11y issues discovered and how they were resolved, or "None" -->

## Exceptions

<!-- List any deviations from A11Y.md rules and add them to EXCEPTIONS.md, or "None" -->