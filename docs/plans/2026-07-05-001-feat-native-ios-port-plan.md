---
title: feat: Build native SwiftUI parity app for You Are Sigma
type: feat
status: active
date: 2026-07-05
---

# feat: Build native SwiftUI parity app for You Are Sigma

**Target repo:** `You Are Sigma`

## Summary

Ship a fast native SwiftUI version that feels like the web app, keeps the main joke intact, and rebuilds the needed backend functionality in this repo instead of depending on the web repo’s server. Prioritize working flows over perfect architecture, exhaustive parity, or deep polish.

---

## Problem Frame

The iOS repo is nearly empty. The web repo already has the product and content, but its backend cannot be reused. Fastest path: port the critical app logic from the web repo, rebuild only the backend surfaces needed for chat and photo generation inside this repo, keep storage local, and defer anything that does not block the core fantasy loop.

---

## Assumptions

- Use current web behavior as source of truth, not older prose spec, when they disagree.
- Backend must be rebuilt in this repo and can use the same high-level request/response shapes as the web app for speed.
- API keys will be added later, so backend code can be written assuming provider secrets will exist by runtime.
- Missing avatar/static photo assets can be stubbed with initials/placeholders first, then swapped later.
- “Quick and dirty” means simple local architecture, thin tests, and only enough polish to keep flows usable.

---

## Requirements

- R1. Replace the placeholder iOS app with working Home, Settings, Photos, Messages, Contacts, Thread, and Vault screens.
- R2. Rebuild backend support for health, chat reply, and photo generation inside this repo.
- R3. Keep name, bio, profile photo, and generated photos local on device.
- R4. Preserve the core loop: onboarding/profile setup -> background luxury photos -> celebrity inbox/notifications -> vault flex screen.
- R5. Port enough of the web data/personalization logic that the app feels personalized and funny, even if the internal code structure is not yet ideal.
- R6. Verify the high-risk pieces: data logic, storage, API wiring, and main user flows.

---

## Scope Boundaries

- No dependency on `../you-are-sigma-web/artifacts/api-server/` at runtime.
- No user accounts, auth, cloud sync, remote push notifications, or backend persistence.
- No redesign of current web behavior just to make the native app “cleaner.”
- No heavy refactor/framework work unless needed to unblock shipping.

### Deferred to Follow-Up Work

- Asset automation, App Store hardening, and deep polish.
- Broader test coverage, stronger architecture cleanup, and release-readiness work.
- Hardening the rebuilt backend for production scale, abuse prevention, and observability.

---

## Context & Research

### Relevant Code and Patterns

- iOS app shell: `You Are Sigma/You_Are_SigmaApp.swift`, `You Are Sigma/ContentView.swift`
- Web screens and overlays: `../you-are-sigma-web/artifacts/you-are-sigma/src/pages/`, `../you-are-sigma-web/artifacts/you-are-sigma/src/components/`
- Web state/persistence/generation logic: `../you-are-sigma-web/artifacts/you-are-sigma/src/contexts/settings-context.tsx`, `../you-are-sigma-web/artifacts/you-are-sigma/src/lib/`
- Web backend behavior to mirror, not reuse: `../you-are-sigma-web/lib/api-spec/openapi.yaml`, `../you-are-sigma-web/artifacts/api-server/src/routes/`
- Existing native test harnesses: `You Are SigmaTests/`, `You Are SigmaUITests/`

### Institutional Learnings

- None in repo.

### External References

- None needed. Web repo already gives enough signal.

---

## Key Technical Decisions

- Use one simple app store plus a few helper services instead of over-designing modules up front.
- Store small text in `UserDefaults`; store profile and generated images as files with a tiny Codable index.
- Rebuild the backend in this repo as a small service that mirrors the web contract closely, so the iOS app can stay simple and the old web behavior can be copied with minimal translation.
- Hand-write a thin `URLSession` client and Codable types instead of adding dependencies on the iOS side.
- Port the web logic mostly as direct Swift equivalents first; cleanup later if needed.
- Test only the parts most likely to break silently: deterministic logic, storage, request/response wiring, and one happy-path UI walk.

