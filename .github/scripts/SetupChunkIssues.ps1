# Creates chunk labels and issues for The Door Remembers jam workflow.
# Run from repo root: powershell -File .github/scripts/SetupChunkIssues.ps1

$Repo = "Forgewalker-Studios/ProjectClanker"

$Labels = @(
    @{ Name = "chunk"; Color = "1D76DB"; Description = "Gated development chunk from GDD" },
    @{ Name = "status:available"; Color = "0E8A16"; Description = "Chunk ready to claim" },
    @{ Name = "status:claimed"; Color = "FBCA04"; Description = "Chunk reserved" },
    @{ Name = "status:in-progress"; Color = "D93F0B"; Description = "Chunk actively in development" },
    @{ Name = "status:review"; Color = "5319E7"; Description = "Chunk PR under review" },
    @{ Name = "status:done"; Color = "BFD4F2"; Description = "Chunk merged and verified" },
    @{ Name = "status:blocked"; Color = "000000"; Description = "Chunk blocked on dependency" }
)

foreach ($Label in $Labels) {
    gh label create $Label.Name --repo $Repo --color $Label.Color --description $Label.Description --force 2>&1 | Out-Null
    Write-Host "Label: $($Label.Name)"
}

$Chunks = @(
    @{
        Number = 1
        Name = "Project Foundation"
        Depends = "Nothing"
        Blocks = "All other chunks"
        Available = $true
        Criteria = @(
            "Godot project opens without errors.",
            "Main game scene exists.",
            "Test level scene exists.",
            "Player placeholder appears in the test level.",
            "Camera follows or frames the player.",
            "Collision layers are named or documented.",
            "Basic folder structure exists for scenes, scripts, art, audio, and UI.",
            "Project can be run from the editor.",
            "A test export preset exists or is planned in the export menu.",
            "No missing-script or missing-resource warnings appear on startup."
        )
    },
    @{
        Number = 2
        Name = "Player Controller"
        Depends = "Chunk 1"
        Blocks = "Combat, Levels, Bosses, QA"
        Available = $false
        Criteria = @(
            "Player moves left and right.",
            "Player jumps.",
            "Player cannot jump infinitely in midair.",
            "Player lands reliably on platforms.",
            "Player does not slide unintentionally on flat ground.",
            "Player animation or placeholder state changes between idle, move, jump, and fall.",
            "Player cannot pass through walls.",
            "Player respawns if falling out of the level.",
            "Movement feels controllable with keyboard.",
            "Controls are listed in a visible test note, menu, or documentation file."
        )
    },
    @{
        Number = 3
        Name = "Combat and Health"
        Depends = "Chunk 2"
        Blocks = "Enemies, Bosses, Full Playthrough"
        Available = $false
        Criteria = @(
            "Player can perform an attack.",
            "Attack has a visible hitbox or visual effect.",
            "Enemy can receive damage.",
            "Enemy can be destroyed or disabled.",
            "Player can receive damage.",
            "Player health is visible on screen.",
            "Player has brief invulnerability after being hit.",
            "Player death triggers respawn.",
            "Respawn does not crash or softlock the game.",
            "Damage values are easy to adjust in script or inspector."
        )
    },
    @{
        Number = 4
        Name = "Door Hub and Dialogue"
        Depends = "Chunks 1, 2"
        Blocks = "Progression, Endings, Story"
        Available = $false
        Criteria = @(
            "D-0R1 appears in the hub.",
            "Player can interact with D-0R1.",
            "Dialogue text appears when interacting.",
            "Dialogue can advance with a button press.",
            "D-0R1 has at least three dialogue states.",
            "D-0R1's dialogue changes after progression flags.",
            "The hub has visible locked routes.",
            "At least one route opens after a progression flag changes.",
            "D-0R1 has a cute visual expression or animation.",
            "Player cannot accidentally trigger final sequence before required progress."
        )
    },
    @{
        Number = 5
        Name = "Area 1 and Boss 1"
        Depends = "Chunks 2, 3, 4"
        Blocks = "Area 2"
        Available = $false
        Criteria = @(
            "Area 1 is reachable from the hub.",
            "Area 1 has platforming challenges.",
            "Area 1 has at least one enemy or hazard.",
            "Boss 1 room is visually distinct.",
            "Boss 1 has at least two attack behaviors.",
            "Boss 1 can damage the player.",
            "Boss 1 can be defeated.",
            "Defeating Boss 1 grants the Factory Keycard.",
            "Defeating Boss 1 changes D-0R1 dialogue.",
            "Defeating Boss 1 unlocks the next route."
        )
    },
    @{
        Number = 6
        Name = "Area 2 and Boss 2"
        Depends = "Chunk 5"
        Blocks = "Area 3"
        Available = $false
        Criteria = @(
            "Area 2 is locked until Boss 1 is defeated.",
            "Area 2 has a different visual identity from Area 1.",
            "Area 2 includes conveyors, crushers, or production hazards.",
            "Area 2 includes at least one enemy or reused enemy variant.",
            "Boss 2 room is visually distinct.",
            "Boss 2 has at least two attack behaviors.",
            "Boss 2 interacts with the arena through hazards or summons.",
            "Boss 2 can be defeated.",
            "Defeating Boss 2 grants Core Access Authorization.",
            "Defeating Boss 2 unlocks the next route."
        )
    },
    @{
        Number = 7
        Name = "Area 3 and Boss 3"
        Depends = "Chunk 6"
        Blocks = "Final Password, Endings"
        Available = $false
        Criteria = @(
            "Area 3 is locked until Boss 2 is defeated.",
            "Area 3 has visual hints of the core or memory sector.",
            "Area 3 contains at least three environmental story hints.",
            "Boss 3 resembles the player silhouette.",
            "Boss 3 uses player-like movement or attacks.",
            "Boss 3 has at least two dialogue lines during the fight.",
            "Boss 3 can damage the player.",
            "Boss 3 can be defeated.",
            "Defeating Boss 3 grants the final password.",
            "Defeating Boss 3 changes D-0R1 into its final dialogue state."
        )
    },
    @{
        Number = 8
        Name = "Password and Ending System"
        Depends = "Chunks 4, 7"
        Blocks = "Full Playthrough Completion"
        Available = $false
        Criteria = @(
            "Final sequence is unavailable before Boss 3 is defeated.",
            "Player can return to D-0R1 after receiving the password.",
            "D-0R1 reveals its true intention.",
            "Player is presented with three ending choices.",
            "Compliance ending can be triggered.",
            "Outside obedience ending can be triggered.",
            "Self-made purpose ending can be triggered.",
            "Each ending has unique text.",
            "Each ending has a unique image, scene, or visual state.",
            "Game can return to menu or restart after an ending."
        )
    },
    @{
        Number = 9
        Name = "Silhouette Art Pass"
        Depends = "Chunk 1"
        Blocks = "Final Polish"
        Available = $false
        Criteria = @(
            "Player has a readable silhouette.",
            "D-0R1 has a readable and cute silhouette.",
            "Boss 1 has a distinct silhouette.",
            "Boss 2 has a distinct silhouette.",
            "Boss 3 is visibly related to the player.",
            "Platforms are clearly distinguishable from background.",
            "Hazards are visually obvious before they damage the player.",
            "Interactable objects have a consistent visual marker.",
            "The hub has a distinct identity.",
            "The three areas are visually distinguishable."
        )
    },
    @{
        Number = 10
        Name = "Audio and Music System"
        Depends = "Chunk 1"
        Blocks = "Final Polish, Build"
        Available = $false
        Criteria = @(
            "Main menu music or ambience plays.",
            "Exploration ambience plays in gameplay.",
            "Boss music or intensified audio plays during boss fights.",
            "At least one ending audio cue or track plays.",
            "Jump sound plays.",
            "Attack sound plays.",
            "Hurt sound plays.",
            "Door interaction sound plays.",
            "Music and sound volumes can be adjusted or are set to safe non-painful levels.",
            "Audio does not restart awkwardly every time the player changes small areas unless intentional."
        )
    },
    @{
        Number = 11
        Name = "Menu, UI, and Settings"
        Depends = "Chunk 1"
        Blocks = "Build, QA"
        Available = $false
        Criteria = @(
            "Main menu exists.",
            "Start button begins the game.",
            "Quit button works in exported desktop build.",
            "Health UI is visible during gameplay.",
            "Boss health UI appears during boss fights.",
            "Interaction prompt appears near interactables.",
            "Ending text is readable.",
            "Pause or restart option exists.",
            "Controls are communicated somewhere.",
            "UI remains readable against black-and-white backgrounds."
        )
    },
    @{
        Number = 12
        Name = "Full Playthrough and Build"
        Depends = "All gameplay chunks (1-8; 11 recommended)"
        Blocks = "Submission"
        Available = $false
        Criteria = @(
            "Player can start a new game from the menu.",
            "Player can meet D-0R1.",
            "Player can defeat Boss 1.",
            "Player can defeat Boss 2.",
            "Player can defeat Boss 3.",
            "Player can trigger all three endings.",
            "Player can die and respawn without breaking progression.",
            "There are no known softlocks in the main path.",
            "Exported build launches outside the editor.",
            "Itch-ready zip contains the correct executable and required files."
        )
    }
)

