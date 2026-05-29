# Product Requirements Document: CampAwayDesign — Affordable SUV-Towable Tiny Trailer Home Design Platform

## 1. Problem Statement

People who want affordable, movable tiny homes have no easy way to work with architects and builders. Today, the back-and-forth happens over scattered emails, text messages, phone calls, and one-off PDFs. Clients struggle to clearly describe the layout they want, the features they need, and the budget they can afford. Architects and builders, in turn, waste time chasing missing information and re-doing work after misunderstandings.

This matters now because demand for compact, towable living spaces — for weekend getaways, short-term mobile living, and affordable housing alternatives — is growing, while the tools to design them collaboratively have not kept up. A focused platform that handles requirement gathering, floorplan collaboration, revisions, and approvals in one place removes friction for everyone and helps deliver a finished trailer home under ~$50k that's towable by a typical SUV.

## 2. Goals

1. Reduce the time from first client inquiry to an approved floorplan by 40% within the first 6 months of launch. `[ASSUMPTION]`
2. Cut the average number of revision rounds per project from a baseline to 30% fewer within 6 months. `[ASSUMPTION — baseline not yet measured]`
3. Achieve a requirement-form completion rate of 80% among clients who start one within 3 months of launch.
4. Reach a client satisfaction score of 4.2 out of 5 or higher on the design collaboration experience within 6 months.
5. Onboard at least 10 active design/build firms and 100 active client projects within the first 9 months. `[ASSUMPTION — depends on go-to-market]`

## 3. Non-Goals

- This platform will **not** perform structural engineering calculations or certify towing safety/road-legality. It supports collaboration, not regulatory compliance sign-off.
- It will **not** handle payments, invoicing, or contracts between clients and firms in the MVP.
- It will **not** generate floorplans automatically or use AI to design layouts in the MVP. Designs are created by the architects/builders.
- It will **not** manage physical construction scheduling, material procurement, or on-site project logistics.
- It will **not** support homes outside the compact trailer category (e.g., full-size RVs, stationary tiny homes, or multi-trailer builds) in the MVP.
- It will **not** include a native mobile app for the MVP — it will be a responsive web application only.

## 4. Users & Use Cases

**Primary users:**
- **Clients** wanting compact trailer homes under $50k (including couples seeking weekend or short-term mobile living)
- **Architecture and design firms**
- **Tiny home builders and project managers**

**Scenario 1 — The budget-conscious couple**
Maria and Jon want a weekend trailer home they can tow behind their mid-size SUV. They visit the platform, fill out a requirement form describing their must-haves (wet bath, kitchenette, sleeping space for two) and their $45k budget. They upload a few inspiration photos from Pinterest. The platform packages this into a clear brief that a design firm can act on without a single phone call.

**Scenario 2 — The design firm picking up a new project**
A designer at a small architecture firm logs in and sees a new client brief with all requirements, budget, and reference images in one place. She uploads a first-draft floorplan, marks which requirements it satisfies, and shares it for review. When the clients leave comments asking for a larger kitchenette, she uploads a revised version, and the platform tracks both versions side by side.

**Scenario 3 — The builder confirming feasibility**
A builder/project manager reviews the approved floorplan and the target loaded weight goal (under ~5,000 lbs). He flags that the requested solar-and-battery upgrade may push the budget close to the $50k ceiling, leaves a note on the design, and the clients decide whether to keep or drop the upgrade — all within the platform's revision thread.

## 5. User Stories

**Must-have**
- As a client, I want to fill out a structured requirement form so that I can clearly communicate my layout, features, and budget without writing long emails.
- As a client, I want to upload reference images so that I can show the look and feel I'm going for.
- As a designer, I want to view a client's complete brief in one place so that I can start designing without chasing missing details.
- As a designer, I want to upload floorplan images/files so that clients can review my proposed layout.
- As a client, I want to leave comments on a floorplan so that I can request specific changes.
- As a designer, I want to upload revised floorplans and have versions tracked so that everyone can see what changed across rounds.
- As a client, I want to formally approve a floorplan so that the project can move forward with a clear sign-off.

