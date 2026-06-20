"""Generate grid-aligned silhouette sprite sheets and environment art for ProjectClanker."""

from __future__ import annotations

import math
import os
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageOps

ROOT: Path = Path(__file__).resolve().parents[1]
CELL: int = 64
BLACK: tuple[int, int, int, int] = (0, 0, 0, 255)
WHITE: tuple[int, int, int, int] = (255, 255, 255, 255)
TRANSPARENT: tuple[int, int, int, int] = (0, 0, 0, 0)
DARK: tuple[int, int, int, int] = (20, 20, 20, 255)


def new_sheet(cols: int, rows: int, cell: int = CELL) -> Image.Image:
    """Create a transparent RGBA sheet sized to the grid."""
    return Image.new("RGBA", (cols * cell, rows * cell), TRANSPARENT)


def paste_cell(
    sheet: Image.Image, col: int, row: int, frame: Image.Image, cell: int = CELL
) -> None:
    """Paste a frame into a grid cell, bottom-aligned and horizontally centered."""
    ox: int = col * cell + (cell - frame.width) // 2
    oy: int = row * cell + (cell - frame.height)
    sheet.paste(frame, (ox, oy), frame)


def frame_canvas(cell: int = CELL) -> Image.Image:
    """Return a transparent frame buffer."""
    return Image.new("RGBA", (cell, cell), TRANSPARENT)


def draw_rect(
    draw: ImageDraw.ImageDraw,
    box: tuple[int, int, int, int],
    fill: tuple[int, int, int, int] = BLACK,
    outline: tuple[int, int, int, int] | None = None,
) -> None:
    """Draw a filled rectangle with optional outline."""
    draw.rectangle(box, fill=fill, outline=outline)


def draw_line_white(
    draw: ImageDraw.ImageDraw, pts: list[tuple[int, int]], width: int = 1
) -> None:
    """Draw a white polyline."""
    draw.line(pts, fill=WHITE, width=width)


def boss1_custodian(frame_idx: int, anim: str) -> Image.Image:
    """Draw Keycard Custodian frames."""
    img: Image.Image = frame_canvas()
    draw: ImageDraw.ImageDraw = ImageDraw.Draw(img)
    t: float = frame_idx / 7.0

    body_w: int = 22
    body_h: int = 34
    bx: int = 32 - body_w // 2
    by: int = 56 - body_h

    if anim == "idle":
        bob: int = int(math.sin(t * math.pi * 2.0) * 1.0)
        draw_rect(draw, (bx, by + bob, bx + body_w, 56), BLACK)
        draw_rect(draw, (bx + 4, by + 8 + bob, bx + body_w - 4, by + 14 + bob), WHITE)
        draw_rect(draw, (bx + 6, by + 18 + bob, bx + body_w - 6, by + 22 + bob), WHITE)
        draw_rect(
            draw, (bx + 8, by + 26 + bob, bx + body_w - 8, by + 30 + bob), BLACK, WHITE
        )
        draw_rect(
            draw, (bx + body_w, by + 12 + bob, bx + body_w + 10, by + 16 + bob), BLACK
        )
        draw_line_white(
            draw,
            [(bx + body_w + 2, by + 13 + bob), (bx + body_w + 8, by + 13 + bob)],
            2,
        )

    elif anim == "attack":
        lean: int = 4 + frame_idx
        draw_rect(draw, (bx - lean, by + 4, bx + body_w - lean, 56), BLACK)
        draw_rect(
            draw, (bx + 2 - lean, by + 12, bx + body_w - 6 - lean, by + 18), WHITE
        )
        draw_rect(
            draw,
            (bx + 4 - lean, by + 22, bx + body_w - 8 - lean, by + 26),
            BLACK,
            WHITE,
        )
        for i in range(frame_idx + 1):
            y: int = by + 20 + i * 2
            draw_line_white(draw, [(8, y), (bx - lean - 4, y)], 1)

    elif anim == "hurt":
        knock: int = frame_idx * 2
        draw_rect(draw, (bx + knock, by + 2, bx + body_w + knock, 56), BLACK)
        draw_rect(
            draw, (bx + 5 + knock, by + 10, bx + body_w - 5 + knock, by + 14), WHITE
        )
        draw_line_white(draw, [(bx + 8 + knock, by + 6), (bx + 16 + knock, by + 18)], 2)
        draw_line_white(draw, [(bx + 14 + knock, by + 8), (bx + 8 + knock, by + 20)], 2)

    else:
        slump: int = min(frame_idx * 3, 14)
        x0: int = bx + slump // 2
        y0: int = min(by + slump, 52)
        draw_rect(draw, (x0, y0, bx + body_w, 56), DARK if frame_idx > 4 else BLACK)
        if frame_idx < 5:
            draw_rect(draw, (x0 + 6, y0 + 8, x0 + body_w - 10, y0 + 12), WHITE)
        if frame_idx < 4:
            draw_rect(draw, (x0 + 8, y0 + 18, x0 + body_w - 12, y0 + 22), WHITE)
        if frame_idx > 3:
            draw_rect(
                draw, (bx + body_w - 4, min(y0 + 24, 52), bx + body_w + 2, 56), DARK
            )

    return img