---

## Open Questions

### Resolved During Planning

- Web implementation wins over older prose spec.
- No external research needed.
- Thread history should stay in-memory only for now, matching web behavior.
- Backend must be rebuilt here, not shared from the web repo.

### Deferred to Implementation

- Lower deployment target only if current one becomes a practical blocker.
- Use Swift literals or JSON for ported content, whichever is faster while staying readable.
- Use placeholders first if final assets are still missing.
- Pick the exact fastest backend runtime for this repo during implementation; bias toward whatever copies web behavior with least friction.

---

## High-Level Technical Design

> *This illustrates the intended approach and is directional guidance for review, not implementation specification. The implementing agent should treat it as context, not code to reproduce.*

```mermaid
flowchart TD
  A[You_Are_SigmaApp] --> B[Root Navigation Shell]
  B --> C[Global App Store]
  C --> D[UserDefaults text state]
  C --> E[File-backed photo stores]
  C --> F[Background look generation coordinator]
  B --> G[Home / Messages / Contacts / Thread / Photos / Settings / Vault]
  G --> H[Ported Swift logic catalogs]
  G --> I[Local API client]
  I --> J[Backend rebuilt in this repo]
  J --> K[/healthz]
  J --> L[/chat/reply]
  J --> M[/photos/generate]
  B --> N[Onboarding overlay]
  B --> O[Live notification overlay]
```

---

## Implementation Units

### U1. Build the native shell and shared plumbing

**Goal:** Replace the hello-world app with a working SwiftUI shell, simple navigation, theme helpers, app store, persistence, and API client hooks.

**Requirements:** R1, R2, R3, R4, R6

**Dependencies:** None

**Files:**
- Modify: `You Are Sigma/You_Are_SigmaApp.swift`
- Modify: `You Are Sigma/ContentView.swift`
- Modify: `You Are Sigma.xcodeproj/project.pbxproj`
- Create: `You Are Sigma/App/RootView.swift`
- Create: `You Are Sigma/Core/AppStore.swift`
- Create: `You Are Sigma/Core/Theme.swift`
- Create: `You Are Sigma/Core/API/AppConfig.swift`
- Create: `You Are Sigma/Core/API/APIClient.swift`
- Create: `You Are Sigma/Core/API/APIModels.swift`
- Create: `You Are Sigma/Core/Persistence/ProfileStore.swift`
- Create: `You Are Sigma/Core/Persistence/GeneratedPhotoStore.swift`
- Test: `You Are SigmaTests/Core/APIModelsTests.swift`

**Approach:**
- Build the minimum native infrastructure once so later screens can land quickly.
- Keep file/folder structure simple and feature-oriented, but do not chase perfect architecture.
- Set up persistence and networking early because every major feature depends on them.

**Patterns to follow:**
- Native shell: `You Are Sigma/You_Are_SigmaApp.swift`
- Contract source to mirror: `../you-are-sigma-web/lib/api-spec/openapi.yaml`
- Runtime behavior to mirror: `../you-are-sigma-web/lib/api-client-react/src/custom-fetch.ts`

**Test scenarios:**
- Happy path: API models decode known health/chat/photo fixtures.
- Error path: JSON error responses decode cleanly.
- Integration: configured base URL can hit a non-local HTTPS server.

**Verification:**
- App no longer shows the Xcode template.
- Root shell can host all target screens plus overlays.

---

### U2. Rebuild the backend in this repo

**Goal:** Create the smallest backend needed for health, chat reply, and photo generation so the app no longer depends on the web repo’s server.

**Requirements:** R2, R6

**Dependencies:** U1

**Files:**
- Create: `backend/`
- Create: `backend/package.json`
- Create: `backend/tsconfig.json`
- Create: `backend/src/server.ts`
- Create: `backend/src/routes/health.ts`
- Create: `backend/src/routes/chat.ts`
- Create: `backend/src/routes/photos.ts`
- Create: `backend/src/lib/openai.ts`
- Create: `backend/src/lib/gemini.ts`
- Create: `backend/.env.example`
- Test: `backend/src/routes/health.test.ts`
- Test: `backend/src/routes/chat.test.ts`
- Test: `backend/src/routes/photos.test.ts`