**Should-have**
- As a builder/project manager, I want to add notes about feasibility (e.g., weight, budget impact) so that clients can make informed trade-offs.
- As a client, I want to see how my selected features (wet bath, kitchenette, solar) map against my budget so that I understand cost trade-offs. `[NEEDS INPUT — is cost estimation in scope for MVP, or only firm-provided notes?]`
- As a user, I want email notifications when a project is updated so that I don't miss revisions or approvals.

**Nice-to-have**
- As a client, I want to compare two floorplan versions side by side so that I can decide which I prefer.
- As a designer, I want reusable requirement templates so that I can speed up briefs for common configurations.
- As a client, I want to indicate optional upgrades (solar, battery) with a toggle so that the firm sees exactly what I want priced.

## 6. Acceptance Criteria

**Story: Client fills out a structured requirement form**
- Given a logged-in client on a new project, when they open the requirement form, then they see fields for trailer size (16–18 ft), sleeping capacity, wet bath, kitchenette, optional solar/battery, and budget target.
- Given a client completing the form, when they leave a required field blank and submit, then the form blocks submission and highlights the missing field.
- Given a completed form, when the client submits it, then the brief becomes visible to the assigned design firm and is marked "Submitted."

**Story: Client uploads reference images**
- Given a client on their project, when they upload an image in a supported format (JPG, PNG) under the size limit, then the image appears in their brief's reference gallery. `[ASSUMPTION — formats and size limit, e.g. 10MB]`
- Given a client uploading an unsupported file type, when they attempt the upload, then the system rejects it with a clear error message.

**Story: Designer uploads a floorplan**
- Given a designer assigned to a project, when they upload a floorplan file, then it appears in the project's floorplan section labeled as the current version.
- Given an existing floorplan, when the designer uploads a new one, then the previous version is preserved and the new one is marked "Latest."

**Story: Client comments on a floorplan**
- Given a client viewing a floorplan, when they add a comment, then the comment is saved, timestamped, attributed to them, and visible to the design firm.

**Story: Revision tracking**
- Given multiple uploaded floorplan versions, when any user opens the project, then they see an ordered version history with dates and who uploaded each version.

**Story: Client approves a floorplan**
- Given a client viewing the latest floorplan, when they click "Approve," then the floorplan is locked as approved, the action is timestamped and attributed, and all parties are notified.
- Given an approved floorplan, when a designer uploads a new version, then the approval status resets and the project returns to "In Review." `[ASSUMPTION — confirm desired behavior]`

## 7. Risks & Assumptions

| Risks | Assumptions |
|---|---|
| Clients may abandon long requirement forms before completing them. | Clients are willing to self-serve a structured form instead of talking to a person first. |
| File upload handling (large images/floorplans) could create performance or storage cost issues. | Floorplans will be shared as images/PDFs, not editable CAD files, in the MVP. |
| Scope creep toward cost estimation, payments, or engineering features could delay the MVP. | Design firms already have their own tools for actual design work and just need a collaboration layer. |
| Without cost guidance, clients may design beyond the ~$50k budget and get frustrated. | The $50k budget and ~5,000 lb towing weight are guidelines the firm enforces, not values the platform calculates. |
| Low firm adoption would starve the platform of designers to serve clients. | There is enough demand from both clients and firms to reach a critical mass. |
| Notification fatigue could cause users to ignore important updates. | Email is an acceptable notification channel for the MVP. |

## 8. Open Questions

- Will the MVP include any cost estimation or budget-vs-feature mapping, or is all cost guidance left to firm-provided notes? `[NEEDS INPUT — Owner: Product]`
- How are clients matched to design firms — self-selection, admin assignment, or marketplace? `[NEEDS INPUT — Owner: Product]`
- What file types and size limits must we support for uploads (e.g., PDF, CAD)? `[NEEDS INPUT — Owner: Engineering]`
- Do we need user roles and permissions beyond client / designer / builder for the MVP? `[NEEDS INPUT — Owner: Product]`
- Should approvals be legally binding or simply a workflow milestone? `[NEEDS INPUT — Owner: Legal/Product]`
- What happens to a project after the floorplan is approved — does the platform's responsibility end there? `[NEEDS INPUT — Owner: Product]`
- Is multi-language or accessibility (WCAG) support required at launch? `[NEEDS INPUT — Owner: Product]`