def boss2_saint(frame_idx: int, anim: str) -> Image.Image:
    """Draw Production Saint frames."""
    img: Image.Image = frame_canvas()
    draw: ImageDraw.ImageDraw = ImageDraw.Draw(img)
    cx: int = 32
    base: int = 58

    if anim == "idle":
        h: int = 56
        top: int = base - h
        draw.polygon(
            [
                (cx - 18, base),
                (cx - 14, top + 8),
                (cx - 6, top),
                (cx + 6, top),
                (cx + 14, top + 8),
                (cx + 18, base),
            ],
            fill=BLACK,
        )
        draw.polygon(
            [
                (cx - 4, top + 10),
                (cx + 4, top + 10),
                (cx + 2, top + 22),
                (cx - 2, top + 22),
            ],
            fill=WHITE,
        )
        draw_rect(draw, (cx - 22, top + 18, cx - 14, base - 4), BLACK)
        draw_rect(draw, (cx + 14, top + 18, cx + 22, base - 4), BLACK)
        pulse: int = int(math.sin(frame_idx * 0.8) * 2)
        draw.ellipse(
            (cx - 3 - pulse, top + 12 - pulse, cx + 3 + pulse, top + 18 + pulse),
            fill=WHITE,
        )

    elif anim == "attack":
        h = 54
        top = base - h
        arm_up: int = min(frame_idx, 3) * 4
        arm_down: int = max(0, frame_idx - 3) * 5
        draw.polygon(
            [
                (cx - 16, base),
                (cx - 12, top + 10),
                (cx - 5, top + 2),
                (cx + 5, top + 2),
                (cx + 12, top + 10),
                (cx + 16, base),
            ],
            fill=BLACK,
        )
        left_y1: int = top + 20 - arm_up + arm_down
        left_y2: int = base - 6 + arm_down
        right_y1: int = top + 20 - arm_up + arm_down
        right_y2: int = base - 6 + arm_down
        draw.polygon(
            [
                (cx - 24, left_y1),
                (cx - 16, left_y2),
                (cx - 12, left_y2 - 4),
                (cx - 20, left_y1 - 4),
            ],
            fill=BLACK,
        )
        draw.polygon(
            [
                (cx + 24, right_y1),
                (cx + 16, right_y2),
                (cx + 12, right_y2 - 4),
                (cx + 20, right_y1 - 4),
            ],
            fill=BLACK,
        )
        if frame_idx < 3:
            for i in range(3):
                draw.polygon(
                    [
                        (cx - 8 + i * 6, top - 6 - i * 2),
                        (cx - 6 + i * 6, top - 2 - i * 2),
                        (cx - 4 + i * 6, top - 6 - i * 2),
                    ],
                    fill=WHITE,
                )
        if frame_idx >= 5:
            draw.ellipse((cx - 8, base - 8, cx + 8, base + 2), fill=WHITE)

    elif anim == "hurt":
        shake: int = 2 if frame_idx % 2 == 0 else -2
        h = 50
        top = base - h
        draw.polygon(
            [
                (cx - 15 + shake, base),
                (cx - 11 + shake, top + 12),
                (cx + 11 - shake, top + 12),
                (cx + 15 - shake, base),
            ],
            fill=BLACK,
        )
        draw.ellipse((cx - 2, top + 14, cx + 2, top + 18), fill=WHITE)
        draw.ellipse((cx - 18 + shake, top + 4, cx - 12 + shake, top + 10), fill=WHITE)
        draw.ellipse((cx + 12 - shake, top + 6, cx + 18 - shake, top + 12), fill=WHITE)

    else:
        fall: int = min(frame_idx * 4, 24)
        h = max(20, 52 - fall)
        top = base - h
        draw.polygon(
            [
                (cx - 14 + fall // 2, base),
                (cx - 8, top + 10),
                (cx + 10, top + 14),
                (cx + 16, base),
            ],
            fill=DARK if frame_idx > 4 else BLACK,
        )
        if frame_idx > 3:
            draw_rect(draw, (cx - 20, top + 20, cx - 10, base - 2), DARK)
            draw_rect(draw, (cx + 8, top + 22, cx + 18, base - 4), DARK)

    return img


def clanker_silhouette(
    draw: ImageDraw.ImageDraw,
    cx: int,
    base: int,
    scale: float,
    crack: bool,
    broken_antenna: bool,
) -> None:
    """Draw a clanker-style robot silhouette."""
    head_r: int = int(7 * scale)
    body_w: int = int(14 * scale)
    body_h: int = int(18 * scale)
    head_y: int = base - int(38 * scale)
    draw.ellipse(
        (cx - head_r, head_y - head_r, cx + head_r, head_y + head_r), fill=BLACK
    )
    draw.ellipse((cx - 3, head_y - 2, cx - 1, head_y), fill=WHITE)
    draw.ellipse((cx + 1, head_y - 2, cx + 3, head_y), fill=WHITE)
    if broken_antenna:
        draw_line_white(draw, [(cx, head_y - head_r), (cx + 2, head_y - head_r - 5)], 2)
    else:
        draw_line_white(draw, [(cx, head_y - head_r), (cx, head_y - head_r - 7)], 2)
    torso_top: int = head_y + head_r - 2
    draw_rect(
        draw, (cx - body_w // 2, torso_top, cx + body_w // 2, torso_top + body_h), BLACK
    )
    draw_rect(draw, (cx - 2, torso_top + 4, cx + 2, torso_top + 8), WHITE)
    if crack:
        draw_line_white(draw, [(cx - 4, torso_top + 6), (cx + 5, torso_top + 14)], 1)
        draw_line_white(draw, [(cx + 2, torso_top + 10), (cx - 3, torso_top + 16)], 1)
    leg_len: int = int(12 * scale)
    draw_rect(
        draw,
        (cx - 6, torso_top + body_h - 2, cx - 2, torso_top + body_h + leg_len),
        BLACK,
    )
    draw_rect(
        draw,
        (cx + 2, torso_top + body_h - 2, cx + 6, torso_top + body_h + leg_len),
        BLACK,
    )


def boss3_other_clanker(frame_idx: int, anim: str) -> Image.Image:
    """Draw Other Clanker frames."""
    img: Image.Image = frame_canvas()
    draw: ImageDraw.ImageDraw = ImageDraw.Draw(img)
    cx: int = 32
    base: int = 58
    scale: float = 1.25

    if anim == "idle":
        bob: int = int(math.sin(frame_idx * 0.9) * 1.5)
        clanker_silhouette(draw, cx, base + bob, scale, True, True)

    elif anim == "run":
        stride: float = frame_idx / 7.0 * math.pi * 2.0
        offset: int = int(math.sin(stride) * 3)
        clanker_silhouette(draw, cx + offset, base, scale, True, True)
        leg_y: int = base - int(8 * scale)
        draw_rect(draw, (cx - 8 + offset, leg_y, cx - 4 + offset, base), BLACK)
        draw_rect(draw, (cx + 2 + offset, leg_y - 4, cx + 8 + offset, base), BLACK)

    elif anim == "jump":
        rise: int = int(abs(math.sin(frame_idx / 6.0 * math.pi)) * 10)
        tuck: int = min(frame_idx, 4)
        clanker_silhouette(draw, cx, base - rise, scale, True, True)
        draw_rect(
            draw,
            (
                cx - 8,
                base - rise - int(6 * scale) + tuck,
                cx - 3,
                base - rise - int(2 * scale),
            ),
            BLACK,
        )
        draw_rect(
            draw,
            (
                cx + 3,
                base - rise - int(6 * scale) + tuck,
                cx + 8,
                base - rise - int(2 * scale),
            ),
            BLACK,
        )

    elif anim == "attack":
        reach: int = frame_idx * 3
        clanker_silhouette(draw, cx - 2, base, scale, True, True)
        draw_rect(
            draw,
            (cx + 6, base - int(24 * scale), cx + 10 + reach, base - int(14 * scale)),
            BLACK,
        )
        draw_line_white(
            draw,
            [
                (cx + 12 + reach, base - int(22 * scale)),
                (cx + 20 + reach, base - int(18 * scale)),
                (cx + 26 + reach, base - int(12 * scale)),
            ],
            2,
        )

    elif anim == "hurt":
        flash: bool = frame_idx % 2 == 0
        body_color: tuple[int, int, int, int] = WHITE if flash else BLACK
        head_r: int = int(7 * scale)
        head_y: int = base - int(38 * scale)
        draw.ellipse(
            (cx - head_r, head_y - head_r, cx + head_r, head_y + head_r),
            fill=body_color,
        )
        draw_rect(draw, (cx - 8, head_y + 4, cx + 8, base - 10), fill=body_color)
        draw_line_white(draw, [(cx - 10, head_y), (cx + 12, head_y + 20)], 2)
        draw_line_white(draw, [(cx + 8, head_y + 4), (cx - 8, head_y + 22)], 2)

    else:
        kneel: int = min(frame_idx * 2, 14)
        clanker_silhouette(draw, cx, base + kneel // 2, scale * 0.95, True, True)
        draw_rect(draw, (cx - 10, base - 8 + kneel, cx - 4, base + kneel // 2), BLACK)
        draw_rect(draw, (cx + 4, base - 8 + kneel, cx + 10, base + kneel // 2), BLACK)
        if frame_idx > 4:
            draw.ellipse(
                (
                    cx - 2,
                    base - int(36 * scale) + kneel,
                    cx + 2,
                    base - int(32 * scale) + kneel,
                ),
                fill=DARK,
            )

    return img


def minion_vfx(frame_idx: int) -> Image.Image:
    """Draw scrap drone or shared VFX in cells 0-7 of row 14."""
    img: Image.Image = frame_canvas()
    draw: ImageDraw.ImageDraw = ImageDraw.Draw(img)
    cx: int = 32
    cy: int = 40

    if frame_idx == 0:
        draw.ellipse((cx - 8, cy - 4, cx + 8, cy + 6), fill=BLACK)
        draw_line_white(draw, [(cx, cy - 8), (cx, cy - 14)], 2)
        draw_line_white(draw, [(cx - 6, cy - 14), (cx + 6, cy - 14)], 1)
        draw.ellipse((cx - 2, cy, cx + 2, cy + 3), fill=WHITE)
    elif frame_idx == 1:
        draw.ellipse((cx - 8, cy - 6, cx + 8, cy + 4), fill=BLACK)
        draw_line_white(draw, [(cx, cy - 10), (cx, cy - 16)], 2)
        draw_line_white(draw, [(cx - 10, cy - 2), (cx - 18, cy - 6)], 1)
        draw_line_white(draw, [(cx + 10, cy - 2), (cx + 18, cy - 6)], 1)
    elif frame_idx == 2:
        draw.ellipse((cx - 6, cy - 2, cx + 10, cy + 6), fill=BLACK)
        draw_line_white(draw, [(cx + 12, cy + 2), (cx + 22, cy + 2)], 2)
        draw.ellipse((cx + 20, cy, cx + 24, cy + 4), fill=WHITE)
    elif frame_idx == 3:
        for r in range(3):
            rad: int = 4 + frame_idx + r * 3
            draw.ellipse(
                (cx - rad, cy - rad, cx + rad, cy + rad), outline=WHITE, width=1
            )
        draw.ellipse((cx - 3, cy - 3, cx + 3, cy + 3), fill=DARK)
    elif frame_idx == 4:
        draw.polygon(
            [(cx - 16, cy + 8), (cx - 4, cy - 12), (cx + 8, cy + 8)], fill=WHITE
        )
    elif frame_idx == 5:
        draw.line(
            [
                (cx - 10, cy),
                (cx, cy - 12),
                (cx + 8, cy - 4),
                (cx + 12, cy + 10),
                (cx - 6, cy + 6),
                (cx - 10, cy),
            ],
            fill=WHITE,
            width=2,
        )
    elif frame_idx == 6:
        for i in range(4):
            draw.polygon(
                [
                    (cx - 8 + i * 5, cy - 6),
                    (cx - 6 + i * 5, cy + 4),
                    (cx - 4 + i * 5, cy - 6),
                ],
                fill=BLACK,
            )
    else:
        draw.polygon(
            [
                (cx, cy - 10),
                (cx + 3, cy - 2),
                (cx + 10, cy - 2),
                (cx + 4, cy + 2),
                (cx + 6, cy + 10),
                (cx, cy + 5),
                (cx - 6, cy + 10),
                (cx - 4, cy + 2),
                (cx - 10, cy - 2),
                (cx - 3, cy - 2),
            ],
            fill=WHITE,
        )

    return img


def generate_baddies() -> Path:
    """Build the 512x960 baddies sprite sheet."""
    cols: int = 8
    rows: int = 15
    sheet: Image.Image = new_sheet(cols, rows)
    row_defs: list[tuple[str, str]] = [
        ("boss1", "idle"),
        ("boss1", "attack"),
        ("boss1", "hurt"),
        ("boss1", "defeated"),
        ("boss2", "idle"),
        ("boss2", "attack"),
        ("boss2", "hurt"),
        ("boss2", "defeated"),
        ("boss3", "idle"),
        ("boss3", "run"),
        ("boss3", "jump"),
        ("boss3", "attack"),
        ("boss3", "hurt"),
        ("boss3", "defeated"),
        ("minion", "vfx"),
    ]

    for row_idx, (boss, anim) in enumerate(row_defs):
        for col in range(cols):
            if boss == "boss1":
                frame = boss1_custodian(col, anim)
            elif boss == "boss2":
                frame = boss2_saint(col, anim)
            elif boss == "boss3":
                frame = boss3_other_clanker(col, anim)
            else:
                frame = minion_vfx(col)
            paste_cell(sheet, col, row_idx, frame)

    out: Path = ROOT / "Assets" / "baddies.png"
    sheet.save(out)
    return out


def dori_face(draw: ImageDraw.ImageDraw, ox: int, oy: int, expression: str) -> None:
    """Draw D-0R1 screen expression inside the door panel."""
    panel: tuple[int, int, int, int] = (ox + 18, oy + 22, ox + 46, oy + 50)
    draw_rect(draw, panel, BLACK, WHITE)
    cx: int = ox + 32
    cy: int = oy + 36

    if expression == "neutral":
        draw.ellipse((cx - 8, cy - 6, cx - 4, cy - 2), fill=WHITE)
        draw.ellipse((cx + 4, cy - 6, cx + 8, cy - 2), fill=WHITE)
        draw_line_white(draw, [(cx - 4, cy + 6), (cx + 4, cy + 6)], 2)
    elif expression == "happy":
        draw.arc((cx - 8, cy - 8, cx - 2, cy - 2), 200, 340, fill=WHITE, width=2)
        draw.arc((cx + 2, cy - 8, cx + 8, cy - 2), 200, 340, fill=WHITE, width=2)
        draw.arc((cx - 4, cy + 2, cx + 4, cy + 10), 20, 160, fill=WHITE, width=2)
    elif expression == "sad":
        draw.ellipse((cx - 8, cy - 4, cx - 4, cy), fill=WHITE)
        draw.ellipse((cx + 4, cy - 4, cx + 8, cy), fill=WHITE)
        draw.arc((cx - 4, cy + 6, cx + 4, cy + 12), 160, 340, fill=WHITE, width=2)
        draw_line_white(draw, [(cx - 10, cy - 10), (cx - 4, cy - 8)], 2)
        draw_line_white(draw, [(cx + 10, cy - 10), (cx + 4, cy - 8)], 2)
    elif expression == "cry":
        draw.ellipse((cx - 8, cy - 4, cx - 4, cy), fill=WHITE)
        draw.ellipse((cx + 4, cy - 4, cx + 8, cy), fill=WHITE)
        draw.arc((cx - 4, cy + 6, cx + 4, cy + 12), 160, 340, fill=WHITE, width=2)
        for i in range(3):
            draw.ellipse(
                (cx - 9 + i * 2, cy + 4 + i * 3, cx - 7 + i * 2, cy + 6 + i * 3),
                fill=WHITE,
            )
            draw.ellipse(
                (cx + 5 + i * 2, cy + 4 + i * 3, cx + 7 + i * 2, cy + 6 + i * 3),
                fill=WHITE,
            )
    elif expression == "shock":
        draw.ellipse((cx - 8, cy - 6, cx - 4, cy - 2), fill=WHITE)
        draw.ellipse((cx + 4, cy - 6, cx + 8, cy - 2), fill=WHITE)
        draw.ellipse((cx - 2, cy + 4, cx + 2, cy + 8), fill=WHITE)
        for i in range(3):
            draw_line_white(
                draw,
                [
                    (ox + 48 + i * 3, oy + 28 + i * 2),
                    (ox + 52 + i * 3, oy + 28 + i * 2),
                ],
                2,
            )
    else:
        draw_line_white(draw, [(cx - 6, cy - 4), (cx + 6, cy - 4)], 3)
        draw_line_white(draw, [(cx - 4, cy + 6), (cx + 4, cy + 6)], 2)


def dori_frame(expression: str, cell: int = 128) -> Image.Image:
    """Draw one D-0R1 door terminal frame."""
    img: Image.Image = Image.new("RGBA", (cell, cell), TRANSPARENT)
    draw: ImageDraw.ImageDraw = ImageDraw.Draw(img)
    ox: int = 16
    oy: int = 8
    draw_rect(draw, (ox, oy, ox + 96, oy + 112), BLACK, WHITE)
    draw_rect(draw, (ox + 6, oy + 6, ox + 34, oy + 18), BLACK, WHITE)
    draw.text((ox + 8, oy + 7), "D-0R1", fill=WHITE)
    draw.text((ox + 8, oy + 14), "SEC-01", fill=WHITE)
    draw_rect(draw, (ox + 8, oy + 54, ox + 30, oy + 64), BLACK, WHITE)
    draw_line_white(
        draw, [(ox + 14, oy + 58), (ox + 10, oy + 62), (ox + 18, oy + 62)], 1
    )
    draw_rect(draw, (ox + 70, oy + 88, ox + 92, oy + 108), BLACK)
    for i in range(4):
        draw_line_white(
            draw, [(ox + 72 + i * 5, oy + 108), (ox + 76 + i * 5, oy + 92)], 1
        )
    draw_rect(draw, (ox + 4, oy + 72, ox + 12, oy + 108), BLACK)
    draw_line_white(draw, [(ox + 6, oy + 76), (ox + 6, oy + 104)], 1)
    draw_line_white(draw, [(ox + 10, oy + 76), (ox + 10, oy + 104)], 1)
    dori_face(draw, ox, oy, expression)
    return img


def generate_dori() -> Path:
    """Build the 384x256 D-0R1 expression sheet (3x2 grid, 128px cells)."""
    cell: int = 128
    cols: int = 3
    rows: int = 2
    sheet: Image.Image = new_sheet(cols, rows, cell)
    expressions: list[str] = ["neutral", "happy", "sad", "cry", "shock", "sleep"]
    for idx, expression in enumerate(expressions):
        col: int = idx % cols
        row: int = idx // cols
        paste_cell(sheet, col, row, dori_frame(expression, cell), cell)
    out: Path = ROOT / "Assets" / "dori.png"
    sheet.save(out)
    return out


def to_silhouette(source: Image.Image) -> Image.Image:
    """Convert a colored sprite into a black-and-white silhouette with transparency."""
    rgba: Image.Image = source.convert("RGBA")
    width: int
    height: int
    width, height = rgba.size
    out: Image.Image = Image.new("RGBA", (width, height), TRANSPARENT)
    src_px = rgba.load()
    out_px = out.load()

    for y in range(height):
        for x in range(width):
            red: int
            green: int
            blue: int
            alpha: int
            red, green, blue, alpha = src_px[x, y]
            if alpha < 32:
                continue
            lum: int = int(red * 0.299 + green * 0.587 + blue * 0.114)
            if lum < 24:
                continue
            if lum > 210:
                out_px[x, y] = WHITE
            else:
                out_px[x, y] = (0, 0, 0, 255)
    return out


def generate_environment_sprites() -> Path:
    """Convert platform-builder PNGs into silhouette sprites and pack a paint atlas."""
    src_root: Path = (
        ROOT
        / "Assets"
        / "2d-sci-fi-industrial-platform-builder"
        / "2D Sci-Fi Industrial Platform Builder"
        / "2-PNG Files"
    )
    out_dir: Path = ROOT / "Art" / "Environment" / "Silhouettes"
    out_dir.mkdir(parents=True, exist_ok=True)

    png_paths: list[Path] = sorted(src_root.rglob("*.png"))
    saved: list[Path] = []
    for src in png_paths:
        rel: Path = src.relative_to(src_root)
        dest: Path = out_dir / rel
        dest.parent.mkdir(parents=True, exist_ok=True)
        silhouette: Image.Image = to_silhouette(Image.open(src))
        silhouette.save(dest)
        saved.append(dest)

    # Build a 64px atlas for TileMap painting (8 columns).
    atlas_cols: int = 8
    thumb: int = 64
    atlas_rows: int = int(math.ceil(len(saved) / atlas_cols))
    atlas: Image.Image = Image.new(
        "RGBA", (atlas_cols * thumb, max(1, atlas_rows) * thumb), TRANSPARENT
    )
    manifest_lines: list[str] = [
        "# LevelPaint atlas tile index",
        f"# Cell size: {thumb}x{thumb}",
        "",
    ]

    for idx, path in enumerate(saved):
        col: int = idx % atlas_cols
        row: int = idx // atlas_cols
        sprite: Image.Image = Image.open(path).convert("RGBA")
        fitted: Image.Image = Image.new("RGBA", (thumb, thumb), TRANSPARENT)
        sprite.thumbnail((thumb, thumb), Image.Resampling.LANCZOS)
        ox: int = (thumb - sprite.width) // 2
        oy: int = thumb - sprite.height
        fitted.paste(sprite, (ox, oy), sprite)
        atlas.paste(fitted, (col * thumb, row * thumb))
        manifest_lines.append(f"{idx}: {path.relative_to(out_dir).as_posix()}")

    atlas_path: Path = ROOT / "Art" / "Environment" / "LevelPaintAtlas.png"
    atlas.save(atlas_path)
    manifest_path: Path = ROOT / "Art" / "Environment" / "LevelPaintAtlas.txt"
    manifest_path.write_text("\n".join(manifest_lines) + "\n", encoding="utf-8")
    return atlas_path


BG_SOURCE_PALETTE: dict[tuple[int, int, int], tuple[int, int, int]] = {
    (25, 40, 31): (22, 22, 24),
    (35, 76, 52): (40, 40, 43),
    (44, 109, 72): (62, 62, 66),
    (52, 137, 88): (84, 84, 88),
}


def remap_parallax_background() -> Path:
    """Remap the industrial parallax bg dither to the project grayscale palette."""
    src_path: Path = (
        ROOT
        / "Assets"
        / "industrial-parallax-background"
        / "parallax-industrial-web"
        / "Assets"
        / "Layers"
        / "bg.png"
    )
    out_dir: Path = ROOT / "Art" / "Environment" / "Parallax"
    out_dir.mkdir(parents=True, exist_ok=True)
    out_path: Path = out_dir / "BgLevelPaint.png"

    source: Image.Image = Image.open(src_path).convert("RGB")
    remapped: Image.Image = Image.new("RGB", source.size)
    src_px = source.load()
    out_px = remapped.load()

    for y in range(source.height):
        for x in range(source.width):
            rgb: tuple[int, int, int] = src_px[x, y]
            mapped: tuple[int, int, int] | None = BG_SOURCE_PALETTE.get(rgb)
            if mapped is None:
                lum: int = int(rgb[0] * 0.299 + rgb[1] * 0.587 + rgb[2] * 0.114)
                gray: int = max(18, min(90, lum))
                mapped = (gray, gray, gray)
            out_px[x, y] = mapped

    remapped.save(out_path)
    return out_path


def _pixel_luminance(red: int, green: int, blue: int) -> int:
    """Return perceptual luminance for a pixel."""
    return int(red * 0.299 + green * 0.587 + blue * 0.114)


def process_midground_transparency(
    bg_luminance_max: int = 30,
    neighbor_luminance_delta: int = 10,
) -> Path:
    """Remove opaque sky fill from midground.png via edge-connected flood fill."""
    from collections import deque

    src_path: Path = ROOT / "Assets" / "midground.png"
    out_dir: Path = ROOT / "Art" / "Environment" / "Parallax"
    out_dir.mkdir(parents=True, exist_ok=True)
    out_path: Path = out_dir / "MidgroundLevel.png"

    source: Image.Image = Image.open(src_path).convert("RGBA")
    width: int
    height: int
    width, height = source.size
    src_px = source.load()
    is_background: list[list[bool]] = [[False] * width for _ in range(height)]
    queue: deque[tuple[int, int]] = deque()

    def is_seed_pixel(x: int, y: int) -> bool:
        red: int
        green: int
        blue: int
        alpha: int
        red, green, blue, alpha = src_px[x, y]
        if alpha < 32:
            return True
        return _pixel_luminance(red, green, blue) <= bg_luminance_max

    for x in range(width):
        for y in (0, height - 1):
            if is_seed_pixel(x, y) and not is_background[y][x]:
                is_background[y][x] = True
                queue.append((x, y))

    for y in range(height):
        for x in (0, width - 1):
            if is_seed_pixel(x, y) and not is_background[y][x]:
                is_background[y][x] = True
                queue.append((x, y))

    while queue:
        x: int
        y: int
        x, y = queue.popleft()
        seed_luminance: int = _pixel_luminance(
            src_px[x, y][0], src_px[x, y][1], src_px[x, y][2]
        )
        for next_x, next_y in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
            if next_x < 0 or next_y < 0 or next_x >= width or next_y >= height:
                continue
            if is_background[next_y][next_x]:
                continue
            red: int
            green: int
            blue: int
            alpha: int
            red, green, blue, alpha = src_px[next_x, next_y]
            next_luminance: int = _pixel_luminance(red, green, blue)
            if next_luminance > bg_luminance_max + neighbor_luminance_delta:
                continue
            if abs(next_luminance - seed_luminance) > neighbor_luminance_delta:
                continue
            is_background[next_y][next_x] = True
            queue.append((next_x, next_y))

    output: Image.Image = source.copy()
    out_px = output.load()
    for y in range(height):
        for x in range(width):
            if is_background[y][x]:
                out_px[x, y] = TRANSPARENT

    output.save(out_path)
    return out_path


def main() -> None:
    """Generate all art assets."""
    baddies: Path = generate_baddies()
    dori: Path = generate_dori()
    atlas: Path = generate_environment_sprites()
    parallax_bg: Path = remap_parallax_background()
    midground: Path = process_midground_transparency()
    print(f"Wrote {baddies} ({Image.open(baddies).size})")
    print(f"Wrote {dori} ({Image.open(dori).size})")
    print(f"Wrote {atlas} ({Image.open(atlas).size})")
    print(f"Wrote {parallax_bg} ({Image.open(parallax_bg).size})")
    print(f"Wrote {midground} ({Image.open(midground).size})")


if __name__ == "__main__":
    main()