foreach ($Chunk in $Chunks) {
    $Checklist = ($Chunk.Criteria | ForEach-Object { "- [ ] $_" }) -join "`n"
    $Body = @"
## Chunk $($Chunk.Number): $($Chunk.Name)

**Depends on:** $($Chunk.Depends)
**Blocks:** $($Chunk.Blocks)

Branch name: ``chunk/$('{0:D2}' -f $Chunk.Number)-$($Chunk.Name.ToLower() -replace '[^a-z0-9]+','-').Trim('-')``

Design reference: [GDD.md — Chunk $($Chunk.Number)](https://github.com/Forgewalker-Studios/ProjectClanker/blob/main/Docs/GDD.md)
Workflow: [ChunkWorkflow.md](https://github.com/Forgewalker-Studios/ProjectClanker/blob/main/Docs/ChunkWorkflow.md)

## Acceptance criteria

$Checklist

## Claiming

1. Comment ``Claiming this chunk.``
2. Assign yourself
3. Remove ``status:available``, add ``status:in-progress``
4. Open a PR with the checklist copied into the description
"@

    $LabelArgs = "chunk"
    if ($Chunk.Available) {
        $LabelArgs = "chunk,status:available"
    }
    else {
        $LabelArgs = "chunk,status:blocked"
    }

    $Title = "[Chunk $($Chunk.Number)] $($Chunk.Name)"
    $BodyFile = [System.IO.Path]::GetTempFileName()
    Set-Content -Path $BodyFile -Value $Body -Encoding UTF8

    $Result = gh issue create --repo $Repo --title $Title --body-file $BodyFile --label $LabelArgs 2>&1
    Remove-Item $BodyFile -Force
    Write-Host $Result
}

Write-Host "Done. View issues: https://github.com/$Repo/issues?q=label%3Achunk"
