#!/usr/bin/env python3
"""Generate app icons for Android, iOS, and macOS from a source PNG using sips."""

import subprocess
import os
import sys

BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
SRC_ICON = os.path.join(BASE_DIR, 'assets', 'app_icon.png')

if not os.path.exists(SRC_ICON):
    print(f"ERROR: Source icon not found at {SRC_ICON}")
    sys.exit(1)

def run(cmd):
    print(f"+ {' '.join(str(c) for c in cmd)}")
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"ERROR: {result.stderr}")
        sys.exit(1)
    return result.stdout

def resize(src, dst, size):
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    run(['sips', '-Z', str(size), src, '--out', dst])

print("=== Generating Android icons ===")
android_sizes = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
}

for folder, size in android_sizes.items():
    dest = os.path.join(BASE_DIR, 'android', 'app', 'src', 'main', 'res', folder, 'ic_launcher.png')
    resize(SRC_ICON, dest, size)
    print(f"  -> {dest} ({size}x{size})")

adaptive_dir = os.path.join(BASE_DIR, 'android', 'app', 'src', 'main', 'res', 'mipmap-xxxhdpi')
resize(SRC_ICON, os.path.join(adaptive_dir, 'ic_launcher_foreground.png'), 192)

print("\n=== Generating iOS icons ===")
ios_dir = os.path.join(BASE_DIR, 'ios', 'Runner', 'Assets.xcassets', 'AppIcon.appiconset')
ios_sizes = [
    ('Icon-App-20x20@1x.png', 20),
    ('Icon-App-20x20@2x.png', 40),
    ('Icon-App-20x20@3x.png', 60),
    ('Icon-App-29x29@1x.png', 29),
    ('Icon-App-29x29@2x.png', 58),
    ('Icon-App-29x29@3x.png', 87),
    ('Icon-App-40x40@1x.png', 40),
    ('Icon-App-40x40@2x.png', 80),
    ('Icon-App-40x40@3x.png', 120),
    ('Icon-App-60x60@2x.png', 120),
    ('Icon-App-60x60@3x.png', 180),
    ('Icon-App-76x76@1x.png', 76),
    ('Icon-App-76x76@2x.png', 152),
    ('Icon-App-83.5x83.5@2x.png', 167),
    ('Icon-App-1024x1024@1x.png', 1024),
]
for filename, size in ios_sizes:
    dest = os.path.join(ios_dir, filename)
    resize(SRC_ICON, dest, size)
    print(f"  -> {dest} ({size}x{size})")

print("\n=== Generating macOS icons ===")
macos_dir = os.path.join(BASE_DIR, 'macos', 'Runner', 'Assets.xcassets', 'AppIcon.appiconset')
macos_sizes = [
    ('app_icon_16.png', 16),
    ('app_icon_32.png', 32),
    ('app_icon_64.png', 64),
    ('app_icon_128.png', 128),
    ('app_icon_256.png', 256),
    ('app_icon_512.png', 512),
    ('app_icon_1024.png', 1024),
]
for filename, size in macos_sizes:
    dest = os.path.join(macos_dir, filename)
    resize(SRC_ICON, dest, size)
    print(f"  -> {dest} ({size}x{size})")

print("\n=== Generating Windows ico ===")
run(['sips', '-Z', '256', SRC_ICON, '--out', '/tmp/app_icon_256.png'])
run(['python3', '-c', '''
import struct, sys
from pathlib import Path

# Create a minimal ICO from a 256x256 PNG
png = Path("/tmp/app_icon_256.png").read_bytes()
data_size = len(png)
ico = struct.pack("<HHH", 0, 1, 1)  # reserved=0, type=1(ico), count=1
ico += struct.pack("<BBBBHHII", 0, 0, 0, 0, 1, 32, data_size, 22)
ico += png
Path("''' + os.path.join(BASE_DIR, 'windows', 'runner', 'resources', 'app_icon.ico') + '''").write_bytes(ico)
print("Done")
'''])

print("\n✅ All app icons generated successfully!")
