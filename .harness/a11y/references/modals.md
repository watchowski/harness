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
