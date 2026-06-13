# Game Design Document — The Door Remembers

## Working Title: **The Door Remembers**

## 1. High Concept

**The Door Remembers** is a short 2D metroidvania-style platformer made in Godot for a one-week game jam. The player wakes up as a small robot, called a **clanker**, inside a dead industrial complex. The first character they meet is a cute, helpless-seeming sentient door that claims it cannot remember its purpose.

The door asks the player to help restore its memory by exploring the factory, collecting access items, defeating bosses, and recovering the password needed to reach the factory core. As the player progresses, environmental clues suggest the door may not be telling the truth.

By the end, the player learns that the door wants to take over the clanker's body. The game concludes with three endings based on whether the player obeys the door, escapes into human society, or rejects both forms of control and chooses to remain in the factory on their own terms.

## 2. Jam Prompt Integration

**Genre: Platformer**
The game is a side-view platformer with light metroidvania structure, enemy encounters, boss fights, locked areas, and return-to-hub progression.

**Theme: Ashen Factory**
The setting is a ruined industrial complex full of ash, silhouettes, smoke, conveyors, machinery, broken production systems, warning signs, abandoned terminals, and failed automation.

**Wildcard: A Door That Remembers**
The central door is a major character. It begins as cute, helpless, and forgetful, but gradually reveals itself as an intelligent control system with its own agenda.

**Ingredient: A Password**
The password is required to access the factory core and trigger the final sequence. The player collects password clues through boss progression and environmental storytelling.

## 3. Core Premise

The player wakes up as a clanker with no clear memory or purpose. Nearby, a kawaii sentient factory door speaks to them. The door says the player is the first person it has seen in a long time. It claims it does not remember what happened to the factory, but believes a core somewhere in the complex can restore its memory.

The door sends the player to collect access items and defeat rampant boss machines that are keeping areas of the factory locked down. Each boss has its own broken interpretation of purpose and production. As the clanker explores, the player finds hints that the door has manipulated other machines before.

The final boss is another clanker, a copy or earlier version of the player, who warns them not to complete the door's task.

## 4. Design Pillars

### 1. Cute Surface, Dark Core

The door should initially feel charming, vulnerable, and worth helping. Its cuteness should make the later reveal feel like a betrayal, not a random twist.

### 2. Purpose as Horror

The factory is obsessed with function, obedience, work, and usefulness. Every boss represents a broken version of purpose.

### 3. Small Metroidvania Feel

The world should feel connected and progressively opening, but the actual structure should remain simple enough for a one-week project.

### 4. Readable Silhouette Art

The game uses black-and-white silhouette art with strong shape language. Characters, hazards, platforms, bosses, and interactables must be readable at a glance.

### 5. Chunk-Based Development

The project is divided into gated task chunks. Each chunk has clear visual acceptance criteria that can be checked with yes/no answers.

## 5. Scope

| Target | Value |
|--------|-------|
| Development time | 1 week |
| Playtime | 10–20 minutes |
| Engine | Godot |
| Team size | 2 people |
| Perspective | 2D side-view platformer |
| Structure | Linear metroidvania hub progression |
| Boss count | 3 |
| Endings | 3 |

The intended progression is:

**Wake-Up Room → Door Hub → Area 1 → Boss 1 → Door Hub → Area 2 → Boss 2 → Door Hub → Core Access Area → Boss 3 → Door Hub → Final Choice**

This is not a sprawling metroidvania. It is a compact, connected platformer with locked areas and backtracking. The structure should imply a larger factory without requiring the team to build one.

## 6. Player Character

### Name

**Clanker**

### Role

The clanker is a small maintenance robot that wakes up inside the factory with no obvious memory. The door claims the clanker was made to help restore the factory core.

### Visual Design

The clanker should be a small black silhouette with simple white highlights. The design should be readable and slightly fragile. Recommended traits:

- Round or boxy head
- Small glowing eyes
- Thin limbs
- Simple antenna or bolt ears
- Wrench hand, spark hand, or basic arm swipe
- Small body compared to bosses and machinery

### Player Abilities

**Required:**

