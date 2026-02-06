# Feature & UX Recommendations

## UX Issues to Fix

### 1. Unsaved-Changes Guard (missing `beforeunload`)

**Problem:** Auto-save is debounced by 1 second (`index.html:2976-2979`). If a user closes the tab immediately after making changes, the save may not fire. There is no `beforeunload` handler to warn them.

**Fix:** Add a `beforeunload` listener that fires when there are unsaved changes:
```js
window.addEventListener('beforeunload', (e) => {
  if (hasUnsavedChanges) {
    e.preventDefault();
    e.returnValue = '';
  }
});
```

---

### 2. Silent Rejection When Selecting a 3rd Limiting Factor

**Problem:** Users can only pick 2 limiting factors (`index.html:4036`), but clicking a 3rd option does absolutely nothing — no visual feedback, no disabled state, no message. Users will think the UI is broken.

**Fix:**
- After 2 factors are selected, visually dim the remaining unselected cards (reduced opacity + `cursor: not-allowed`)
- Show a subtle inline message: "Maximum 2 factors selected. Deselect one to change."

---

### 3. "Don't Know" Auto-Selection in Tool Categories

**Problem:** When a tool category loads with nothing selected, the code silently selects "Don't know" as a default (`index.html:3106-3112`). Users don't realize a choice was made for them, and it inflates the "Don't know" count in exports.

**Fix:** Leave categories unselected by default. Show a neutral state like "No selection yet" instead of pre-checking "Don't know."

---

### 4. Exclusive Options Clear Multi-Selections Without Warning

**Problem:** In the Client AI Usage question (`index.html:3487-3502`), selecting "I Don't Know" or "Not Using AI" silently clears all other selections. A user who carefully picked 3 usage types and then accidentally clicks "I Don't Know" loses all of them with no undo.

**Fix:**
- Show a confirmation before clearing: "This will remove your other selections. Continue?"
- Or visually separate exclusive options (e.g., place "I Don't Know" and "Not Using AI" in their own row above the multi-select cards with a divider labeled "— or select all that apply —")

---

### 5. Disabled "Start Assessment" Button Has No Explanation

**Problem:** The start button begins disabled (`index.html:1776`) but there's no hint telling users they need to type an account name first. A new user sees a grayed-out button with no context.

**Fix:** Add helper text below the input: "Enter an account name to begin" that disappears once the button enables. Or show a tooltip on the disabled button.

---

### 6. Review Page Edit Buttons Are Ambiguous

**Problem:** On the review page (`index.html:4174-4386`), both the entire section header AND an "Edit" button inside it navigate to the same step. Users don't know if they should click the header text or the button. There's no hover effect on the header to indicate it's clickable.

**Fix:**
- Remove the `onclick` from the section header div — keep only the Edit button as the click target
- Style the Edit button more prominently (outlined pill with an edit icon)
- Add the destination step name to the button: "Edit Roles" instead of just "Edit"

---

### 7. No Confirmation or Toast After Download

**Problem:** After the ZIP downloads (`index.html:4906-4922`), the button just reverts to its original text. Users on slow connections or with popup blockers may not realize the download happened.

**Fix:** Show an in-page success toast: "Assessment downloaded successfully" that auto-dismisses after 4 seconds. If the download fails, show a persistent error toast instead of `alert()`.

---

### 8. No Notification When Restoring Saved Progress

**Problem:** When a returning user loads the page, the app silently jumps to their last step (`index.html:2987-2995`). There's no message like "Welcome back — resuming from Step 4."

**Fix:** Show a dismissible banner at the top: "Your previous progress has been restored. [Start Over]" — giving the user context and the option to reset.

---

### 9. Clear All Data Has No Undo

**Problem:** "Clear All Data" uses a single `confirm()` dialog (`index.html:2893`), then permanently deletes everything. One accidental click and all work is gone.

