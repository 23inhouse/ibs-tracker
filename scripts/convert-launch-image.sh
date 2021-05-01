#!/bin/bash

echo "convert to rgb"
convert AppIcon.png \
  -colorspace rgb \
  working/launch-image-rgb.png

open working/launch-image-rgb.png

echo "generate difference"
convert working/launch-image-rgb.png \( +clone 0--1 -fx 'p{0,0}' \) \
  -compose Difference \
  -composite -modulate 100,0 \+matte \
  working/launch-image-difference.png

open working/launch-image-difference.png

echo "remove background"
convert working/launch-image-difference.png \
  -bordercolor white \
  -border 1x1 \
  -matte \
  -fill none \
  -fuzz 7% \
  -draw 'alpha 1,1 floodfill' \
  -draw 'alpha 775,400 floodfill' \
  -draw 'alpha 945,400 floodfill' \
  -shave 1x1 \
  working/launch-image-removed-background.png

open working/launch-image-removed-background.png

echo "compose image to check mask"
composite  -compose Dst_Over \
  -tile pattern:checkerboard working/launch-image-removed-background.png \
  working/launch-image-removed-background-check.png

open working/launch-image-removed-background-check.png

echo "generate matte"
convert working/launch-image-removed-background.png \
  -channel matte \
  -separate \
  +matte \
  working/launch-image-matte.png

open working/launch-image-matte.png

echo "negate background"
convert working/launch-image-matte.png \
  -negate \
  -blur 0x0 \
  working/launch-image-matte-negated.png

open working/launch-image-matte-negated.png

echo "compose image"
composite -compose CopyOpacity \
  working/launch-image-matte.png working/launch-image-matte-negated.png \
  working/launch-image-finished.png

open working/launch-image-finished.png

echo "covert to 50 opacity"
convert working/launch-image-finished.png \
  -fill white \
  -colorize 50% \
  -channel RGBA \
  -blur 0x1 \
  working/launch-image-50%.png

echo "crop to 1337x1536"
convert working/launch-image-50%.png \
  -crop 1337x1536+0+0 \
  working/launch-image-cropped.png

convert working/launch-image-cropped.png \
  -gravity center \
  -background none \
  -extent 1536x1536 \
  launch-image-app-icon-@3.png

echo "resize to @2"
convert launch-image-app-icon-@3.png \
  -resize 50% \
  launch-image-app-icon-@2.png

echo "resize to @1"
convert launch-image-app-icon-@3.png \
  -resize 25% \
  launch-image-app-icon-@1.png

open launch-image-app-icon-@1.png launch-image-app-icon-@2.png launch-image-app-icon-@3.png