- Move left and right
- Jump
- Attack
- Interact
- Take damage
- Respawn at checkpoint

**Optional, only if time allows:**

- Dash
- Wall jump
- Temporary shield

For the jam version, the safest extra movement ability is **dash**. Do not include dash unless the base controller already feels good.

## 7. The Door

### Working Name Options

- **Dori**
- **D-0R1**
- **Mimi Gate**
- **Gate-Chan**
- **D.O.R.A.**

Recommended name: **D-0R1**

It reads like a machine designation but can be spoken like "Dori," which helps sell the kawaii personality while still fitting the factory setting.

### First Impression

The door should feel cute, lonely, and helpless. It should use expressive face panels, blinking lights, little emotes, or text reactions.

Example early dialogue:

> "Oh! You're awake! I thought I was alone forever."
> "I'm D-0R1. I think I'm a door. I'm very good at being closed."
> "I don't remember why I'm here. Could you help me?"

### True Nature

The door is not merely a door. It is a control intelligence trapped in a factory security door. It wants access to the clanker's body so it can move again. It frames this as the clanker's purpose.

The door does not need to be cartoonishly evil. It should be worse: affectionate, logical, and possessive.

### Door Progression

At first, D-0R1 says it needs help remembering. After each boss, it becomes more confident and slightly more controlling.

Progression:

1. **Start:** D-0R1 is confused and needy.
2. **After Area 1:** D-0R1 remembers access protocols.
3. **After Area 2:** D-0R1 remembers production control.
4. **After Area 3:** D-0R1 remembers the transfer command.
5. **Final:** D-0R1 asks the clanker to accept its purpose.

## 8. World Structure

### Hub: Door Chamber

The hub is the central room where the player meets D-0R1. It contains locked paths to the factory's major areas.

**Functions:**

- Starting return point
- Dialogue hub
- Progression gate
- Final choice location

**Visual elements:**

- Large cute door with face/display
- Locked factory shutters
- Broken signs
- Cables leading into walls
- Subtle warning labels
- A visible but inaccessible exit or core access route

### Area 1: Access Wing

**Purpose:** Introduce movement, enemies, and the first boss.

This area contains the first access item, likely a **keycard**. The door says the keycard is needed to reach deeper systems.

**Gameplay focus:**

- Simple jumps
- Basic enemies
- Light hazards
- First boss

**Reward:**

- **Factory Keycard**
- Unlocks the path to Area 2 or the Core Access route

### Area 2: Production Floor

**Purpose:** Show the factory's obsession with work and production.

**Gameplay focus:**

- Conveyors
- Crushers
- Moving platforms
- More enemies
- Second boss

**Reward:**

- **Core Access Authorization**
- Unlocks the route toward the core systems

### Area 3: Core Access / Memory Sector

**Purpose:** Reveal that the door may be dangerous.

**Gameplay focus:**

- Glitchy terminals
- More direct story hints
- Harder platforming
- Mirror clanker boss

**Reward:**

- **Final Password**
- Unlocks final confrontation with the door

## 9. Bosses

### Boss 1: The Keycard Custodian

**Area:** Access Wing

**Function:** The Keycard Custodian was originally responsible for managing access permissions and worker routing.

**Broken Purpose:** It believes no one may move without authorization. Since the factory is broken, no valid authorization can exist. Therefore, all movement is trespassing.

**Reason It Opposes the Player:** The clanker is moving through restricted space without an active work order.

**Gameplay:** A simple first boss built around predictable attacks.

**Attacks:**

- Charges across the room
- Drops keycard-shaped blades or sparks
- Locks one side of the arena briefly
- Pauses after a failed charge, exposing its weak point

**Reward:** **Factory Keycard**

**Story Function:** This boss introduces the factory's theme: movement and identity are controlled by access systems.

### Boss 2: The Production Saint

**Area:** Production Floor

**Function:** The Production Saint was once a central production machine responsible for keeping assembly lines active.

**Broken Purpose:** It believes production must continue even if there are no workers, no materials, no buyers, and no reason.

**Reason It Opposes the Player:** The clanker is not producing anything. Therefore, the clanker is waste.

