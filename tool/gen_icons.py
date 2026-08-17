#!/usr/bin/env python3
"""Generates every Momentum raster icon from one vector mark. Pure stdlib.

The mark: a progress ring closing on a check, with a bright spark at the head
of the ring — the app's own ProgressRing motif, as a logo. The same geometry is
drawn in Dart by MomentumMark (lib/presentation/widgets/momentum_logo.dart), so
the launcher, the notification shade and the app header all carry one identity.

Run from anywhere: `python3 tool/gen_icons.py`
"""
import math
import os
import struct
import zlib

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                    "..", "android", "app", "src", "main", "res")

# ----------------------------------------------------------------- the mark
# All geometry lives in a 0..100 box. Keep in step with MomentumMark.

RING_CENTRE = (50.0, 50.0)
RING_RADIUS = 33.0
RING_STROKE = 8.5
# 320° of ring, leaving a 40° gap centred on the bottom.
RING_FROM, RING_TO = -70.0, 250.0
SPARK_RADIUS = 4.25

CHECK = [(34.0, 51.0), (45.0, 62.0), (67.0, 38.0)]
CHECK_STROKE = 9.0

INK = (0x06, 0x11, 0x0E)
WHITE = (0xF2, 0xFA, 0xF7)
TEAL_HI = (0x63, 0xF0, 0xD0)
TEAL_LO = (0x12, 0x9E, 0x86)
PLATE_HI = (0x1A, 0x1D, 0x23)
PLATE_LO = (0x08, 0x09, 0x0C)

# ------------------------------------------------------------------- output


def write_png(path, w, h, px):
    raw = b"".join(b"\x00" + px[y * w * 4:(y + 1) * w * 4] for y in range(h))

    def chunk(tag, data):
        body = tag + data
        return struct.pack(">I", len(data)) + body + struct.pack(
            ">I", zlib.crc32(body) & 0xFFFFFFFF)

    out = b"\x89PNG\r\n\x1a\n"
    out += chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0))
    out += chunk(b"IDAT", zlib.compress(raw, 9))
    out += chunk(b"IEND", b"")
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "wb") as f:
        f.write(out)


# -------------------------------------------------------- signed distances
# Every shape returns a signed distance in glyph units; `render` converts to
# pixels and turns that into antialiased coverage.


def seg_dist(px, py, ax, ay, bx, by):
    vx, vy = bx - ax, by - ay
    wx, wy = px - ax, py - ay
    length = vx * vx + vy * vy
    t = 0.0 if length == 0 else max(0.0, min(1.0, (wx * vx + wy * vy) / length))
    dx, dy = wx - t * vx, wy - t * vy
    return math.sqrt(dx * dx + dy * dy)


def polyline(points, width):
    def f(x, y):
        d = min(seg_dist(x, y, *points[i], *points[i + 1])
                for i in range(len(points) - 1))
        return d - width / 2
    return f


def arc(cx, cy, r, width, a0, a1):
    """Rounded-cap arc. Angles in degrees, 0 = east, counter-clockwise."""
    r0, r1 = math.radians(a0), math.radians(a1)
    caps = [(cx + r * math.cos(a), cy - r * math.sin(a)) for a in (r0, r1)]
    span = (r1 - r0) % (2 * math.pi)

    def f(x, y):
        angle = math.atan2(cy - y, x - cx)
        if (angle - r0) % (2 * math.pi) <= span:
            return abs(math.hypot(x - cx, y - cy) - r) - width / 2
        return min(math.hypot(x - ex, y - ey) for ex, ey in caps) - width / 2
    return f


def disc(cx, cy, r):
    return lambda x, y: math.hypot(x - cx, y - cy) - r


def squircle(pad=3.5, radius=22.5):
    def f(x, y):
        w = 100 - 2 * pad
        qx = abs(x - pad - w / 2) - (w / 2 - radius)
        qy = abs(y - pad - w / 2) - (w / 2 - radius)
        return (math.hypot(max(qx, 0), max(qy, 0))
                + min(max(qx, qy), 0) - radius)
    return f


def cover(d):
    """Antialiased coverage from a signed distance in pixels."""
    return max(0.0, min(1.0, 0.5 - d))


def lerp(a, b, t):
    t = max(0.0, min(1.0, t))
    return tuple(round(a[i] + (b[i] - a[i]) * t) for i in range(3))


def sweep(lo, hi):
    """Diagonal gradient across the glyph box."""
    return lambda x, y: lerp(lo, hi, (x + y) / 200)