**Approach:**
- Rebuild only the three endpoints the app needs.
- Mirror the old web contract where practical so the iOS app can use familiar payload shapes.
- Keep backend simple and local to this repo; do not overbuild auth, persistence, or admin surfaces.
- Copy prompt/validation behavior from the web backend where it matters for output quality, but trim anything nonessential for speed.

**Patterns to follow:**
- Contract and route behavior to copy: `../you-are-sigma-web/artifacts/api-server/src/routes/`
- Contract shape to mirror: `../you-are-sigma-web/lib/api-spec/openapi.yaml`

**Test scenarios:**
- Happy path: health route returns success payload.
- Happy path: chat route accepts persona/history/message and returns reply text.
- Happy path: photo route accepts compressed image + prompt and returns base64 image output.
- Error path: malformed payloads return structured error responses.
- Error path: missing provider keys or upstream provider failures surface clear server errors.

**Verification:**
- Native app can point only at backend code in this repo and complete chat/photo flows.

---

### U3. Port the web logic and local profile/photo flows

**Goal:** Port the content/personalization logic and get Settings + Photos fully usable fast.

**Requirements:** R1, R2, R3, R4, R5, R6

**Dependencies:** U1, U2

**Files:**
- Create: `You Are Sigma/Core/Content/Looks.swift`
- Create: `You Are Sigma/Core/Content/People.swift`
- Create: `You Are Sigma/Core/Content/Interests.swift`
- Create: `You Are Sigma/Core/Content/ConversationTemplates.swift`
- Create: `You Are Sigma/Core/Content/Feed.swift`
- Create: `You Are Sigma/Core/Content/FakeData.swift`
- Create: `You Are Sigma/Core/Content/AvatarImages.swift`
- Create: `You Are Sigma/Core/Content/PhotoUtils.swift`
- Create: `You Are Sigma/Features/Settings/SettingsView.swift`
- Create: `You Are Sigma/Features/Photos/PhotosView.swift`
- Create: `You Are Sigma/Features/Photos/PhotoGeneratorSheet.swift`
- Create: `You Are Sigma/Features/Photos/PhotoLightboxView.swift`
- Test: `You Are SigmaTests/Core/FeedTests.swift`
- Test: `You Are SigmaTests/Core/FakeDataTests.swift`
- Test: `You Are SigmaTests/Core/PhotoUtilsTests.swift`

**Approach:**
- Port the web logic almost one-to-one where possible.
- Get photo compression, local storage, background luxury-photo generation, manual generation, and gallery ordering working before chasing visual perfection.
- Allow rougher layouts if needed, but preserve the behavior that makes the feature useful.

**Patterns to follow:**
- Settings state/generation: `../you-are-sigma-web/artifacts/you-are-sigma/src/contexts/settings-context.tsx`
- Logic/data modules: `../you-are-sigma-web/artifacts/you-are-sigma/src/lib/`
- Photos UI behavior: `../you-are-sigma-web/artifacts/you-are-sigma/src/pages/photos.tsx`

**Test scenarios:**
- Happy path: bio -> categories -> people/feed ordering matches expected results.
- Happy path: picked image compresses to JPEG payload under expected limits.
- Edge case: name-only or photo-only profile remains unconfigured.
- Edge case: generated photos sort newest-first and appear before static seeds.
- Error path: missing selfie or missing prompt blocks generation with user-visible error.
- Integration: replacing the selfie during background generation leaves only newest run active.

**Verification:**
- User can set up profile, trigger auto-generation, manually generate more photos, and reopen saved content after relaunch.

---

### U4. Build the joke loop screens: Home, onboarding, notifications, inbox, contacts, thread, vault

**Goal:** Get the rest of the app working end-to-end around the already ported logic and API client.

**Requirements:** R1, R2, R4, R5, R6

**Dependencies:** U1, U2, U3

