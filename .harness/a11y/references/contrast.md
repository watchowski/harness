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