# ------------------------------------------------------------------ layers


def spark_at(angle):
    cx, cy = RING_CENTRE
    rad = math.radians(angle)
    return disc(cx + RING_RADIUS * math.cos(rad),
                cy - RING_RADIUS * math.sin(rad), SPARK_RADIUS)


def mark(ring_color, check_color, spark_color):
    """Ring, spark and check — no plate."""
    return [
        {"sdf": arc(*RING_CENTRE, RING_RADIUS, RING_STROKE, RING_FROM, RING_TO),
         "color": ring_color},
        {"sdf": spark_at(RING_FROM), "color": spark_color},
        {"sdf": polyline(CHECK, CHECK_STROKE), "color": check_color},
    ]


PLATE_ART = [{"sdf": squircle(), "color": sweep(PLATE_HI, PLATE_LO)}] + mark(
    sweep(TEAL_HI, TEAL_LO), WHITE, TEAL_HI)

GLYPH_ART = mark(sweep(TEAL_HI, TEAL_LO), WHITE, TEAL_HI)
GLYPH_WHITE = mark(WHITE, WHITE, WHITE)
GLYPH_INK = mark(INK, INK, INK)


def render(size, layers, scale=1.0):
    """`scale` shrinks the 0..100 box inside the canvas, keeping it centred —
    that is how the adaptive layers get their safe-zone padding."""
    buf = bytearray(size * size * 4)
    unit = size * scale / 100.0
    offset = (size - size * scale) / 2.0

    for py in range(size):
        for px in range(size):
            gx = (px + 0.5 - offset) / unit
            gy = (py + 0.5 - offset) / unit
            r = g = b = 0
            a = 0.0
            for layer in layers:
                c = cover(layer["sdf"](gx, gy) * unit)
                if c <= 0:
                    continue
                col = layer["color"]
                if callable(col):
                    col = col(gx, gy)
                # Source-over onto whatever the earlier layers left.
                na = c + a * (1 - c)
                r = round((col[0] * c + r * a * (1 - c)) / na)
                g = round((col[1] * c + g * a * (1 - c)) / na)
                b = round((col[2] * c + b * a * (1 - c)) / na)
                a = na
            i = (py * size + px) * 4
            buf[i], buf[i + 1], buf[i + 2], buf[i + 3] = r, g, b, round(a * 255)
    return bytes(buf)


DENSITIES = [("mdpi", 1), ("hdpi", 1.5), ("xhdpi", 2), ("xxhdpi", 3),
             ("xxxhdpi", 4)]

# The ring spans 74.5 of the 100 box. Scales below are derived from that:
#   plate art  — ring fills ~80% of the padded plate, so no scaling
#   adaptive   — ring must sit inside the 66dp safe zone of the 108dp canvas
#   status bar — ring fills the whole 24dp box
RING_SPAN = (RING_RADIUS + RING_STROKE / 2) * 2 / 100
ADAPTIVE_SCALE = (66 / 108 * 0.87) / RING_SPAN
STATUS_SCALE = 0.98 / RING_SPAN


def emit(folder, name, base_dp, layers, scale=1.0):
    for density, factor in DENSITIES:
        size = int(base_dp * factor)
        path = os.path.join(ROOT, f"{folder}-{density}", f"{name}.png")
        write_png(path, size, size, render(size, layers, scale))
        print(f"  {folder}-{density}/{name}.png ({size}px)")


def main():
    print("legacy launcher")
    emit("mipmap", "ic_launcher", 48, PLATE_ART)

    print("adaptive foreground (paired with the dark plate in "
          "drawable/ic_launcher_background.xml)")
    emit("mipmap", "ic_launcher_foreground", 108, GLYPH_ART, ADAPTIVE_SCALE)

    print("adaptive monochrome (themed icons, Android 13+)")
    emit("mipmap", "ic_launcher_monochrome", 108, GLYPH_WHITE, ADAPTIVE_SCALE)

    print("notification large icon — must stay a real PNG, BitmapFactory "
          "cannot decode\nthe adaptive-icon XML that @mipmap/ic_launcher "
          "resolves to on API 26+")
    emit("drawable", "ic_notification_large", 64, PLATE_ART)

    print("notification small icon (Android masks it to a silhouette)")
    emit("drawable", "ic_notification", 24, GLYPH_WHITE, STATUS_SCALE)


if __name__ == "__main__":
    main()