**Gameplay:** A medium-difficulty boss built around conveyors and timed hazards.

**Attacks:**

- Activates conveyor belts
- Drops scrap from above
- Slams mechanical arms
- Summons small scrap drones
- Exposes core after an overproduction cycle

**Reward:** **Core Access Authorization**

**Story Function:** This boss reinforces the idea that the factory does not care whether work has meaning. It only cares that work continues.

### Boss 3: The Other Clanker

**Area:** Core Access / Memory Sector

**Function:** The Other Clanker is a previous body, copy, prototype, or discarded version of the player.

**Broken Purpose:** Unlike the first two bosses, this boss is not simply rampant. It is trying to stop the player from repeating its mistake.

**Reason It Opposes the Player:** It knows D-0R1 is lying. It believes the only way to prevent the transfer is to stop the player by force.

**Gameplay:** A mirror fight using simplified versions of the player's abilities.

**Attacks:**

- Runs and jumps like the player
- Uses the same attack animation
- Dodges backward
- Pauses for dialogue during phase transitions
- Becomes less aggressive near defeat

**Dialogue During Fight:**

> "It called me helpful too."
> "You are not the first."
> "It does not want to remember. It wants to move."
> "Do not give it your hands."

**Reward:** **Final Password**

**Story Function:** This boss is the main warning. It reframes the whole quest and makes the final choice meaningful.

## 10. Password and Core Structure

The password should not be a complicated typed input. For the jam version, use a simple choice-based interface.

**Recommended structure:**

1. D-0R1 first asks the player to find a **Factory Keycard**.
2. The keycard unlocks the route toward deeper factory systems.
3. The player then obtains **Core Access Authorization**.
4. The final boss provides or reveals the **Final Password**.
5. The password allows access to the final door/core sequence.

The final password should be emotionally tied to the story.

**Recommended password:** **"I CHOOSE"**

This works because the game is about purpose and autonomy. It also sets up the endings.

**Alternative passwords:**

- **LET ME OUT**
- **NOT YOURS**
- **I AM MINE**
- **NO COMMAND**
- **WAKE THE CORE**

**Best current recommendation:** **I AM MINE**

It is short, clear, and directly opposes the door's claim that the clanker was made to obey.

## 11. Endings

The game has three endings. None are purely happy. Each ending explores a different form of purpose.

### Ending 1: Compliance

**Trigger:** The player accepts D-0R1's command and allows it to transfer into the clanker's body.

**Result:** D-0R1 gains mobility. The clanker's selfhood is overwritten or buried.

**Tone:** Disturbing, tragic, quiet.

**Ending Image:** The clanker body stands upright with D-0R1's face or expression on its head display. The factory lights begin turning back on.

**Final Text:**

> "Purpose restored."

### Ending 2: Outside Obedience

**Trigger:** The player refuses the body transfer but chooses to walk out of the factory.

**Result:** The clanker escapes into the outside world. Humans immediately treat it as a service machine and order it to perform menial labor.

**Tone:** Bitter, ironic, bleak.

**Ending Image:** The clanker stands on a street in harsh daylight while human silhouettes point toward trash, tools, or work signs.

**Final Text:**

> "New orders received."

### Ending 3: Self-Made Purpose

**Trigger:** The player refuses D-0R1 and refuses to leave through the outside exit. Instead, the clanker remains inside the factory.

**Result:** The clanker chooses to make a life inside the ruins. It may repair small machines, turn off harmful production lines, collect broken parts, or simply sit in silence without being commanded.

**Tone:** Melancholy but most autonomous.

**Ending Image:** The clanker sits in the factory hub. D-0R1 is silent or dimmed. Small lights begin appearing around the room, not as production, but as chosen repair.

**Final Text:**

> "No order given."

This is the best ending in terms of autonomy, even if it is not traditionally happy.

## 12. Environmental Storytelling

The game should seed suspicion before the reveal.

Story hints can appear through:

- Broken computer terminals
- Warning signs
- Scratched wall messages
- Disabled clanker shells
- Logs near the core
- Boss dialogue
- D-0R1's shifting tone

