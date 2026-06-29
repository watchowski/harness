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