**Fix:**
- Replace `confirm()` with an in-page modal: "This will permanently delete all your assessment data. Type DELETE to confirm."
- Or: after clearing, show a 10-second undo banner: "All data cleared. [Undo]" — keep the old data in memory briefly.

---

### 10. Workflow Maturity Stage Descriptions Are Too Small to Read

**Problem:** The WFM table cells use `font-size: 0.68rem` (~9px) (`index.html:754`). Users can't comfortably read the stage descriptions, especially on laptop screens.

**Fix:**
- Increase to at least `0.75rem` (12px)
- Add a tooltip or expandable detail on hover/click for each cell so users can read the full description without squinting
- Consider a card-based layout instead of a dense table: one role at a time, with stages as selectable cards (similar to the Client AI maturity pipeline)

---

## Features to Add

### 11. Printable / Share-Ready Summary View

**Problem:** The only way to share results is downloading a ZIP of JSON + Markdown files. There's no way to print the assessment, share a link, or copy a summary.

**Feature:**
- Add a "Print" button on the review page that opens a print-friendly CSS view
- Add a "Copy Summary to Clipboard" button that copies the Markdown report
- Both are low-effort, high-value additions for users who need to share results in meetings or emails

---

### 12. Step-by-Step Progress Breadcrumbs

**Problem:** The current progress indicator is a fill bar + "Step X of Y" text (`index.html:1718`). Users can't see step names, can't jump to a specific step, and can't tell which steps are complete vs. incomplete.

**Feature:**
- Replace or supplement the progress bar with a clickable breadcrumb trail showing step names (e.g., "Engagement > Client AI > Roles > Tools > ...")
- Mark completed steps with a checkmark, current step as highlighted, future steps as dimmed
- Allow clicking completed steps to navigate directly (with unsaved-changes check)

---

### 13. Optional Steps Clearly Marked

**Problem:** Steps 3 (Use Cases), 4 (Role-Tool Matrix), and 9 (Workflow Maturity) have no validation (`index.html:4107-4166`) — they're effectively optional. But nothing in the UI signals this. Users either feel pressured to complete them or skip them without realizing they're important.

**Feature:**
- Add "(Optional)" next to the step indicator for these steps
- On the review page, show "Not completed" with a subtle prompt: "Want to add this? [Go to step]"
- In the export, note which optional sections were skipped vs. intentionally left empty

---

### 14. Inline Help / Tooltips for Complex Concepts

**Problem:** Several questions use domain-specific terms without explanation:
- "Staff Augmentation" vs. "Outcome-Based" ownership — what's the difference?
- "FedRAMP" vs. "SOC 2" compliance — which applies to the user?
- "Piloting" vs. "Scaling" in the AI maturity pipeline — where's the boundary?
- Workflow Maturity stages 3-5 are nuanced and hard to distinguish

**Feature:**
- Add small info icons (ⓘ) next to terms that expand to a 1-2 sentence tooltip on hover/click
- For the maturity pipeline, add a "What does each stage mean?" expandable section with examples
- This helps less-experienced users answer accurately without leaving the page

---

### 15. Assessment Scoring / Readiness Dashboard

**Problem:** The review page is just a data dump — it lists what the user selected but provides no analysis or actionable insight. Users fill out 8 steps of detailed data and get back... the same data formatted slightly differently.

**Feature:**
- Calculate a simple "AI Readiness Score" based on responses (e.g., maturity stage, tool adoption, workflow maturity levels, governance)
- Show a visual dashboard on the review page with:
  - Overall readiness score (e.g., "3.2 / 5")
  - Radar/spider chart showing dimensions (Tool Maturity, Governance, Skills, Strategy)
  - Top 3 recommended focus areas based on gaps (e.g., "Your team has no AI governance — consider establishing informal guidelines")
- This transforms the tool from a data collection form into an actionable assessment

---

### 16. Comparison / Benchmarking

**Problem:** Users have no frame of reference for whether their answers indicate good or poor AI readiness.

