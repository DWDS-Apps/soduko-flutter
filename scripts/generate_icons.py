#!/usr/bin/env python3
"""Generate Sudoku-themed app icons for Android and iOS using ImageMagick."""

import subprocess
import os
import sys

BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))

def run(cmd):
    print(f"+ {' '.join(str(c) for c in cmd)}")
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"ERROR: {result.stderr}")
        sys.exit(1)
    return result.stdout

BASE_ICON = '/tmp/sudoku_base_icon.png'

# Step 1: Create gradient background (blue-purple diagonal)
run(['convert', '-size', '1024x1024',
     '-define', 'gradient:angle=135',
     'gradient:#1565C0-#0D47A1',
     BASE_ICON])

# Step 2: Lighten slightly
run(['convert', BASE_ICON, '-fill', 'white', '-colorize', '15%', BASE_ICON])

# Step 3: Draw outer rounded rectangle frame
run(['convert', BASE_ICON,
     '-fill', 'none',
     '-stroke', 'white', '-strokewidth', '8',
     '-draw', 'roundrectangle 112,112 912,912 40,40',
     BASE_ICON])

# Step 4: Draw thick 3x3 box grid lines (horizontal)
for i in range(1, 3):
    y = 112 + i * 267
    run(['convert', BASE_ICON,
         '-fill', 'none',
         '-stroke', 'white', '-strokewidth', '6',
         '-draw', f'line 112,{y} 912,{y}',
         BASE_ICON])

# Step 5: Draw thick 3x3 box grid lines (vertical)
for i in range(1, 3):
    x = 112 + i * 267
    run(['convert', BASE_ICON,
         '-fill', 'none',
         '-stroke', 'white', '-strokewidth', '6',
         '-draw', f'line {x},112 {x},912',
         BASE_ICON])

# Step 6: Draw thin cell grid lines (horizontal - skip the thick lines)
for i in [1, 2, 4, 5, 7, 8]:
    y = 112 + i * 89
    run(['convert', BASE_ICON,
         '-fill', 'none',
         '-stroke', 'rgba(255,255,255,0.3)', '-strokewidth', '3',
         '-draw', f'line 112,{y} 912,{y}',
         BASE_ICON])

# Step 7: Draw thin cell grid lines (vertical - skip the thick lines)
for i in [1, 2, 4, 5, 7, 8]:
    x = 112 + i * 89
    run(['convert', BASE_ICON,
         '-fill', 'none',
         '-stroke', 'rgba(255,255,255,0.3)', '-strokewidth', '3',
         '-draw', f'line {x},112 {x},912',
         BASE_ICON])

# Step 8: Place numbers in a Sudoku-like pattern
# Numbers positioned at center of each cell: 112 + col*89 + 44 (centroid)
numbers = [
    # (row, col, number, color_hex)
    (0, 0, '5', '#FFD54F'),
    (1, 1, '3', '#B2FF59'),
    (2, 2, '7', '#FF8A80'),
    (3, 3, '6', '#FFD54F'),
    (4, 4, '1', '#82B1FF'),
    (5, 5, '9', '#B2FF59'),
    (6, 6, '8', '#FFD54F'),
    (7, 7, '2', '#82B1FF'),
    (8, 8, '4', '#FF8A80'),
]

font_name = 'DejaVu-Sans-Bold'

for row, col, num, color in numbers:
    cx = 112 + col * 89 + 44
    cy = 112 + row * 89 + 44
    run(['convert', BASE_ICON,
         '-font', font_name,
         '-fill', color,
         '-pointsize', '56',
         '-gravity', 'NorthWest',
         '-annotate', f'+{cx-28}+{cy-32}', num,
         BASE_ICON])

print("\n=== Generating Android icons ===")
android_sizes = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
}

for folder, size in android_sizes.items():
    dest = os.path.join(BASE_DIR, 'android', 'app', 'src', 'main', 'res', folder, 'ic_launcher.png')
    run(['convert', BASE_ICON, '-resize', f'{size}x{size}', dest])
    print(f"  -> {dest} ({size}x{size})")

# Generate adaptive icon foreground
adaptive_dir = os.path.join(BASE_DIR, 'android', 'app', 'src', 'main', 'res', 'mipmap-xxxhdpi')
run(['convert', BASE_ICON, '-resize', '192x192',
     os.path.join(adaptive_dir, 'ic_launcher_foreground.png')])

print("\n=== Generating iOS icons ===")
ios_dir = os.path.join(BASE_DIR, 'ios', 'Runner', 'Assets.xcassets', 'AppIcon.appiconset')

ios_sizes = {
    'Icon-App-20x20@1x.png': 20,
    'Icon-App-20x20@2x.png': 40,
    'Icon-App-20x20@3x.png': 60,
    'Icon-App-29x29@1x.png': 29,
    'Icon-App-29x29@2x.png': 58,
    'Icon-App-29x29@3x.png': 87,
    'Icon-App-40x40@1x.png': 40,
    'Icon-App-40x40@2x.png': 80,
    'Icon-App-40x40@3x.png': 120,
    'Icon-App-60x60@2x.png': 120,
    'Icon-App-60x60@3x.png': 180,
    'Icon-App-76x76@1x.png': 76,
    'Icon-App-76x76@2x.png': 152,
    'Icon-App-83.5x83.5@2x.png': 167,
    'Icon-App-1024x1024@1x.png': 1024,
}

for filename, size in ios_sizes.items():
    dest = os.path.join(ios_dir, filename)
    run(['convert', BASE_ICON, '-resize', f'{size}x{size}', dest])
    print(f"  -> {dest} ({size}x{size})")

print("\n✅ All app icons generated successfully!")
