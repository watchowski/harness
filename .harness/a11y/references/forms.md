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
