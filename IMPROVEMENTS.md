# AI Adoption Assessment Wizard - Recommended Improvements

## 1. Architecture: Split the Monolithic File

**Current state:** The entire application lives in a single 4,930-line `index.html` file containing HTML, CSS, and JavaScript.

**Problem:** This makes the codebase difficult to navigate, maintain, and collaborate on. Any change risks unintended side-effects in unrelated sections.

**Recommendation:**
- Extract CSS into a separate `styles.css` (or split further: `base.css`, `components.css`, `steps.css`)
- Extract JavaScript into `app.js` or split by concern (`state.js`, `render.js`, `export.js`, `validation.js`)
- Keep the HTML template lean with only markup
- Consider a lightweight bundler (e.g., Vite) for development convenience while still producing a single deployable file if needed

---

## 2. State Management: Replace Global Variables

**Current state:** 20+ global `let` variables manage all application state (`index.html:2622-2654`):
```js
let currentStep = 1;
let accountName = '';
let selectedRoles = new Set();
let selectedTools = {};
// ... 16 more
```

**Problem:** Any function can mutate any state at any time. There's no single source of truth, no change tracking, and it's easy to introduce inconsistencies between the state and the DOM.

**Recommendation:**
- Consolidate all state into a single object (e.g., `const state = { currentStep: 1, accountName: '', ... }`)
- Create getter/setter functions or a simple reactive store pattern so state changes trigger re-renders predictably
- This also simplifies `saveProgress()` and `loadProgress()` since you serialize/deserialize one object

---

## 3. Step Ordering: Eliminate the Confusing Remapping

**Current state:** Steps are defined as `step0` through `step9` in HTML, but displayed in a non-sequential order (step 5 shows as "Step 1", step 6 as "Step 2", step 1 as "Step 3", etc.). Navigation logic must constantly translate between internal IDs and display order.

**Problem:** This indirection makes the code fragile and confusing. Adding or reordering steps requires updating multiple mapping arrays and is error-prone.

**Recommendation:**
- Rename steps so the internal order matches the display order (step 0 = Welcome, step 1 = first displayed step, etc.)
- Use a single ordered array like `const stepFlow = ['welcome', 'engagement', 'client-landscape', 'roles', ...]` and drive all navigation from it
- This eliminates the need for the current step-display remapping logic

---

## 4. Accessibility (a11y)

**Current state:** Some ARIA attributes exist (`role="alert"` on validation errors), but coverage is incomplete.

**Problems identified:**
- Interactive elements built with `<div>` instead of `<button>` (e.g., compliance chips, option cards, role cards, use case cards) lack keyboard focus, `role="button"`, and `aria-pressed`/`aria-selected` attributes
- No skip-to-content link
- Color contrast may not meet WCAG AA in some areas (e.g., light gray text `#9ca3af` on white backgrounds)
- Form inputs lack associated `<label>` elements in several places
- Progress bar lacks `aria-valuenow`/`aria-valuemax`

**Recommendation:**
- Use semantic HTML (`<button>`, `<fieldset>`, `<legend>`) for interactive elements
- Add `aria-label`, `aria-selected`, and keyboard event handlers to all clickable cards
- Run an automated audit with Lighthouse or axe-core and address findings
- Ensure all interactive elements are reachable and operable via keyboard alone

---

## 5. Mobile Responsiveness

**Current state:** There is a viewport meta tag, but no `@media` queries or responsive breakpoints in the CSS.

**Problem:** On narrow screens (phones, small tablets), the multi-column layouts (use case columns, option card grids, role-tool matrix table) will overflow or become unusable.

**Recommendation:**
- Add responsive breakpoints (e.g., `max-width: 768px`) to stack columns vertically
- Make the role-tool matrix horizontally scrollable on small screens
- Test with Chrome DevTools device emulation at common breakpoints (375px, 768px, 1024px)

---

## 6. Testing

**Current state:** No tests exist - no unit tests, no integration tests, no end-to-end tests.

**Problem:** Every change is manually verified. Regressions in validation logic, export formatting, or state management go undetected until a user encounters them.

**Recommendation:**
- Add unit tests for pure logic functions: `generateJSON()`, `generateMarkdown()`, `validateStep()`, state serialization/deserialization
- Add end-to-end tests with a tool like Playwright or Cypress to verify the wizard flow
- Even a small test suite covering the export functions and validation would catch most regressions