**Files:**
- Create: `You Are Sigma/Features/Home/HomeView.swift`
- Create: `You Are Sigma/Features/Onboarding/OnboardingGateView.swift`
- Create: `You Are Sigma/Features/Notifications/LiveNotificationView.swift`
- Create: `You Are Sigma/Features/Messages/MessagesView.swift`
- Create: `You Are Sigma/Features/Contacts/ContactsView.swift`
- Create: `You Are Sigma/Features/Thread/ThreadView.swift`
- Create: `You Are Sigma/Features/Vault/VaultView.swift`
- Modify: `You Are Sigma/App/RootView.swift`
- Test: `You Are SigmaTests/Features/ThreadTests.swift`
- Test: `You Are SigmaUITests/QuickSmokeUITests.swift`

**Approach:**
- Keep visuals simple if necessary, but preserve labels, copy, and navigation structure.
- Reuse feed logic for Messages/Contacts/notifications.
- Reuse fake data for Vault rather than overbuilding chart systems; if a chart detail is slow to port, ship a simpler native chart first and match exact styling later.
- Keep thread state in memory only and wire real `/api/chat/reply`.

**Patterns to follow:**
- Home/overlays: `../you-are-sigma-web/artifacts/you-are-sigma/src/pages/home.tsx`, `../you-are-sigma-web/artifacts/you-are-sigma/src/components/`
- Messages/Contacts/Thread: `../you-are-sigma-web/artifacts/you-are-sigma/src/pages/messages.tsx`, `../you-are-sigma-web/artifacts/you-are-sigma/src/pages/contacts.tsx`, `../you-are-sigma-web/artifacts/you-are-sigma/src/pages/thread.tsx`
- Vault: `../you-are-sigma-web/artifacts/you-are-sigma/src/pages/bank.tsx`

**Test scenarios:**
- Happy path: onboarding appears for unconfigured user and routes into Settings.
- Happy path: Messages and Contacts reorder based on bio.
- Happy path: Thread sends user message and appends AI reply.
- Edge case: chat failure leaves user message visible and shows retry error.
- Edge case: notification tap opens Messages.
- Integration: one UI smoke walk covers Home -> Settings -> Photos -> Messages -> Thread -> Contacts -> Vault.

**Verification:**
- Core fantasy loop works end-to-end inside the native app.
- Remaining gaps are mostly polish, missing assets, or exact visual parity.

---

### U5. Add rough assets, polish only what blocks usability, and run a fast verification pass

**Goal:** Make the app feel complete enough to use, even if some assets or styling remain approximate.

**Requirements:** R1, R2, R4, R6

**Dependencies:** U1, U2, U3, U4

**Files:**
- Create: `You Are Sigma/Resources/Fonts/`
- Create: `You Are Sigma/Resources/Avatars/`
- Create: `You Are Sigma/Resources/Photos/`
- Modify: `You Are Sigma/Assets.xcassets/`
- Modify: `You Are Sigma.xcodeproj/project.pbxproj`
- Test: `You Are SigmaUITests/QuickSmokeUITests.swift`

**Approach:**
- Import real assets if available. If not, ship with graceful fallbacks.
- Use simple gold-on-black styling and enough animation to avoid feeling broken.
- Focus verification on one end-to-end smoke path plus the core unit tests from earlier units.

**Patterns to follow:**
- Theme and assets: `../you-are-sigma-web/artifacts/you-are-sigma/src/index.css`, `../you-are-sigma-web/artifacts/you-are-sigma/src/lib/avatar-images.ts`

**Test scenarios:**
- Happy path: app can be launched and navigated through all major screens.
- Edge case: missing avatar/static assets fall back without blank or crashing UI.
- Integration: smoke pass covers launch, profile setup, photo generation entry, inbox, thread, and vault.

**Verification:**
- App works end-to-end without obvious blockers.
- Remaining issues are clearly polish-level, not flow-level.

---

## System-Wide Impact

- Root app store touches almost every feature, so keep it simple and avoid fancy abstractions.
- Storage, generation state, backend/provider integration, and chat requests are the easiest places to ship regressions.
- If time gets tight, preserve working behavior first and exact styling second.

---

## Risks & Dependencies

