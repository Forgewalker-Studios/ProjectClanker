# AI Assistance Log

## 2026-06-22 - Windows and Web itch.io release

- **Model/tool used:** Cursor Agent (Claude); Godot 4.6.1 headless export; itch.io Butler.
- **Task purpose:** Export Windows and HTML5 builds, publish to itch.io, and push source without build artifacts.
- **Input materials used:** Existing Windows export preset, itch.io project page, uncommitted HUD and menu scene edits, and Butler credentials on the local machine.
- **AI produced:** Web export preset, reorganized Windows export path, release version bump, export preset tests, Butler uploads, and git push excluding `Build/`.
- **User accepted:** Requested dual-platform build, Butler deploy, and git push with build files excluded from commit.
- **User rejected:** None.
- **User changed:** None.
- **Final approval:** Pending human playtest of exported Windows and browser builds.

## 2026-06-22 - Detailed asset credits

- **Model/tool used:** OpenAI Codex, GPT-5 coding agent; PDF text extraction and rendering; itch.io source pages.
- **Task purpose:** Inventory shipped assets and provide detailed player-facing attribution.
- **Input materials used:** Repository assets, import/use references, bundled licenses and readmes, itch receipts and source pages, existing credits UI, and user-provided production roles.
- **AI produced:** Scrollable categorized game credits, expanded provenance and license register, required-attribution regression tests, and synchronized feature version metadata.
- **User accepted:** Need for substantially more detailed asset credits; final wording and licensing decisions remain pending live review.
- **User rejected:** None.
- **User changed:** None.
- **Final approval:** Pending human confirmation of undocumented asset provenance and conflicting license metadata before release.

## 2026-06-22 - Non-blocking hub route triggers

- **Model/tool used:** OpenAI Codex, GPT-5 coding agent
- **Task purpose:** Prevent locked hub doors from blocking travel to other ground-level routes.
- **Input materials used:** User runtime report, hub route scene geometry, HubRoute behavior, ScenePortal abstraction, and progression thresholds.
- **AI produced:** Area2D-based route inheritance, non-solid locked routes, direct shared portal configuration, tests, and synchronized patch version metadata.
- **User accepted:** Requested conversion of hub doors from rigid collision bodies to areas; final behavior pending live review.
- **User rejected:** None.
- **User changed:** None.
- **Final approval:** Pending human hub traversal and route transition testing.

## 2026-06-22 - Dialogue completion input fix

- **Model/tool used:** OpenAI Codex, GPT-5 coding agent
- **Task purpose:** Stop D0R1 dialogue from immediately restarting when the final line is closed with E.
- **Input materials used:** User runtime report and the Player, DialogueBox, DialogueController, and D0R1 input flow.
- **AI produced:** Interaction release latch, keyboard-repeat guard, regression test, and synchronized patch version metadata.
- **User accepted:** Requested correction of the end-of-dialogue loop; final behavior pending live review.
- **User rejected:** None.
- **User changed:** None.
- **Final approval:** Pending human dialogue playtest.

## 2026-06-22 - Hub presentation and route accessibility

- **Model/tool used:** OpenAI Codex, GPT-5 coding agent
- **Task purpose:** Fix unreadable hub overlays, give the hub level-style background art, and make every hub route reachable from the floor.
- **Input materials used:** User-provided hub screenshot, hub/UI scenes and scripts, authored level background component, player movement constraints, and route collision geometry.
- **AI produced:** Separated styled HUD panels, dialogue-aware prompt suppression, level parallax background integration, grounded route layout, player spawn adjustment, tests, and rendered hub QA capture.
- **User accepted:** Requested overlay readability, hub background parity, and ground-level route accessibility; final presentation pending review.
- **User rejected:** None.
- **User changed:** None.
- **Final approval:** Pending human live hub and transition testing.

## 2026-06-22 - Main menu UI polish

- **Model/tool used:** OpenAI Codex, GPT-5 coding agent
- **Task purpose:** Improve main-menu presentation and fix unreadable overlapping Settings UI shown in the user screenshot.
- **Input materials used:** User-provided screenshot, existing MainMenu scene/script, project color direction, and Godot-native UI components.
- **AI produced:** Industrial menu theme, gradient background, framed menu card, styled controls, opaque modal panels, background scrim, focus handling, Escape dismissal, tests, and rendered QA captures.
- **User accepted:** General request to polish the UI; final visual presentation pending review.
- **User rejected:** None.
- **User changed:** None.
- **Final approval:** Pending human review of the rendered and live UI.

## 2026-06-22 - Playable route and export configuration

- **Model/tool used:** OpenAI Codex, GPT-5 coding agent
- **Task purpose:** Resolve identified release blockers by wiring hub and region portals and configuring a Windows export.
- **Input materials used:** Authored hub and region scenes, progression states, scene-transition service, GDD route order, and Godot export configuration.
- **AI produced:** Reusable scene portal behavior, complete portal target wiring, progression updates, final-dialogue completion and dismissal, Windows Desktop export preset, macOS metadata import exclusion, tests, and version updates.
- **User accepted:** Implementation of the previously identified hub, `MoveTo*`, and export-preset blockers.
- **User rejected:** None.
- **User changed:** None.
- **Final approval:** Pending human live-route and exported-build testing.

## 2026-06-22 - Production credits

- **Model/tool used:** OpenAI Codex, GPT-5 coding agent
- **Task purpose:** Add production credits to the player-visible main menu and project documentation.
- **Input materials used:** User-provided studio, producer, writer, and director credits; existing main-menu overlay pattern.
- **AI produced:** Credits button and panel, menu wiring, README credits section, and synchronized version metadata.
- **User accepted:** The exact production credit names and roles supplied in the request.
- **User rejected:** None.
- **User changed:** None.
- **Final approval:** Pending human review of presentation and release inclusion.

## 2026-06-22 - Release-readiness review and enemy bug fixes

- **Model/tool used:** OpenAI Codex, GPT-5 coding agent
- **Task purpose:** Review release readiness; fix excessive enemy pursuit range and enemies running beyond floor collision edges.
- **Input materials used:** Repository source, scenes, resources, project configuration, version history, and user-provided known bug descriptions.
- **AI produced:** Release audit findings; shorter pursuit tuning; a forward floor ray query; behavior integration; regression coverage and fixture repair; a unique Region 02 scene UID; restored D0R1 hub actor and corrected dialogue binding; version and documentation updates.
- **User accepted:** Pending human review.
- **User rejected:** Pending human review.
- **User changed:** Pending human review.
- **Final approval:** Pending; AI output is not a release decision.
