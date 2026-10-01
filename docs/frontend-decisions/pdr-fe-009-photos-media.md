# PDR-FE-009: Photos and private media

- **Status:** Planned; UX reference pending
- **Backend source:** PDR-07 and PDR-07 photo metadata/tags evolution
- **Depends on:** PDR-FE-004/005; PDR-FE-013 tags; optionally PDR-FE-010 covers

## Outcome

Let family members upload private images and create dated photo memories for a
child. Media assets and photo records have separate lifecycles; upload alone
does not create a record.

## Scope and implementation plan

1. Add media/photo models and multipart/blob API methods.
2. Implement upload progress, returned media ID retention, and authorized image
   loading.
3. Implement photo record create/list/detail/edit/delete by event date.
4. Implement image ordering and per-image add/remove/replace operations; add tag
   assignment and unattached-media recovery.

## Acceptance criteria

- UI never constructs public media URLs or exposes storage paths.
- Uncertain upload/record POSTs are reconciled before retry to avoid duplicates.
- Current API contract limits are followed: 1–4 images per record and at most
  four images for a child's date/report. Older PDR drafts mentioning 20 do not
  override the current contract.
- Deleting a record does not imply media deletion; in-use, quota, and transfer
  failures have recovery paths.
- Images and records remain scoped to the selected family and child.

## UX and open decisions

**UX reference: pending.** Need picker/upload progress, failure/retry, preview,
image ordering, date/description entry, and unattached upload recovery. No video,
public sharing, image editing, or social features.

## Contract

[Photos and media API](../backend-api/photos-media.md).