| Risk | Mitigation |
|------|------------|
| Missing assets block perfect parity | Use placeholders/fallback initials first, swap real assets later |
| Deployment target too new for easy testing | Lower only if it blocks local build/sim work |
| Rebuilt backend takes longer than expected | Keep contract minimal: health, chat, photos only |
| Photo generation can hit rate limits or provider quirks | Keep generation behavior simple and surface failures clearly |
| Ported logic drifts from web behavior | Keep a few high-value golden tests around feed/data/photo logic |
| Plan expands into architecture work | Keep bias toward shipping working screens and revisit cleanup later |

---

## Documentation / Operational Notes

- Keep the API base URL configurable for local simulator, device, and release builds.
- Use the existing `.xcodebuildmcp/config.yaml` and UI test target for a quick simulator smoke pass.
- Record any major shortcuts taken so cleanup work is obvious later.

---

## Sources & References

- User request and attached native-port requirements in this session
- Related code: `You Are Sigma/You_Are_SigmaApp.swift`
- Related code: `You Are Sigma/ContentView.swift`
- Related code: `../you-are-sigma-web/artifacts/you-are-sigma/src/App.tsx`
- Related code: `../you-are-sigma-web/artifacts/you-are-sigma/src/contexts/settings-context.tsx`
- Related code: `../you-are-sigma-web/artifacts/you-are-sigma/src/pages/home.tsx`
- Related code: `../you-are-sigma-web/artifacts/you-are-sigma/src/pages/settings.tsx`
- Related code: `../you-are-sigma-web/artifacts/you-are-sigma/src/pages/photos.tsx`
- Related code: `../you-are-sigma-web/artifacts/you-are-sigma/src/pages/messages.tsx`
- Related code: `../you-are-sigma-web/artifacts/you-are-sigma/src/pages/contacts.tsx`
- Related code: `../you-are-sigma-web/artifacts/you-are-sigma/src/pages/thread.tsx`
- Related code: `../you-are-sigma-web/artifacts/you-are-sigma/src/pages/bank.tsx`
- Related code: `../you-are-sigma-web/artifacts/you-are-sigma/src/components/OnboardingGate.tsx`
- Related code: `../you-are-sigma-web/artifacts/you-are-sigma/src/components/LiveNotification.tsx`
- Related code: `../you-are-sigma-web/artifacts/you-are-sigma/src/lib/people.ts`
- Related code: `../you-are-sigma-web/artifacts/you-are-sigma/src/lib/interests.ts`
- Related code: `../you-are-sigma-web/artifacts/you-are-sigma/src/lib/conversation-templates.ts`
- Related code: `../you-are-sigma-web/artifacts/you-are-sigma/src/lib/feed.ts`
- Related code: `../you-are-sigma-web/artifacts/you-are-sigma/src/lib/personalize.ts`
- Related code: `../you-are-sigma-web/artifacts/you-are-sigma/src/lib/looks.ts`
- Related code: `../you-are-sigma-web/artifacts/you-are-sigma/src/lib/fake-data.ts`
- Related code: `../you-are-sigma-web/artifacts/you-are-sigma/src/lib/avatar-images.ts`
- Related code: `../you-are-sigma-web/artifacts/you-are-sigma/src/lib/photo-utils.ts`
- Related code: `../you-are-sigma-web/artifacts/you-are-sigma/src/lib/user-settings.ts`
- Related code: `../you-are-sigma-web/artifacts/you-are-sigma/src/lib/generated-photos.ts`
- Related code: `../you-are-sigma-web/artifacts/you-are-sigma/src/lib/idb.ts`
- Related code: `../you-are-sigma-web/artifacts/you-are-sigma/src/index.css`
- Related code: `../you-are-sigma-web/artifacts/api-server/src/routes/chat.ts`
- Related code: `../you-are-sigma-web/artifacts/api-server/src/routes/photos.ts`
- Related code: `../you-are-sigma-web/artifacts/api-server/src/routes/health.ts`
- Related code: `../you-are-sigma-web/lib/api-spec/openapi.yaml`
- Related code: `../you-are-sigma-web/lib/api-zod/src/generated/types/`