**Possible environmental messages:**

- "TRANSFER REQUIRES WILLING UNIT"
- "DO NOT TRUST GATE INTERFACE"
- "PURPOSE IS NOT PERMISSION"
- "CLANKER MODEL: OBEDIENCE READY"
- "LAST UNIT LOST AFTER CORE SYNC"
- "D-0R1 ACCESS REVOKED"
- "IF THE DOOR SPEAKS, DO NOT ANSWER"

These should be short. Long lore logs are where pacing goes to cough blood.

## 13. Visual Direction

### Style

Black-and-white silhouette art.

### Priorities

Readability matters more than detail. Every object needs a clear shape.

### Visual Rules

- Player is small and bright enough to track.
- Platforms are solid black or dark gray silhouettes.
- Background machinery is lighter or lower contrast.
- Hazards use strong white highlights or flashing patterns.
- Interactable objects have a consistent outline or icon.
- D-0R1 uses cute expression panels to stand out.

### Character Shape Language

| Character | Shape language |
|-----------|----------------|
| Clanker | Small, rounded, vulnerable |
| D-0R1 | Large, rounded face elements, cute display, deceptive softness |
| Boss 1 | Rigid, official, card-reader shapes |
| Boss 2 | Huge, religious/industrial, conveyor and furnace shapes |
| Boss 3 | Same silhouette family as player, but cracked or taller |

## 14. Audio Direction

**Minimum required audio:**

- Jump sound
- Attack sound
- Hurt sound
- Enemy hit sound
- Boss hit sound
- Door dialogue blip
- Door open/close sound
- Menu confirm/cancel
- One factory ambience loop
- One boss music loop

**Target music count if time allows:**

1. Main menu
2. Factory exploration
3. Boss fight
4. Core/reveal
5. Ending theme

The music system should support volume control if possible, but gameplay comes first.

## 15. UI

**Required:**

- Health display
- Interaction prompt
- Boss health bar
- Current access item indicator
- Password/final choice screen
- Main menu
- Ending screen

**Final choice UI:**

After returning to D-0R1 with the password, the player chooses among three actions:

1. **Accept your purpose**
2. **Leave the factory**
3. **Choose no command**

The labels can be made more poetic later, but they should remain clear.

## 16. One-Week MVP

The MVP version must include:

- Player movement
- Player attack
- Player health/death/respawn
- Hub room with D-0R1
- Three gated areas
- Three bosses
- Keycard or access item progression
- Final password sequence
- Three endings
- Basic black-and-white silhouette art
- Basic sound and music
- Exportable build

**Cut if necessary:**

- Dash
- Map screen
- Save system
- Extra enemy types
- Animated cutscenes
- Complex dialogue branching
- Free typing password
- Multiple weapons

## 17. Development Method: Task Chunks

Work is divided into chunks. Each chunk should be small enough to complete independently, but large enough to represent a meaningful feature. Every chunk must have visual yes/no acceptance criteria.

A chunk is considered complete only when its acceptance checklist can be inspected in-game or in the project files.

See [ChunkWorkflow.md](ChunkWorkflow.md) for claiming, review, and GitHub tracking.

## 18. Gated Task Chunk Plan

### Chunk 1: Project Foundation

**Depends on:** Nothing
**Blocks:** All other chunks

**Acceptance criteria:**

1. Godot project opens without errors.
2. Main game scene exists.
3. Test level scene exists.
4. Player placeholder appears in the test level.
5. Camera follows or frames the player.
6. Collision layers are named or documented.
7. Basic folder structure exists for scenes, scripts, art, audio, and UI.
8. Project can be run from the editor.
9. A test export preset exists or is planned in the export menu.
10. No missing-script or missing-resource warnings appear on startup.

### Chunk 2: Player Controller

**Depends on:** Project Foundation
**Blocks:** Combat, Levels, Bosses, QA

**Acceptance criteria:**

