# Administrate Filterable - Stimulus Refactoring Plan

## Current State

The gem currently uses vanilla JavaScript with manual event listeners and DOM manipulation. While functional, it has several issues:

- Global scope pollution
- Repetitive DOM queries
- Manual event handling not optimized for Turbo
- Mixed concerns (form handling, URL manipulation, field population)
- No proper module structure
- Difficult to test

## Goals

1. **Modernize with Stimulus** - Leverage Hotwire/Stimulus for cleaner, more maintainable code
2. **Improve testability** - Separate concerns and make code easier to unit test
3. **Better Turbo integration** - Use Stimulus lifecycle hooks instead of manual event listeners
4. **Cleaner architecture** - Proper separation of concerns

## Proposed Architecture

### Stimulus Controller Structure

```javascript
// controllers/administrate_filterable_controller.js

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "panel",
    "overlay",
    "form",
    "toggleButton",
    "clearButton",
    "applyButton"
  ]

  // Lifecycle
  connect() { }
  disconnect() { }

  // Actions
  toggle(event) { }
  close(event) { }
  apply(event) { }
  clear(event) { }

  // Private methods
  #populateFromUrl() { }
  #buildFilterUrl() { }
  #populateCheckboxes(name, values) { }
  #populateDateRange(name, values) { }
  #populateField(field, value) { }
  #getFormData() { }
  #clearAllFields() { }
}
```

### Benefits

1. **Automatic lifecycle management** - Stimulus handles connect/disconnect
2. **Target system** - No more `getElementsByClassName()[0]`
3. **Action binding** - Declarative event handling in HTML
4. **Scoped behavior** - Multiple filter panels on same page (future-proof)
5. **Better debugging** - Stimulus DevTools support
6. **Type safety** - Can add TypeScript later

### File Structure

```
app/
├── assets/
│   ├── javascripts/
│   │   └── administrate_filterable/
│   │       ├── application.js (registers controller)
│   │       └── controllers/
│   │           └── filter_controller.js
│   └── stylesheets/
│       └── administrate_filterable/
│           └── application.css
└── views/
    └── admin/
        └── application/
            ├── _index_filter.html.erb (updated with data-controller)
            └── filters/
                ├── _date_range.html.erb
                ├── _select.html.erb
                └── _default.html.erb
```

## Implementation Plan

### Phase 1: Setup
- [ ] Add Stimulus as dependency (or document peer dependency)
- [ ] Create controller file structure
- [ ] Update application.js to register Stimulus controller
- [ ] Add data-controller to filter panel HTML

### Phase 2: Core Functionality
- [ ] Implement toggle/close actions
- [ ] Implement apply filter action
- [ ] Implement clear filter action
- [ ] Move URL building logic to controller

### Phase 3: Form Population
- [ ] Extract form population logic
- [ ] Handle checkboxes (single and multiple values)
- [ ] Handle date ranges
- [ ] Handle text inputs
- [ ] Handle select dropdowns
- [ ] Handle Selectize integration

### Phase 4: Cleanup
- [ ] Remove old vanilla JS code
- [ ] Update documentation
- [ ] Add inline code comments
- [ ] Test with Turbo navigation

### Phase 5: Polish
- [ ] Add error handling
- [ ] Add loading states (optional)
- [ ] Consider accessibility improvements
- [ ] Performance optimization

## HTML Changes Required

### Current
```erb
<a href="#administrate-filterable" class="administrate-filterable__toggle-button">
```

### Proposed
```erb
<div data-controller="administrate-filterable">
  <button type="button"
          data-administrate-filterable-target="toggleButton"
          data-action="administrate-filterable#toggle">
  </button>

  <div data-administrate-filterable-target="panel">
    <form data-administrate-filterable-target="form"
          data-action="submit->administrate-filterable#apply">
      <!-- form fields -->

      <button type="button"
              data-action="administrate-filterable#clear">
        Clear Filter
      </button>
      <button type="submit">Apply Filter</button>
    </form>
  </div>

  <div data-administrate-filterable-target="overlay"
       data-action="click->administrate-filterable#close">
  </div>
</div>
```

## Backwards Compatibility

**Breaking Changes:**
- Requires Stimulus.js to be available
- HTML structure changes (data attributes)
- May require app to import Stimulus if not already using it

**Migration Path:**
1. Version bump to 1.0.0 (breaking change)
2. Document Stimulus requirement in README
3. Provide migration guide
4. Consider keeping vanilla JS version in v0.x branch for legacy apps

## Testing Strategy

### Manual Testing Checklist
See TESTING_CHECKLIST.md for full list (~70 test cases)

### Automated Testing (Future)
- Consider adding JavaScript tests with Jest
- Consider adding integration tests with Capybara + Cuprite
- Add to CI pipeline

## Documentation Updates

### README.md
- [ ] Add Stimulus dependency requirement
- [ ] Update installation instructions
- [ ] Add note about Hotwire/Turbo compatibility
- [ ] Update usage examples

### CHANGELOG.md
- [ ] Document breaking changes
- [ ] Document new features
- [ ] Migration guide

## Rollout Plan

1. **Create feature branch** `feature/stimulus-refactor`
2. **Implement in stages** (as outlined above)
3. **Test thoroughly** using manual test cases
4. **Get user feedback** (maybe beta release?)
5. **Merge to main** when stable
6. **Release v1.0.0**

## Alternative: Hybrid Approach

If we want to maintain backwards compatibility:

1. Keep vanilla JS as fallback
2. Auto-detect if Stimulus is available
3. Use Stimulus if present, vanilla JS if not
4. More complex but safer migration

```javascript
if (typeof Stimulus !== 'undefined') {
  // Use Stimulus controller
} else {
  // Fall back to vanilla JS
}
```

## Questions to Consider

1. Should we make Stimulus optional or required?
2. Do we want to support apps without Stimulus?
3. Should this be v1.0.0 or v2.0.0?
4. Do we want to add TypeScript?
5. Should we add automated tests before refactoring?

## Timeline Estimate

- **Phase 1 (Setup):** 1-2 hours
- **Phase 2 (Core):** 3-4 hours
- **Phase 3 (Form Population):** 2-3 hours
- **Phase 4 (Cleanup):** 1-2 hours
- **Phase 5 (Polish):** 2-3 hours
- **Testing:** 2-4 hours
- **Documentation:** 1-2 hours

**Total:** ~12-20 hours of focused work

## Success Criteria

- [ ] All existing functionality works
- [ ] All test cases pass
- [ ] Code is cleaner and more maintainable
- [ ] No performance regressions
- [ ] Documentation is updated
- [ ] Turbo navigation works perfectly
- [ ] No console errors
- [ ] Works in all supported browsers
