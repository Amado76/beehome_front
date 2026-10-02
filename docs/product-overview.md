# Product Overview

## Product

Nosso Dia is a digital family notebook for organizing family life and children's daily routines. It brings together homeschool and studies, daily notes, photo records, books, and periodic reports. Children should be able to see and complete their activities with little navigation; adults have additional tools for setup, organization, and oversight.

The product should feel warm, playful, and family-oriented, not like a corporate
productivity dashboard. Use soft pastels, rounded shapes, restrained shadows,
and hand-drawn illustrations while keeping content clear and easy to use.

## Platforms and experience

- Build the frontend with Flutter for iOS, Android, and Web.
- Prioritize tablet use in landscape orientation, then Web, then mobile, following the product's design mockups.
- Support mobile and desktop/web layouts where needed.
- A layout may use a distinct composition for each size class when rearranging one widget tree would harm the experience. Shared behavior and smaller components should be reused where practical.
- Choose layouts based on available logical width rather than device identity.

Initial width guidance:

| Layout | Available width |
| --- | --- |
| Mobile | Below 600 logical pixels |
| Tablet | 600–1199 logical pixels |
| Desktop | 1200 logical pixels and above |

These values may be refined through implementation and real-device evaluation.

## Localization

The initial interface supports Brazilian Portuguese (`pt-BR`), English (`en`),
Spanish (`es`), and Estonian (`et`, including Estonian regional formatting).
Use the saved user choice when present, otherwise a supported device locale, and
fall back to Brazilian Portuguese. Backend-owned messages currently support
English, Portuguese, and Spanish; requests made with the Estonian interface use
English backend messages until the API adds Estonian translations. See
[PDR-FE-002](frontend-decisions/pdr-fe-002-localization.md).

## Functional color

The adult experience is primarily monochrome. Each child chooses a pastel completion color. A pending activity appears gray; when completed, it takes that child's color. Color communicates state and must not be the only way important information is conveyed.
