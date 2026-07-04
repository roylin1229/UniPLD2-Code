# UniPLD2: A Unified Framework for Efficient Point-Line Detection and Description

MATLAB implementation of **UniPLD2**, a unified framework for efficient feature point
and line segment detection and description.

UniPLD2 detects and describes feature points and line segments in a shared framework by
analyzing dedicated level lines and their differences. It provides both floating-point
and binary descriptors for point-line matching, with a design focused on efficient
deployment and visual localization.

## Highlights

- Unified detection and description of feature points and line segments.
- Shared level-line representation for point-line primitives.
- Floating-point and binary descriptors for efficient matching.
- MATLAB implementation with a simple demo script.
- Visual localization demo using UniPLD2 point-line features.

## Repository Contents

```text
.
+-- UPLD2.m                     # Main UniPLD2 entry point
+-- test.m                      # Minimal demo script
+-- 1.ppm, 3.ppm                # Example input images
+-- loc_demo.gif                # Visual localization demo preview
+-- UIPD.m, ULSD.m              # Point and line extraction modules
+-- extract_*_desc_*.m          # Point/line descriptor extraction
+-- G_gradient.m, gen_LLD.m     # Gradient and level-line difference construction
+-- smart_walk*.m, fitline.m    # Line segment support-region and fitting utilities
```

## Requirements

- MATLAB R2024b or later recommended.
- Image Processing Toolbox is required for functions such as `integralImage`,
  `rgb2gray`, and `imread`.

The demo was tested with MATLAB R2024b on Windows.

## Quick Start

Clone the repository and run the demo from the repository root:

```matlab
test
```

The demo reads `1.ppm` and `3.ppm`, then extracts UniPLD2 feature points, line segments,
and their descriptors.

Expected outputs in `test.m`:

```matlab
[kps1, kp_descs1, kp_descs_b1, kls1, kl_descs1, kl_descs_b1] = UPLD2(img1);
[kps3, kp_descs3, kp_descs_b3, kls3, kl_descs3, kl_descs_b3] = UPLD2(img3);
```

Output variables:

- `kps`: detected feature points
- `kp_descs`: floating-point feature point descriptors
- `kp_descs_b`: binary feature point descriptors
- `kls`: detected line segments
- `kl_descs`: floating-point line segment descriptors
- `kl_descs_b`: binary line segment descriptors

## Visual Localization Demo

UniPLD2 point-line features are used inside an existing mature visual localization demo
framework to show the resulting localization performance.

[![UniPLD2 visual localization demo](loc_demo.gif)](https://drive.google.com/file/d/1kr8EqvrS4JAB7krVde5xMZj6mSvNn6CC/view?usp=sharing)

Demo video:
[Google Drive](https://drive.google.com/file/d/1kr8EqvrS4JAB7krVde5xMZj6mSvNn6CC/view?usp=sharing)

## License

Please check the final project release for license terms before redistribution or
commercial use.
