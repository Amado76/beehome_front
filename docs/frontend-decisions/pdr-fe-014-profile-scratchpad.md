# PDR-FE-014: Profile scratchpad

- **Status:** Initial adult mobile board/editor implemented; iPad interaction validation pending
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

The family home's Free board uses this API as confirmed on 2026-10-03. Mobile
supports handwriting with a finger or compatible stylus, with a read-only
dashboard preview and a dedicated editor. Use one board per selected profile;
the reference's separate text post-its become a single drawing surface. iPad
later reuses the same normalized document and drawing tools. See the
[family workspace plan](pdr-fe-004-family-workspace.md#phase-5--handwritten-free-board-pdr-fe-014-slice).

### Implementation progress — 2026-10-03

The adult profile's home card renders a local vector preview and opens a dedicated
finger/stylus editor. MEMBER can read; OWNER/ADMIN can edit. The shared logical
surface is 4:3; stroke widths use a 400-unit reference width so previews and larger
editors retain proportions. Supported stylus pressure is normalized; finger and
mouse input omit pressure.

The editor offers pen colors, widths 1–10, stroke erase, undo/redo with bounded
history, and clear with confirmation. It captures one pointer at a time and owns
drawing gestures separately from page scrolling. Autosave uses a 1.4-second
debounce, complete documents, revision tracking, and contract payload limits.
New edits survive pending saves. Ambiguous writes require a successful read
before another PUT; conflicting versions are shown with explicit choices and
confirmation. Leaving with unsaved writing requires saving or deliberate discard.

Widget tests exercise finger input at mobile/tablet widths; unit tests cover
revision conflicts, uncertain writes, in-flight edits, read-only roles, and
undo/clear. Physical Pencil behavior, a dedicated iPad visual reference, zoom,
and platform-specific palm rejection remain future refinements. Durable offline
drafts remain a separate persistence decision.

## Contract

[Profile scratchpad API](../backend-api/profile-scratchpad.md). No live
collaboration, pixel eraser, server preview/export, or server-managed offline
queue.

## Profile notes update (2026-10-20)

The current home uses multiple titled vector notes per adult or child profile, following the [profile notes API](../backend-api/profile-notes.md). This supersedes the initial adult-only, one-board presentation described above. “New note” creates an independent note; tapping a card edits that note. Existing vector tools, revision checks, and autosave remain in use. The home previews notes in a horizontal list and preserves legacy drawings through backend migration V22.

Note titles are optional: creation opens the editor directly, with a small inline title field sharing drawing autosave. No title dialog is shown. Migration V23 allows untitled notes.
