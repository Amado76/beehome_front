# PDR-FE-004: Family workspace

- **Status:** Family workspace and mobile dashboard implemented; iPad visual refinement pending
- **Plan date:** 2026-10-03
- **Backend source:** PDR-02 and current Families API contract
- **Depends on:** PDR-FE-003 authentication/session

## Outcome

Let an authenticated user access a single family workspace. Create the family
only when the account has none. After login, enter the existing family
automatically and offer editing of its name and members when the role allows it.
Do not offer creation of another family or family switching.

## Dashboard scope and delivery order

The supplied mobile HTML is the visual reference for the authenticated family
home. PDR-FE-004 delivers the family context and home composition; its profile
carousel and daily checklist require PDR-FE-005 and PDR-FE-006/007 respectively.
The Free board uses PDR-FE-014's profile drawing scratchpad, as confirmed by the
user on 2026-10-03. These dependencies are separate
implementation slices, even when displayed on the same screen.

Follow the requested order: implement the mobile composition first, then adapt
it for iPad. This feature-specific order takes precedence over the project's
usual tablet-first delivery order. Share behavior and state from the start;
select compositions by available width, including iPad split-screen widths.

### Phase 1 — Family context and authenticated entry

1. Add immutable family, family-role, and page models, plus a remote family
   repository using the injected `ApiClient`. Support only the documented list,
   create, read, and PATCH operations.
2. Coordinate active-family state in a `FamilyWorkspaceService` because it is
   shared by the home, profiles, and subsequent daily features. Inject the
   existing local preferences repository for `selectedFamilyId`; do not add
   another preference store.
3. After authenticated startup, revalidate a saved family through GET. Without
   a valid selection, load accessible families: show creation for an empty
   account and automatically enter the first accessible family otherwise.
   Do not display a family chooser or family pagination.
4. Offer family creation with name only and name editing to OWNER/ADMIN.
   Use existing notebook form styling and native accessible controls. The API
   accepts name-only creation and editing. Do not expose timezone controls.
5. Select the family returned by a successful creation. Block further family
   creation; expose family settings and the existing language
   and sign-out actions through their owning ViewModels.
6. Clear family context and cached feature state on sign-out/account switch.
   On family switches, cancel or ignore older requests so a late response cannot
   display data from the previous family. Treat 404 as unavailable context and
   reload the family context; treat 403 as denied permission.
7. After an uncertain POST/PATCH outcome, reload before allowing another write.
   Do not automatically retry creation or identify the created family solely
   by name, since duplicate family names are allowed.

### Phase 2 — Mobile home composition

Build a vertically scrollable home within the safe area, using the supplied
390–420-pixel composition as the visual baseline. Let smaller screens and
enlarged text determine the actual fit; do not hard-code a device width.

| Reference block | Planned behavior | Dependency |
| --- | --- | --- |
| Date, time, BeeHome, and Today | Show localized device-local date/time; open contextual options | PDR-FE-004 |
| Family profile carousel | Select one active profile and visually identify it | PDR-FE-005 |
| Free board | Preview and edit the selected profile's handwritten drawing | PDR-FE-014 |
| Routine and tasks | Show the selected profile's actual daily execution and completion count | PDR-FE-006/007 |
| Footer | Render localized family notebook branding | PDR-FE-004 |

- Preserve the reference's white canvas, generous spacing, subtle borders,
  rounded cards, restrained shadows, honey selection accent, pastel profile
  backgrounds, and horizontal carousels. The HTML defines dotted-paper and
  folded-corner styles but does not apply them to this home; do not introduce
  those decorations solely because the definitions exist.
- Reuse bundled Plus Jakarta Sans for interface text and Space Mono for date,
  time, and notebook captions. Render handwriting from captured strokes;
  no handwritten font is needed for this surface.
- Centralize recurring home styles in existing design-system tokens. Reuse
  smaller presentation widgets where needed rather than copying the HTML's
  inline values into every widget.
- Use at least 48 logical pixels for interactive targets, even where the
  reference's visible icon or checkbox is smaller. Support semantics, text
  scaling, keyboard focus, and reduced motion.
- Localize all interface strings in pt-BR, en, es, and et, including date
  captions, progress plurals, loading, errors, and menu actions. Profile names
  and user content remain unchanged.
- Display the header date/time and execution day in the device's local timezone.
  Send its current UTC offset automatically through X-Timezone-Offset on every
  API request so the backend uses the same calendar day. Refresh on resume and
  detect device-local day changes. Event timestamps remain UTC instants.
- The reference's empty Daily Highlights section creates no additional card.
  Its names, notes, dates, times, and completion counts are examples, not
  production defaults.

### Phase 3 — Profile carousel integration (PDR-FE-005 slice)

1. Load active profiles from the family members API with pagination. Provide
   loading, no-profile, and retry states independently of the family shell.