---

## 7. CDN Dependency Risk

**Current state:** JSZip is loaded from `cdnjs.cloudflare.com` at runtime (`index.html:6`):
```html
<script src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js"></script>
```

**Problem:** If the CDN is down or unreachable (corporate firewalls, air-gapped networks), the download feature silently breaks. There's no fallback or error handling for the script failing to load.

**Recommendation:**
- Vendor the JSZip library locally (inline it or host the file alongside `index.html`)
- Alternatively, add an `onerror` handler on the script tag to warn the user
- If keeping the single-file approach, inline the minified JSZip directly into the HTML

---

## 8. Data Validation and Input Sanitization

**Current state:** User text inputs (account name, custom tools, custom compliance, success stories, AI champion name) are inserted into the DOM via string interpolation and `innerHTML`.

**Problem:** While this is a client-side-only app with no server, using `innerHTML` with user input is a bad practice that creates XSS vulnerabilities if the app ever gains a backend or if content is shared between users (e.g., via exported files opened in a browser).

**Recommendation:**
- Use `textContent` or `document.createElement()` instead of `innerHTML` for user-provided content
- Sanitize inputs before inserting into the DOM
- Add length limits on free-text inputs to prevent abuse in exports

---

## 9. Error Handling and User Feedback

**Current state:** Errors during download use `console.error` + `alert()`. Auto-save failures are silent. LocalStorage quota exhaustion is not handled.

**Recommendation:**
- Replace `alert()` with an in-page notification/toast system consistent with the existing UI
- Handle LocalStorage quota errors gracefully (inform the user, offer to clear old data)
- Add a try/catch around `loadProgress()` to handle corrupted localStorage data without breaking the app on load

---

## 10. Performance: Rendering Efficiency

**Current state:** Several render functions (e.g., `renderReview()`, `renderUseCases()`, `renderRoleToolMatrix()`) rebuild large sections of the DOM by setting `innerHTML` on container elements.

**Problem:** This is fine at the current scale, but it destroys and recreates all DOM nodes on every re-render, losing scroll position and input focus. It also prevents event delegation from working efficiently.

**Recommendation:**
- Use DOM diffing or targeted updates instead of full `innerHTML` replacements
- Adopt event delegation on stable container elements rather than re-attaching listeners after each render
- For the review step, consider building the DOM incrementally instead of one large HTML string

---

## 11. LocalStorage Robustness

**Current state:** All state is serialized to LocalStorage with `JSON.stringify`, and Sets are converted via `Array.from()`. There is no versioning.

**Problem:** If the data schema changes (new fields, renamed fields, restructured objects), old saved data will cause silent bugs or crashes when loaded. There's no migration path.

**Recommendation:**
- Add a schema version number to saved data (e.g., `{ version: 2, data: { ... } }`)
- Write migration logic that upgrades old formats to the current schema on load
- This prevents data loss for returning users after updates

---

## 12. Export Quality

**Current state:** JSON and Markdown exports work, but the JSON output is a flat dump of all state variables.

**Recommendations:**
- Structure the JSON export with a clear schema (metadata section, sections matching the wizard steps)
- Add a version field to the JSON export so downstream consumers can handle format changes
- Consider adding CSV export as an option for teams that want to aggregate results in spreadsheets
- Add a "copy to clipboard" option for the Markdown report for quick sharing

---

## Summary: Priority Ranking

| Priority | Improvement | Impact | Effort |
|----------|------------|--------|--------|
| High | Split monolithic file (#1) | Maintainability | Medium |
| High | Accessibility fixes (#4) | Usability, compliance | Medium |
| High | Mobile responsiveness (#5) | Reach | Low-Medium |
| High | Input sanitization (#8) | Security | Low |
| Medium | State management (#2) | Code quality | Medium |
| Medium | Step ordering cleanup (#3) | Maintainability | Low |
| Medium | Inline JSZip (#7) | Reliability | Low |
| Medium | LocalStorage versioning (#11) | Data integrity | Low |
| Medium | Add basic tests (#6) | Reliability | Medium |
| Low | Error handling UX (#9) | Polish | Low |
| Low | Render efficiency (#10) | Performance | Medium |
| Low | Export improvements (#12) | Feature quality | Low |