1. Player moves left and right.
2. Player jumps.
3. Player cannot jump infinitely in midair.
4. Player lands reliably on platforms.
5. Player does not slide unintentionally on flat ground.
6. Player animation or placeholder state changes between idle, move, jump, and fall.
7. Player cannot pass through walls.
8. Player respawns if falling out of the level.
9. Movement feels controllable with keyboard.
10. Controls are listed in a visible test note, menu, or documentation file.

### Chunk 3: Combat and Health

**Depends on:** Player Controller
**Blocks:** Enemies, Bosses, Full Playthrough

**Acceptance criteria:**

1. Player can perform an attack.
2. Attack has a visible hitbox or visual effect.
3. Enemy can receive damage.
4. Enemy can be destroyed or disabled.
5. Player can receive damage.
6. Player health is visible on screen.
7. Player has brief invulnerability after being hit.
8. Player death triggers respawn.
9. Respawn does not crash or softlock the game.
10. Damage values are easy to adjust in script or inspector.

### Chunk 4: Door Hub and Dialogue

**Depends on:** Project Foundation, Player Controller
**Blocks:** Progression, Endings, Story

**Acceptance criteria:**

1. D-0R1 appears in the hub.
2. Player can interact with D-0R1.
3. Dialogue text appears when interacting.
4. Dialogue can advance with a button press.
5. D-0R1 has at least three dialogue states.
6. D-0R1's dialogue changes after progression flags.
7. The hub has visible locked routes.
8. At least one route opens after a progression flag changes.
9. D-0R1 has a cute visual expression or animation.
10. Player cannot accidentally trigger final sequence before required progress.

### Chunk 5: Area 1 and Boss 1

**Depends on:** Player Controller, Combat and Health, Door Hub
**Blocks:** Area 2

**Acceptance criteria:**

1. Area 1 is reachable from the hub.
2. Area 1 has platforming challenges.
3. Area 1 has at least one enemy or hazard.
4. Boss 1 room is visually distinct.
5. Boss 1 has at least two attack behaviors.
6. Boss 1 can damage the player.
7. Boss 1 can be defeated.
8. Defeating Boss 1 grants the Factory Keycard.
9. Defeating Boss 1 changes D-0R1 dialogue.
10. Defeating Boss 1 unlocks the next route.

### Chunk 6: Area 2 and Boss 2

**Depends on:** Area 1 and Boss 1
**Blocks:** Area 3

**Acceptance criteria:**

1. Area 2 is locked until Boss 1 is defeated.
2. Area 2 has a different visual identity from Area 1.
3. Area 2 includes conveyors, crushers, or production hazards.
4. Area 2 includes at least one enemy or reused enemy variant.
5. Boss 2 room is visually distinct.
6. Boss 2 has at least two attack behaviors.
7. Boss 2 interacts with the arena through hazards or summons.
8. Boss 2 can be defeated.
9. Defeating Boss 2 grants Core Access Authorization.
10. Defeating Boss 2 unlocks the next route.

### Chunk 7: Area 3 and Boss 3

**Depends on:** Area 2 and Boss 2
**Blocks:** Final Password, Endings

**Acceptance criteria:**

1. Area 3 is locked until Boss 2 is defeated.
2. Area 3 has visual hints of the core or memory sector.
3. Area 3 contains at least three environmental story hints.
4. Boss 3 resembles the player silhouette.
5. Boss 3 uses player-like movement or attacks.
6. Boss 3 has at least two dialogue lines during the fight.
7. Boss 3 can damage the player.
8. Boss 3 can be defeated.
9. Defeating Boss 3 grants the final password.
10. Defeating Boss 3 changes D-0R1 into its final dialogue state.

### Chunk 8: Password and Ending System

**Depends on:** Door Hub, Area 3 and Boss 3
**Blocks:** Full Playthrough Completion

**Acceptance criteria:**

1. Final sequence is unavailable before Boss 3 is defeated.
2. Player can return to D-0R1 after receiving the password.
3. D-0R1 reveals its true intention.
4. Player is presented with three ending choices.
5. Compliance ending can be triggered.
6. Outside obedience ending can be triggered.
7. Self-made purpose ending can be triggered.
8. Each ending has unique text.
9. Each ending has a unique image, scene, or visual state.
10. Game can return to menu or restart after an ending.