2. Use the same selected profile for both the avatar carousel and task-filter
   pills; tapping either updates the other. Keep selection in workspace memory
   for this release and reset it when changing family/account or when the
   selected profile becomes unavailable. Select the first available active
   profile when no valid selection exists.
3. Use profile colors through semantic tokens and show a selection ring plus
   an accessible selected state. Use local illustrative placeholders or initials;
   the current API's avatar is read-only and null. Do not assign the supplied
   people's illustrations to arbitrary real profiles.
4. Keep profile creation/editing as the PDR-FE-005 workflow. An empty carousel
   may link to that workflow when implemented and allowed by the API role.

### Phase 4 — Daily checklist integration (PDR-FE-006/007 slice)

1. Supply routine/planning configuration through PDR-FE-006 and execution
   materialization through PDR-FE-007. Read completion from execution snapshots,
   never infer it from the plan or generate example activities.
2. Load the device-local day's execution and filter items for the selected
   profile. Derive the profile's completed/total label from its actual items,
   respecting execution statuses; do not reuse a family-wide count as the
   selected profile's progress.
3. Delegate materialization policy to the execution ViewModel/service. GET
   reads existing snapshots; PUT materializes/synchronizes today according to
   the documented execution flow. Do not issue writes from widget builds or
   materialize historical/future dates.
4. Complete/uncomplete using returned execution item IDs. Disable each pending
   action while its request runs, apply the server response, and reconcile
   uncertain outcomes before retrying. Handle finalized execution and role
   errors with localized feedback.
5. Keep pending tasks gray; map completed tasks to the profile's configured
   completion color, with a checkmark and readable completion semantics. The
   reference's green checkmarks do not override the project's functional-color
   rule.
6. Refresh data on device-local day rollover and resume. Protect requests from
   family/profile/date changes and show empty-day and recoverable-error states.

### Phase 5 — Handwritten Free board (PDR-FE-014 slice)

The user confirmed handwriting on mobile using the existing drawing API.
Adapt the reference to one board per selected profile: a locally rendered
drawing preview, a Write/Edit action, and the profile name as board owner.
Remove the multiple text post-its, per-note authors, and active-note count.

1. Load the selected profile's document through the profile-scratchpad GET
   route. Render strokes locally; the server does not provide preview images.
   Show empty, loading, and retry states. Initially expose adult boards as
   defined by PDR-FE-014; never leave another profile's board visible on switch.
2. OWNER/ADMIN can open a dedicated editor; MEMBER can view the board. Support
   finger drawing and compatible stylus input, with one stroke per pointer
   contact, normalized 0–1 coordinates, and pressure only when supplied by the
   device. Handwriting does not require recognition or conversion to text.
3. Choose one stable drawing aspect ratio shared by mobile and iPad. Fit the
   surface into the viewport without distorting strokes. Keep the home preview
   read-only; the editor owns drawing gestures, preventing accidental strokes
   during home scrolling. Provide explicit pan mode if viewport navigation is
   needed. Refine zoom and palm rejection only as platform capabilities and
   interaction needs justify them.
4. Offer pen color/width, undo/redo, stroke erase, and clear with confirmation.
   Save complete documents with debounce, revision tracking, payload limits,
   and visible saving/saved/error feedback, following PDR-FE-014.
5. Preserve newer edits during in-flight saves. Reconcile uncertain writes
   through GET and resolve revision conflicts deliberately without silently
   discarding either version. Protect unsaved edits on dismissal or family/
   profile changes and ensure each save targets its original document.
6. Keep durable offline drafts as a separate persistence decision; do not
   promise offline synchronization. This board can ship after profiles,
   independently of the daily checklist.

Follow [PDR-FE-014](pdr-fe-014-profile-scratchpad.md) and the existing
[profile scratchpad API](../backend-api/profile-scratchpad.md). No new text-note
API is required for the agreed handwriting scope.

### Phase 6 — iPad composition

After the mobile home is implemented, refine a dedicated iPad composition from
the subsequent tablet reference. The provisional layout is a bounded notebook
canvas with a shared header/profile selector and a wider main area; when the
free board becomes available, place it beside the daily checklist where space
allows. Final column proportions and navigation await the iPad reference.

Use shared breakpoints: compact below 600, tablet at 600–1199, and desktop at
1200 or above. Do not stretch mobile cards to fill an iPad or branch by device
model. Reuse repositories, services, ViewModels, localization, tokens, and
feature widgets. Support portrait, landscape, split-screen, scrolling, and
external keyboard interaction. Pencil input reuses the mobile drawing document
and editor tools. Drawing tools belong to the drawing slice,
not to family selection or the daily checklist.

## Implementation boundaries

- Organize family models, repositories, service, ViewModels, and views under
  `features/family_workspace/`, creating only the layers needed above. Profiles,
  execution, and scratchpad keep their own feature ownership.
