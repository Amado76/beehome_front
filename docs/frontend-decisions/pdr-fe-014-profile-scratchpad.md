# PDR-FE-014: Profile scratchpad

- **Status:** Planned; UX reference pending
- **Backend source:** PDR-10 and current Profile Scratchpad API contract
- **Depends on:** PDR-FE-005 family member profiles

## Outcome

Give each family member an editable vector scratchpad, initially exposed on
adult profiles. The document belongs to the profile and synchronizes across
authorized devices. Flutter owns drawing interaction; the backend stores
validated whole-document revisions.

## Scope and implementation plan

1. Define typed versioned document/stroke/point models and serialization.
2. Implement pointer/stylus capture, normalized coordinates, rendering, and
   local stroke editing (undo/redo and stroke erase).
3. Load/save the full document with debounce, revision tracking, and save state.
4. Implement payload-limit handling and deliberate conflict recovery. Durable
   offline drafts require a separate storage/sync decision.

## Acceptance criteria

- Coordinates are normalized 0–1 and independent of screen resolution.
- Autosave sends whole documents after edits, never a request per pointer event.
- Newer local edits survive an in-flight save.
- A stale revision never silently overwrites server content; reload and resolve.
- Clear saves an empty document and advances revision.
- Client follows current format and size limits and fails safely on unsupported
  versions.

## UX and open decisions

**UX reference: pending.** Need drawing surface/aspect ratio, palette/tools,
undo/clear behavior, save indicator, and conflict recovery. Tune debounce and
point simplification through interaction design.

## Contract

[Profile scratchpad API](../backend-api/profile-scratchpad.md). No live
collaboration, pixel eraser, server preview/export, or server-managed offline
queue.