## 9. Success Metrics

**Leading indicators (early signals)**
- Requirement-form start and completion rates
- Number of reference images and floorplans uploaded per project
- Time from brief submission to first floorplan upload
- Number of comments/revisions per project (engagement)
- Weekly active firms and active client projects

**Lagging indicators (final outcomes)**
- Percentage of projects that reach an approved floorplan
- Average time from inquiry to approved floorplan (vs. 40% reduction goal)
- Average revision rounds per project (vs. 30% reduction goal)
- Client satisfaction score (target ≥ 4.2 / 5)
- Firm retention and repeat-project rate over 6–9 months

---

## Appendix A: Detailed User Stories — Client Requirement Intake Form (MVP)

> Scope note: This is the **MVP** version of the requirement form. Stories below marked Nice-to-have (e.g. draft persistence) are **out of MVP scope** and listed only for future planning. MVP delivers Stories 1–3.

**Story 1:** As a client, I want to fill out a structured requirement form so that I can clearly describe my trailer home's layout, features, and budget without writing long emails.

**Acceptance Criteria:**
- Given a logged-in client starting a new project, when they open the form, then they see fields for trailer length (16–18 ft), sleeping capacity, wet bath, kitchenette, optional solar/battery, budget, and free-text notes, pre-filled with the PRD default values.
- Given a client completing the form, when they submit with all required fields valid, then a new project is created with status "submitted" and the client is taken to the project view.
- Given a client editing the trailer length or budget, when the value falls outside the PRD targets (16–18 ft, ~$50k), then an inline warning appears but does not block submission.

**Priority:** Must-have
**Effort:** Medium (2-3 days)

**Story 2:** As a client, I want required fields validated before I submit so that I don't send an incomplete brief to the design firm.

**Acceptance Criteria:**
- Given a client on the form, when they leave a required field (e.g. client name, budget) blank and try to submit, then submission is blocked and the missing field is highlighted with a message.
- Given a client who fixes a previously-invalid field, when the field becomes valid, then its error message clears immediately.
- Given a form with validation errors, when the client submits, then focus moves to the first field with an error for accessibility.

**Priority:** Must-have
**Effort:** Small (< 1 day)

**Story 3:** As a client, I want to toggle optional upgrades (solar, battery) so that the firm sees exactly which extras I want priced.

**Acceptance Criteria:**
- Given a client on the form, when they enable the solar or battery toggle, then that choice is saved on the brief and shown in the submitted project.
- Given both upgrades are off by default, when the client submits without touching them, then the brief records both as not requested.

**Priority:** Should-have
**Effort:** Small (< 1 day)

**Story 4:** As a client, I want my in-progress answers preserved so that I don't lose my brief if I close the tab before submitting. `[NEEDS CLARIFICATION]` — *Out of MVP scope.*

**Acceptance Criteria:**
- Given a client partway through the form, when they reload or reopen the page, then their entered values are restored.
- Given a client who submits the form, when the project is created, then the saved draft is cleared.

**Priority:** Nice-to-have
**Effort:** Medium (2-3 days)

### Edge Cases to Discuss
- What happens if the client enters a budget far below feasible (e.g. $5,000)? Warn, block, or allow?
- How should the form behave on mobile — single column with the same field order, or a stepped/multi-page flow?
- What if a client tries to create a second project — is there a limit, or a list/dashboard to choose from first?
- Should reference-image upload live inside this form or be a separate step after the project is created? (Affects Story 1's scope.)
- What happens to validation warnings (out-of-range length/budget) once the firm sees them — are they flagged on the firm's side too?

### Questions for the Team
1. Is the requirement form the entry point to creating a project, or does a project already exist (created by the firm) that the client then fills in? This changes who owns project creation.
2. Does reference-image upload belong in this story, or is it a separate must-have story we build next? (PRD lists it as its own story.)
3. Should out-of-budget / out-of-spec values be a soft warning (current assumption) or a hard block requiring firm override?

---

Review the `[ASSUMPTION]`, `[NEEDS INPUT]`, and `[NEEDS CLARIFICATION]` sections before sharing with engineering.
