# PDR-FE-002: Localization and regional formatting

- **Status:** Accepted for initial implementation
- **Date:** 2026-09-30
- **Scope:** Interface language, backend message language, and regional display

## Context

The backend contracts support English (`en`), Portuguese (`pt`), and Spanish
(`es`) messages. Regional preferences such as `pt-BR` are accepted with a
language fallback. User-entered names, notes, titles, and other family content
are not translated. Dates and wall times may be family-timezone values rather
than device-local values.

## Decisions

- Use Flutter's generated localization support with ARB resources and
  `flutter_localizations`; use `intl` for locale-aware formatting and plural
  rules. Keep source identifiers and filenames in English, as required by the
  constitution.
- Initial supported interface locales are Brazilian Portuguese (`pt-BR`),
  English (`en`), Spanish (`es`), and Estonian (`et`, with `et-EE` regional
  formatting). Portuguese is the fallback when neither a saved choice nor a
  supported device locale is available. An explicit saved choice takes priority
  over the device locale.
- Store only the user's explicit locale override in simple preferences. If no
  override exists, resolve from the device's supported locale; do not persist a
  one-time device-derived choice.
- Send `Accept-Language` on every API request. Map `pt-BR` to `pt`, `en` to
  `en`, and `es` to `es`. The backend does not currently support Estonian, so
  map `et` to `en` for backend-owned messages until its API localization adds
  Estonian. Frontend-owned UI strings are translated in all four locales.
  Never branch on translated backend text; use stable API error codes.
- Localize all frontend-owned labels, validation, empty/loading/error states,
  accessibility labels, date/time labels, and plural forms. Do not translate
  user-authored content or API identifiers/enums.
- Keep calendar dates (`YYYY-MM-DD`) as date-only values. Do not parse them as
  UTC instants or shift them through the device timezone. For planning and daily
  execution, use the family's IANA timezone for “today” and wall times, as
  required by the backend contract. Use the interface locale only to format the
  displayed date/time text.
- Format audit/event instants using an explicitly chosen display timezone for
  the view. Unless a feature's contract requires family time, show instants in
  the device timezone and label dates that are family-local. Never change the
  stored API date/time representation during formatting.
- Translation resources are reviewed together across all supported locales.
  Adding a locale requires complete coverage for the initial app shell and a
  decision about its backend `Accept-Language` value.

## Consequences

The app UI and backend-owned messages start in the same selected language.
Flutter locale drives phrasing and formatting; family timezone independently
drives family calendar semantics. This prevents a device in another timezone
from moving a plan or completion to the wrong day.

The frontend may need to map server validation errors that lack a stable field
code to a localized generic field message while still showing any localized
server `detail` where appropriate. Unsupported framework errors remain safe,
localized generic UI failures.

## Initial implementation acceptance criteria

- The root app registers the generated localization delegates and all four
  supported locales.
- Locale resolution follows saved override, supported device locale, then
  Portuguese fallback.
- A locale change updates the app immediately and persists only the explicit
  override.
- API requests send a matching `Accept-Language`, including regional Portuguese.
- Date-only API fields remain unchanged across device timezone changes; family
  day boundaries use the family's IANA timezone.
- All first-shell strings exist in all four locales; no user-facing string is
  added inline in a feature view.

## Implementation progress

### Interface language — 2026-10-01

- Tablet and desktop/Web layouts (at least 600 logical pixels wide) provide a
  compact flag menu at the top right for all four locales and an option to
  follow the device language. Mobile language selection belongs exclusively
  in Settings, which has not been implemented yet; the mobile shell has no
  language selector.
- Explicit choices update the interface immediately and are stored as language
  tags. Returning to the device language removes the stored override. Device
  locale changes are observed while the app runs and respect explicit overrides.
- A failed preference write restores the previous choice and displays a
  localized message inviting the user to select the language again.
- Tests cover resolution, regional override restoration, persistence and
  removal, device changes, save failure and retry, shell interaction, and the
  API client's use of the current backend language on each request.
- Remaining work: regional date/time formatting (including `et-EE`), date-only
  values, family IANA timezone boundaries and wall times, explicit instant
  display timezone handling, and plural resources when count-based UI is added.

## References

- [Product overview](../product-overview.md)
- [Family timezone contract](../backend-api/families.md#family-timezone)
- [Planning date and time contract](../backend-api/planning.md#authentication-and-formats)
- [Authentication localization contract](../backend-api/authentication.md#connection-and-headers)
- [Flutter internationalization guide](https://docs.flutter.dev/ui/internationalization)
