#!/bin/bash
python3 << 'PYEOF'
import sys, time, random, os

ART_LINES = [
"             GGGGGGGGGG             ",
"        GGGGGGGGGGGGGGGGGGGG        ",
"     GGGGGGGGGGGGGGGGGGGGGGGGGG     ",
"    GGGGGGGGGGGGGGGGGGGGGGGGGGGG    ",
"  GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG  ",
" GGGGGG  GGGGGGGGGGGGGGGGGG  GGGGGG ",
"GGGGGGG    GGGGGGGGGGGGGG    GGGGGGG",
"GGGGGGG      GGGGGGGGGG      GGGGGGG",
"GGGGGGG        GGGGGG        GGGGGGG",
"GGGGGGG   GG     GG     GG   GGGGGGG",
"GGGGGG    GGGG        GGGG    GGGGGG",
" GGGGG    GGGGGGG  GGGGGGG    GGGGG ",
"          GGGGGGGGGGGGGGGG          ",
"   GGGGGGGGGGGGGGGGGGGGGGGGGGGGGG   ",
"    GGGGGGGGGGGGGGGGGGGGGGGGGGGG    ",
"       GGGGGGGGGGGGGGGGGGGGGG       ",
"          GGGGGGGGGGGGGGGG          ",
"                                    ",
"       Maybe you need Monero        ",
]

COLOR_MAP = [
"             OOOOOOOOOO             ",
"        OOOOOOOOOOOOOOOOOOOO        ",
"     OOOOOOOOOOOOOOOOOOOOOOOOOO     ",
"    OOOOOOOOOOOOOOOOOOOOOOOOOOOO    ",
"  OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO  ",
" OOOOOO  OOOOOOOOOOOOOOOOOO  OOOOOO ",
"OOOOOOO    OOOOOOOOOOOOOO    OOOOOOO",
"OOOOOOO      OOOOOOOOOO      OOOOOOO",
"OOOOOOO        OOOOOO        OOOOOOO",
"OOOOOOO   GG     OO     GG   OOOOOOO",
"OOOOOO    GGGG        GGGG    OOOOOO",
" OOOOO    GGGGGGG  GGGGGGG    OOOOO ",
"          GGGGGGGGGGGGGGGG          ",
"   GGGGGGGGGGGGGGGGGGGGGGGGGGGGGG   ",
"    GGGGGGGGGGGGGGGGGGGGGGGGGGGG    ",
"       GGGGGGGGGGGGGGGGGGGGGG       ",
"          GGGGGGGGGGGGGGGG          ",
"                                    ",
"       OOOOOOOOOOOOOOOOOOOOOO       ",
]

ROWS = len(ART_LINES)
COLS = len(ART_LINES[0])
RAIN_CHARS = "olo,.':;co|"

def rc(r, g, b, ch):
    return f"\033[38;2;{r};{g};{b}m{ch}"

ORANGE  = lambda ch: rc(255, 102,  0, ch)
GREY    = lambda ch: rc( 76,  76, 76, ch)
HEAD    = lambda ch: rc(255, 220, 180, ch)
TRAIL1  = lambda ch: rc(255, 140,  0, ch)
TRAIL2  = lambda ch: rc(220,  90,  0, ch)
TRAIL3  = lambda ch: rc(180,  60,  0, ch)
TRAIL4  = lambda ch: rc(120,  35,  0, ch)
TRAIL5  = lambda ch: rc( 70,  18,  0, ch)
TRAIL6  = lambda ch: rc( 30,   8,  0, ch)
RESET   = "\033[0m"
CLEAR   = "\033[2J\033[H"
HOME    = "\033[H"
HIDE_CUR= "\033[?25l"
SHOW_CUR= "\033[?25h"

def color_for(r, c):
    if c < len(COLOR_MAP[r]) and COLOR_MAP[r][c] == 'G':
        return GREY
    return ORANGE

def rch():
    return random.choice(RAIN_CHARS)

def write(s):
    sys.stdout.write(s)

def flush():
    sys.stdout.flush()

write(HIDE_CUR)
write(CLEAR)
flush()

# -------------------------------------------------------
# Phase 1: Full screen orange rain
# -------------------------------------------------------
pos  = [random.randint(0, ROWS) for _ in range(COLS)]
spd  = [random.randint(1, 3)    for _ in range(COLS)]
TRAIL_FNS = [HEAD, TRAIL1, TRAIL2, TRAIL3, TRAIL4, TRAIL5, TRAIL6]

for tick in range(55):
    out = [HOME]
    for r in range(ROWS):
        for c in range(COLS):
            diff = r - pos[c]
            if 0 <= -diff < len(TRAIL_FNS):
                out.append(TRAIL_FNS[-diff](rch()))
            else:
                out.append(RESET + " ")
        out.append(RESET + "\n")
    for c in range(COLS):
        pos[c] += spd[c]
        if pos[c] > ROWS + 6:
            pos[c] = -random.randint(0, 6)
            spd[c] = random.randint(1, 3)
    write("".join(out))
    flush()
    time.sleep(0.055)

# -------------------------------------------------------
# Phase 2: Resolve into logo
# -------------------------------------------------------
locked = [[False] * COLS for _ in range(ROWS)]
pos    = [random.randint(0, ROWS - 1) for _ in range(COLS)]
spd    = [random.randint(1, 2)        for _ in range(COLS)]

def col_has_content(c):
    return any(ART_LINES[r][c] != ' ' for r in range(ROWS))

active_cols = [c for c in range(COLS) if col_has_content(c)]

while active_cols:
    out = [HOME]
    for c in active_cols[:]:
        p = pos[c]
        for r in range(min(p, ROWS)):
            locked[r][c] = True
        pos[c] += spd[c]
        if pos[c] >= ROWS:
            for r in range(ROWS):
                locked[r][c] = True
            active_cols.remove(c)
    for r in range(ROWS):
        for c in range(COLS):
            ch = ART_LINES[r][c]
            p  = pos[c]
            diff = r - p
            if locked[r][c]:
                out.append(color_for(r, c)(ch))
            elif 0 <= -diff < 4 and ch != ' ':
                out.append(TRAIL1(rch()) if diff != 0 else HEAD(rch()))
            else:
                out.append(RESET + " ")
        out.append(RESET + "\n")
    write("".join(out))
    flush()
    time.sleep(0.06)

# -------------------------------------------------------
# Phase 3: Flash pulse then settle
# -------------------------------------------------------
for _ in range(3):
    write(HOME)
    for r, row in enumerate(ART_LINES):
        for c, ch in enumerate(row):
            if COLOR_MAP[r][c] == 'G':
                write(rc(180, 180, 180, '') + ch)  # flash to light grey
            else:
                write(rc(255, 220, 180, '') + ch)  # flash to warm white
        write(RESET + "\n")
    flush()
    time.sleep(0.08)
    write(HOME)
    for r, row in enumerate(ART_LINES):
        for c, ch in enumerate(row):
            write(color_for(r, c)(ch))
        write(RESET + "\n")
    flush()
    time.sleep(0.08)

write(CLEAR)
for r, row in enumerate(ART_LINES):
    for c, ch in enumerate(row):
        write(color_for(r, c)(ch))
    write(RESET + "\n")
write(SHOW_CUR)
flush()
PYEOF
