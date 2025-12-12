# Administrate Filterable - Testing Checklist

## Test Environment Setup

- [ ] Rails 8 app with Hotwire/Turbo enabled
- [ ] PostgreSQL database
- [ ] Administrate installed
- [ ] Test model with various field types:
  - String fields
  - Integer fields
  - Enum fields
  - Date fields
  - DateTime fields

---

## 1. Filter Panel Toggle

- [ ] **TC-01:** Click filter button → panel slides in from right
- [ ] **TC-02:** Click filter button again → panel slides out
- [ ] **TC-03:** Click overlay (dark background) → panel closes
- [ ] **TC-04:** Press ESC key → panel closes (if implemented)
- [ ] **TC-05:** Panel state doesn't persist after page reload
- [ ] **TC-06:** CSS transitions are smooth (0.5s cubic-bezier)

---

## 2. String Field Filtering

- [ ] **TC-07:** Enter "test" in string field → filters with LIKE '%test%'
- [ ] **TC-08:** Enter empty string → no filter param added
- [ ] **TC-09:** Enter "test" → apply → value persists in input
- [ ] **TC-10:** Enter special chars like `%`, `_`, `'` → properly escaped
- [ ] **TC-11:** Enter Unicode/emoji → works correctly
- [ ] **TC-12:** Enter very long string (1000+ chars) → handles gracefully

---

## 3. Integer/Enum Field Filtering (Select Dropdown)

**Note:** Only applies if using select dropdown instead of checkboxes

- [ ] **TC-13:** Select option → filters with exact match (=)
- [ ] **TC-14:** Select option → apply → value persists
- [ ] **TC-15:** Leave blank/default → no filter param added
- [ ] **TC-16:** Select "0" value → filters correctly (not treated as blank)

---

## 4. Enum Field Filtering (Multi-Checkbox)

- [ ] **TC-17:** Check one checkbox → filters with exact match
- [ ] **TC-18:** Check two checkboxes → filters with IN query (OR logic)
- [ ] **TC-19:** Check all checkboxes → filters with IN query
- [ ] **TC-20:** Uncheck all → no filter param added
- [ ] **TC-21:** Check "pending" → apply → "pending" stays checked
- [ ] **TC-22:** Check "pending" + "completed" → both stay checked
- [ ] **TC-23:** URL shows `?status=pending&status=completed` format
- [ ] **TC-24:** Checkbox labels are fully visible (not cut off)
- [ ] **TC-25:** Long enum value wraps properly in UI
- [ ] **TC-26:** Clicking label checks/unchecks checkbox

---

## 5. Date Range Filtering

- [ ] **TC-27:** Set only "from" date → filters with >= query
- [ ] **TC-28:** Set only "to" date → filters with <= query
- [ ] **TC-29:** Set both dates → filters with range (>= AND <=)
- [ ] **TC-30:** Leave both dates empty → no filter param added
- [ ] **TC-31:** Set "from" = "to" (same date) → filters single day
- [ ] **TC-32:** Set "from" > "to" → handles gracefully (backend validates?)
- [ ] **TC-33:** Date values persist after filtering
- [ ] **TC-34:** Date inputs render side-by-side (flex layout)
- [ ] **TC-35:** Date inputs are equal width (50/50 split)
- [ ] **TC-36:** Date placeholders show "From" and "To"
- [ ] **TC-37:** Invalid date entry → browser handles validation
- [ ] **TC-38:** Label shows humanized field name (e.g., "Created at")

---

## 6. Combined Filters

- [ ] **TC-39:** String + enum checkbox → both filters applied (AND)
- [ ] **TC-40:** Enum checkbox + date range → both applied
- [ ] **TC-41:** String + enum + date → all three applied
- [ ] **TC-42:** Multiple enum checkboxes + text → works correctly
- [ ] **TC-43:** Existing page param preserved (e.g., `?page=2`)
- [ ] **TC-44:** Existing sort param preserved (e.g., `?order=name`)

---

## 7. Apply Filter Button

- [ ] **TC-45:** Click "Apply Filter" → submits form
- [ ] **TC-46:** URL updates with query params
- [ ] **TC-47:** Page reloads with filtered results
- [ ] **TC-48:** Panel closes after applying (optional behavior)
- [ ] **TC-49:** Rapid clicking doesn't cause duplicate requests
- [ ] **TC-50:** Works with Turbo (uses Turbo.visit if implemented)
- [ ] **TC-51:** Works without Turbo (full page reload fallback)

---

## 8. Clear Filter Button