**Feature:**
- Show anonymous aggregate benchmarks: "Most teams at the Piloting stage have 3+ AI tools adopted"
- Provide tier labels: "Your team's AI workflow maturity is in the top 30% of assessed teams"
- Even static/hardcoded benchmarks based on industry research would add tremendous value
- This could be a future phase if data aggregation infrastructure is added

---

### 17. Import Previously Exported Assessment

**Problem:** Users can export to JSON/ZIP, but there's no way to re-import. If a user clears their browser data or switches devices, they lose everything and must start over.

**Feature:**
- Add an "Import Assessment" button on the welcome step
- Accept a previously exported JSON file, validate the schema, and restore all state
- This also enables teams to share and review each other's assessments

---

### 18. Multi-Language Support (i18n Ready)

**Problem:** All UI text is hardcoded in English throughout the HTML and JavaScript. For a global consulting tool, localization would expand reach.

**Feature:**
- Extract all user-facing strings into a translation object (e.g., `const i18n = { en: { ... }, es: { ... } }`)
- Add a language selector in the header
- Even if only English is supported initially, having the structure in place makes future translations trivial

---

### 19. Dark Mode Toggle

**Problem:** The app has a dark header/background but white content cards. Users in low-light environments or who prefer dark mode have no option.

**Feature:**
- Add a dark/light mode toggle in the header (next to "Clear All Data")
- Use CSS custom properties for all colors so switching is a single class toggle
- Respect `prefers-color-scheme` media query as the default

---

### 20. Conditional / Adaptive Questions

**Problem:** All steps are shown to all users regardless of context. For example:
- If no QA roles are selected, the Test Management Tools category still appears (though it's hidden via `showForRoles` — good)
- But if a team has zero AI tools, they still see the Role-Tool Matrix (which will be empty)
- If client AI maturity is "Not Started," detailed governance and challenge questions may be premature

**Feature:**
- Skip or collapse the Role-Tool Matrix step when no AI tools are selected
- If client AI maturity is "Not Started" or "Don't Know," auto-skip or simplify subsequent client AI questions
- Show a "This step was skipped because..." message in the review for transparency

---

## Summary: Priority Ranking

| Priority | # | Recommendation | Type | Effort |
|----------|---|---------------|------|--------|
| **High** | 1 | Unsaved-changes guard (`beforeunload`) | UX Fix | Low |
| **High** | 2 | Visual feedback for limiting factor max selection | UX Fix | Low |
| **High** | 4 | Warn before exclusive options clear multi-selections | UX Fix | Low |
| **High** | 5 | Explain why Start Assessment is disabled | UX Fix | Low |
| **High** | 12 | Step-by-step progress breadcrumbs | Feature | Medium |
| **High** | 15 | Assessment scoring / readiness dashboard | Feature | High |
| **Medium** | 3 | Don't auto-select "Don't Know" in tool categories | UX Fix | Low |
| **Medium** | 6 | Clarify review page Edit buttons | UX Fix | Low |
| **Medium** | 7 | Toast notification after download | UX Fix | Low |
| **Medium** | 8 | "Welcome back" notification on restore | UX Fix | Low |
| **Medium** | 10 | Increase WFM stage description readability | UX Fix | Low |
| **Medium** | 11 | Print view + Copy to Clipboard | Feature | Low |
| **Medium** | 13 | Mark optional steps clearly | Feature | Low |
| **Medium** | 14 | Inline help tooltips for complex terms | Feature | Medium |
| **Medium** | 17 | Import previously exported assessment | Feature | Medium |
| **Medium** | 20 | Conditional / adaptive question flow | Feature | Medium |
| **Low** | 9 | Undo for Clear All Data | UX Fix | Medium |
| **Low** | 16 | Comparison / benchmarking | Feature | High |
| **Low** | 18 | i18n-ready string extraction | Feature | Medium |
| **Low** | 19 | Dark mode toggle | Feature | Medium |