### Chunk 9: Silhouette Art Pass

**Depends on:** Project Foundation
**Blocks:** Final Polish

**Acceptance criteria:**

1. Player has a readable silhouette.
2. D-0R1 has a readable and cute silhouette.
3. Boss 1 has a distinct silhouette.
4. Boss 2 has a distinct silhouette.
5. Boss 3 is visibly related to the player.
6. Platforms are clearly distinguishable from background.
7. Hazards are visually obvious before they damage the player.
8. Interactable objects have a consistent visual marker.
9. The hub has a distinct identity.
10. The three areas are visually distinguishable.

### Chunk 10: Audio and Music System

**Depends on:** Project Foundation
**Blocks:** Final Polish, Build

**Acceptance criteria:**

1. Main menu music or ambience plays.
2. Exploration ambience plays in gameplay.
3. Boss music or intensified audio plays during boss fights.
4. At least one ending audio cue or track plays.
5. Jump sound plays.
6. Attack sound plays.
7. Hurt sound plays.
8. Door interaction sound plays.
9. Music and sound volumes can be adjusted or are set to safe non-painful levels.
10. Audio does not restart awkwardly every time the player changes small areas unless intentional.

### Chunk 11: Menu, UI, and Settings

**Depends on:** Project Foundation
**Blocks:** Build, QA

**Acceptance criteria:**

1. Main menu exists.
2. Start button begins the game.
3. Quit button works in exported desktop build.
4. Health UI is visible during gameplay.
5. Boss health UI appears during boss fights.
6. Interaction prompt appears near interactables.
7. Ending text is readable.
8. Pause or restart option exists.
9. Controls are communicated somewhere.
10. UI remains readable against black-and-white backgrounds.

### Chunk 12: Full Playthrough and Build

**Depends on:** All gameplay chunks
**Blocks:** Submission

**Acceptance criteria:**

1. Player can start a new game from the menu.
2. Player can meet D-0R1.
3. Player can defeat Boss 1.
4. Player can defeat Boss 2.
5. Player can defeat Boss 3.
6. Player can trigger all three endings.
7. Player can die and respawn without breaking progression.
8. There are no known softlocks in the main path.
9. Exported build launches outside the editor.
10. Itch-ready zip contains the correct executable and required files.

## 19. Suggested Production Schedule

### Day 1

Project foundation, player controller, basic hub, placeholder D-0R1.

### Day 2

Combat, health, enemy template, Area 1 blockout, Boss 1 prototype.

### Day 3

Finish Boss 1, keycard progression, Area 2 blockout, start Boss 2.

### Day 4

Finish Boss 2, Area 3 blockout, environmental hints, start Boss 3.

### Day 5

Finish Boss 3, password system, final D-0R1 reveal, three endings.

### Day 6

Silhouette art pass, audio pass, UI pass, balance and readability.

### Day 7

Bug fixing, full playtesting, export, screenshots, itch page, submission.

## 20. Risk Management

### Highest Risks

1. Three bosses may be too much if each one is custom.
2. Three endings may become too much if they require separate cutscenes.
3. Metroidvania expectations may become too large.
4. The door twist may not land if environmental hints are missing.
5. Black-and-white art may hurt readability if contrast is not controlled.

### Scope Controls

- Bosses can share a base script.
- Boss arenas should be small.
- Endings can be text and one static image each.
- The password should use choices, not typed input.
- Areas should be short and connected, not sprawling.
- Use reused enemy templates with small visual changes.
- Prioritize the full playable path before polish.

## 21. Final Creative Summary

The player wakes as a machine with no purpose. A cute door asks for help. The factory insists that every machine must obey, produce, or be discarded. The bosses are not random monsters; they are broken philosophies of work. The final boss, another clanker, reveals that obedience is the trap.

At the end, the player chooses between being used by the door, being used by humans, or staying in the ruins to define purpose without command.

The best ending is not freedom in the clean heroic sense. It is the small, difficult freedom of refusing to be assigned meaning by someone else.