- [ ] **TC-52:** Click "Clear Filter" → removes all filter params
- [ ] **TC-53:** Preserves non-filter params (page, order, etc.)
- [ ] **TC-54:** Unchecks all checkboxes
- [ ] **TC-55:** Clears all text inputs
- [ ] **TC-56:** Clears all date inputs
- [ ] **TC-57:** Resets select dropdowns to default
- [ ] **TC-58:** Page reloads showing unfiltered results
- [ ] **TC-59:** URL shows clean path (no filter query params)

---

## 9. Turbo Navigation

- [ ] **TC-60:** Navigate to page → filter button works
- [ ] **TC-61:** Click link (Turbo) → filter button works on new page
- [ ] **TC-62:** Browser back → filter values restored
- [ ] **TC-63:** Browser forward → filter values restored
- [ ] **TC-64:** Apply filter → navigate away → back button → filters persist
- [ ] **TC-65:** No duplicate event listeners after multiple navigations
- [ ] **TC-66:** Panel state resets after navigation (doesn't stay open)
- [ ] **TC-67:** Works on initial page load (DOMContentLoaded)
- [ ] **TC-68:** Works on Turbo load (turbo:load event)
- [ ] **TC-69:** No console errors on any navigation

---

## 10. URL State Management

- [ ] **TC-70:** Load page with `?status=pending` → checkbox checked
- [ ] **TC-71:** Load page with `?status=pending&status=completed` → both checked
- [ ] **TC-72:** Load page with `?created_at_from=2024-01-01` → date populated
- [ ] **TC-73:** Load page with `?name=test` → text input populated
- [ ] **TC-74:** Manually edit URL params → form updates on load
- [ ] **TC-75:** URL-encoded chars (%20, %2B, etc.) decode properly
- [ ] **TC-76:** Copy URL → paste in new tab → filters identical

---

## 11. Edge Cases

- [ ] **TC-77:** Page has no filter form → no JavaScript errors
- [ ] **TC-78:** Dashboard has FILTER_ATTRIBUTES = [] → no filters shown
- [ ] **TC-79:** Field name contains underscore (e.g., `user_id`) → works
- [ ] **TC-80:** Field named `sent_to` (not a date) → doesn't get date range UI
- [ ] **TC-81:** Field named `created_at_backup` → doesn't conflict with `created_at`
- [ ] **TC-82:** Very long filter value (10000+ chars) → handles gracefully
- [ ] **TC-83:** Filter value contains `&`, `=`, `?` → properly encoded
- [ ] **TC-84:** Filter value contains newlines → handled correctly
- [ ] **TC-85:** Empty enum options array → no checkboxes rendered

---

## 12. Backend Integration

- [ ] **TC-86:** String field generates SQL: `WHERE name LIKE '%value%'`
- [ ] **TC-87:** Integer field generates SQL: `WHERE id = 123`
- [ ] **TC-88:** Enum array generates SQL: `WHERE status IN ('pending', 'completed')`
- [ ] **TC-89:** Date range generates SQL: `WHERE created_at >= ? AND created_at <= ?`
- [ ] **TC-90:** Only "from" date generates: `WHERE created_at >= ?`
- [ ] **TC-91:** Only "to" date generates: `WHERE created_at <= ?`
- [ ] **TC-92:** No SQL injection possible with any input
- [ ] **TC-93:** ActiveRecord sanitization works correctly
- [ ] **TC-94:** PostgreSQL-specific syntax works (not MySQL-only)
- [ ] **TC-95:** Results are actually filtered (not just URL change)

---

## 13. Layout & UI

- [ ] **TC-96:** Text inputs are 100% width of panel
- [ ] **TC-97:** Select dropdowns are 100% width of panel
- [ ] **TC-98:** Date range inputs split 50/50 with gap
- [ ] **TC-99:** Date inputs don't overflow container
- [ ] **TC-100:** Checkbox labels fully visible (not cut to one letter!)
- [ ] **TC-101:** Long enum values wrap to multiple lines
- [ ] **TC-102:** Filter panel scrollable when content overflows
- [ ] **TC-103:** Panel looks good on mobile (< 460px wide)
- [ ] **TC-104:** Panel looks good on tablet
- [ ] **TC-105:** Panel looks good on desktop
- [ ] **TC-106:** Filter button visible and clickable
- [ ] **TC-107:** Overlay covers entire viewport
- [ ] **TC-108:** Buttons ("Clear", "Apply") are styled correctly

---

## 14. Form Field Population from URL

- [ ] **TC-109:** Text input populates from URL on page load
- [ ] **TC-110:** Select dropdown populates from URL
- [ ] **TC-111:** Single checkbox populates from URL
- [ ] **TC-112:** Multiple checkboxes populate from URL
- [ ] **TC-113:** Date "from" input populates from URL
- [ ] **TC-114:** Date "to" input populates from URL
- [ ] **TC-115:** Radio buttons populate from URL (if used)
- [ ] **TC-116:** Selectize field populates if library present
- [ ] **TC-117:** Unknown query param doesn't break form population

---

## 15. Data Integrity

- [ ] **TC-118:** Params format is clean: `{status: ["pending", "completed"]}`
- [ ] **TC-119:** No mangled params like `status[` => `][]`
- [ ] **TC-120:** Empty strings not sent as filter values
- [ ] **TC-121:** Blank checkbox doesn't send empty array
- [ ] **TC-122:** Date format consistent (YYYY-MM-DD)
- [ ] **TC-123:** Timezone handling doesn't cause date shifts
- [ ] **TC-124:** NULL values handled correctly
- [ ] **TC-125:** Boolean values (if any) work correctly

---

## 16. Cross-Browser Testing

- [ ] **TC-126:** Chrome (latest) - all features work
- [ ] **TC-127:** Firefox (latest) - all features work
- [ ] **TC-128:** Safari (latest) - all features work
- [ ] **TC-129:** Edge (latest) - all features work
- [ ] **TC-130:** Mobile Safari - all features work
- [ ] **TC-131:** Mobile Chrome - all features work

---

## 17. Performance

- [ ] **TC-132:** Panel opens/closes smoothly (no jank)
- [ ] **TC-133:** Form population is fast (< 100ms)
- [ ] **TC-134:** No memory leaks after multiple navigations
- [ ] **TC-135:** Large number of checkboxes (50+) performs well
- [ ] **TC-136:** Page load time not impacted by filter JS

---

## 18. Accessibility (Optional but Recommended)

- [ ] **TC-137:** Filter button has proper ARIA label
- [ ] **TC-138:** Panel has proper ARIA role
- [ ] **TC-139:** Keyboard navigation works (Tab, Enter, Esc)
- [ ] **TC-140:** Screen reader announces panel state
- [ ] **TC-141:** Focus management is logical
- [ ] **TC-142:** Color contrast meets WCAG standards

---

## Critical Path (Must All Pass)

**End-to-End Happy Path:**

1. ✅ Load admin index page
2. ✅ Click filter button → panel opens
3. ✅ Check 2 enum checkboxes (e.g., "pending", "completed")
4. ✅ Set date range (from: 2024-01-01, to: 2024-12-31)
5. ✅ Enter text in string field (e.g., "test")
6. ✅ Click "Apply Filter"
7. ✅ See filtered results
8. ✅ Verify URL has all query params
9. ✅ All 2 checkboxes still checked
10. ✅ Date range values still populated
11. ✅ Text input still has "test"
12. ✅ Click "Clear Filter"
13. ✅ All filters removed
14. ✅ Page shows all unfiltered records
15. ✅ Navigate to another page (Turbo)
16. ✅ Navigate back
17. ✅ Filter button still works

---

## Regression Testing

After Stimulus refactor:

- [ ] **RT-01:** Re-run all 142 test cases above
- [ ] **RT-02:** No new console errors introduced
- [ ] **RT-03:** No performance degradation
- [ ] **RT-04:** All existing apps still work (if backwards compatible)

---

## Test Environment Matrix

| Rails Version | Ruby Version | Turbo Version | Browser | Status |
|---------------|--------------|---------------|---------|--------|
| 8.0           | 3.3          | Latest        | Chrome  | ⬜     |
| 8.0           | 3.3          | Latest        | Firefox | ⬜     |
| 8.0           | 3.3          | Latest        | Safari  | ⬜     |
| 7.1           | 3.2          | Latest        | Chrome  | ⬜     |
| 7.0           | 3.1          | Latest        | Chrome  | ⬜     |

---

## Bug Report Template

When a test fails, document it:

```markdown
**Test Case:** TC-XXX
**Expected:** [what should happen]
**Actual:** [what actually happened]
**Steps to Reproduce:**
1.
2.
3.

**Environment:**
- Rails: X.X.X
- Ruby: X.X.X
- Browser: XXX
- Turbo: X.X.X

**Screenshots/Logs:**
[attach if relevant]

**Severity:** Critical / High / Medium / Low
```

---

## Sign-Off

- [ ] All critical path tests pass
- [ ] No P0/P1 bugs remaining
- [ ] Performance is acceptable
- [ ] Code reviewed
- [ ] Documentation updated
- [ ] Ready for release

**Tested by:** _________________
**Date:** _________________
**Version:** _________________
