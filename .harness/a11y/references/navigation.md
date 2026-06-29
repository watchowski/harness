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