- Views render injected ViewModel state and forward actions. Register the new
  dependencies in a feature module at the existing composition boundary; do
  not turn `AppServices` into a container of every dashboard dependency.
- Use native listenables and the current API/session/error handling. Preserve
  the bounded session-refresh behavior; a family preference never grants access.
- Track completion by slice: family workspace, mobile profile/checklist
  integrations, handwritten free board implementation, and iPad composition. A
  completed family shell does not mean every referenced dashboard block ships.

## Acceptance criteria

- Empty, single-family, and multiple-family accounts can enter a valid family.
- Stale/inaccessible selection is cleared safely; family ID is not treated as
  authorization.
- Creation and editing send only a name. Families have no timezone field.
  The network client supplies the current device UTC offset automatically.
- Only OWNER/ADMIN see edit affordances; backend 403/404 remains authoritative.
- Uncertain create/edit outcomes reload family state before another write.
- Mobile home follows the supplied visual hierarchy without horizontal page
  overflow; only the carousels scroll horizontally.
- Family switches, sign-out, and late requests cannot expose stale family data.
- Date/time and daily task loading use device-local today, including after
  resume or midnight.
- Profile selection and task filters remain synchronized when their dependent
  slices ship; completion and counts come from actual execution responses.
- Functional screens show loading, empty, error, and unavailable-feature states
  without presenting example data as persisted content.
- iPad delivery reuses the mobile behavior and adapts composition by width.
- The board supports finger/stylus handwriting on mobile and the same drawing
  on iPad without distortion. Roles, save failures, revision conflicts, and
  profile switches preserve document ownership and unsaved edits.

## Implementation progress — 2026-10-03

- Production authenticated entry now opens the family home. Empty accounts can
  create a family with a name only; accounts can choose
  or switch families, paginate the chooser, and edit settings when authorized.
- The shared workspace service revalidates saved selection and clears context
  on session changes. Request generations protect family and profile switches;
  ambiguous family writes require successful reconciliation and user review
  before another submission.
- The mobile home implements the supplied header, profile carousel, board card,
  task filters, checklist, and footer hierarchy. Profiles can be created/edited
  with type, birth date, color, and completion-color preference when editing.
  Profile carousel and task filters share the same selection.
- The family clock uses the device-local date and time for the header and
  execution requests. The API client automatically supplies the current
  device UTC offset; no timezone database dependency is needed.
- The daily slice reads execution snapshots, materializes a missing current
  day, supports explicit synchronization, creates date-specific planning tasks,
  and completes/undoes execution items. Cancelled items are omitted from the
  checklist count; finalized days are read-only. Recurring-routine management
  and history remain their owning PDRs' later workflows.
- The adult board previews the selected profile's drawing. Its separate editor
  supports finger/stylus input, colors, width, stroke erase, undo/redo, clear,
  whole-document autosave, uncertain-write reconciliation, and explicit
  conflict resolution. Unsaved edits require saving or deliberate discard when
  leaving the editor.
- Layouts below 600 logical pixels stack the cards; wider layouts use a
  provisional shared two-column composition. The specific iPad visual design
  still awaits its reference. Mobile text scaling and safe-area layout are
  covered by widget tests.
- All new interface strings are localized in pt-BR, en, es, and et. The feature
  repositories and shared workspace are registered in a dedicated DI module;
  Views continue to receive ViewModels through constructors.

## Validation

When implementing, cover repository payloads/pagination, role-aware family
forms, selection restoration and clearing, family-switch request races, and
ambiguous mutation recovery. For the later dashboard integrations, cover
profile/filter synchronization, device-local day changes, completion commands,
and finalized execution. For drawing, cover coordinate mapping, finger/stylus
input, read-only roles, undo/clear, in-flight edits, conflicts, and navigation
with unsaved strokes. Check mobile safe areas, long names, enlarged text,
and the subsequent iPad compositions against the supplied references.

Implementation validation on 2026-10-03: all 111 tests pass; `flutter analyze
--fatal-infos --fatal-warnings` reports no issues; `flutter build web` succeeds
using an example API origin for compilation. Tests cover selection clearing,
late responses, uncertain mutations, device-local midnight boundaries, failed task
completion, drawing revisions/in-flight edits/conflicts, and touch interaction
at mobile and tablet widths. Live backend integration and physical iPad/Pencil
interaction have not been exercised in this implementation session.

## UX and open decisions

**Mobile home reference: received on 2026-10-03.** The supplied HTML informs
the home composition only; its browser geolocation scripts are not application
requirements. Chooser, empty state, creation, settings, and
iPad references remain pending; use the existing design system for essential
family forms. The Free board is approved as a profile vector drawing using the
existing API; refine its editor and shared aspect ratio during that slice. Family
creation quota remains a backend rollout decision; do not invent a client quota.

## Contract and exclusions

[Families API](../backend-api/families.md). No invites, join-by-code,
membership/role management, ownership transfer, leave, deletion, or archival.
