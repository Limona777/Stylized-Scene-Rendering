# Stylized Scene Rendering

> A Unity-based stylized rendering project featuring **Realistic Desert Rendering**, **Stylized Ocean Rendering**, and a suite of NPR (Non-Photorealistic Rendering) techniques — including dynamic sky, interactive sand, heat-wave post-processing, and buoyancy simulation.

[![Platform](https://img.shields.io/badge/Platform-PC-blue)]()
[![Engine](https://img.shields.io/badge/Engine-Unity-orange)]()
[![Language](https://img.shields.io/badge/Language-C%23%20%2F%20HLSL%20%2F%20Cg%20%2F%20ShaderLab-green)]()
[![Role](https://img.shields.io/badge/Role-Independent%20Development-purple)]()

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
  - [Realistic Style Desert Rendering](#realistic-style-desert-rendering)
  - [Stylized Ocean Rendering](#stylized-ocean-rendering)
- [Dependencies](#dependencies)
- [References](#references)

---

## Overview

This project is an independent research & development endeavor focused on **natural scene construction and stylized rendering** in Unity. It explores a range of rendering techniques across two core scenes:

1. **Realistic Style Desert** — A dynamic skybox system, interactive deformable sand, and heat-wave post-processing combine to form a cohesive, real-time desert environment.
2. **Stylized Ocean** — A stylized water body with planar reflections, refraction, subsurface scattering, foam, and a matching stylized beach, paired with a buoyancy simulation for floating objects.

All visual systems are implemented through custom ShaderLab shaders and C# scripts, with a strong emphasis on mathematical, texture-flexible, real-time solutions.

### Tech Stack

| Category | Details |
|---|---|
| **Platform** | PC (Windows / macOS) |
| **Engine** | Unity |
| **Programming Language** | C# / HLSL / Cg (ShaderLab) |
| **Render Pipeline** | Built-in Render Pipeline |
| **Role** | Independent Development |

---

## Features

### Realistic Style Desert Rendering

#### Dynamic Skybox
A dynamic skybox shader written in Unity ShaderLab, designed for desert scenes. It simulates various visual effects in real time based on the directional light, including:
- Day-night transitions driven by the sun's elevation angle (`sunY`), using `smoothstep` for smooth horizon fading of the sun and moon.
- Atmospheric scattering via **Rayleigh** and **Mie** phase functions, with height gradients and ground occlusion for enhanced realism.
- Multi-layer noise texture sampling (main texture, distortion texture, secondary noise) with UV warping, tiling, and time-driven animation for flowing, non-repetitive clouds and fog.
- Sun and moon halos using texture sampling with power-law attenuation; the moon achieves **crescent / gibbous** phases via offset vectors.
- Highly customizable via a large set of adjustable parameters and toggle switches for each effect layer.

#### Interactive Sand
A real-time terrain deformation system composed of the `TerrainCamera` C# script and custom shaders, based on depth detection:
- An orthographic camera captures the scene from above, using a replacement shader to render objects with a specific tag into a depth map.
- Results are accumulated into two alternating `RenderTexture`s, blending the previous height map with the current frame's depth each frame to record impressions and particle accumulation.
- The shader reads the dynamic height map, drives vertex displacement along the Y-axis, and reconstructs normals from neighboring-pixel height differences.
- Combined with **tessellation** and a custom **Oren-Nayar** diffuse lighting model for a realistic, rough sand appearance.

#### Heat Wave Post Processing
- Samples a time-varying noise texture to obtain random UV offsets.
- Applies dynamic pixel-position distortion to simulate the refraction effect of rising heat waves.

### Stylized Ocean Rendering

#### Ocean
A stylized water surface with the following pipeline:
- **Dynamic ripples** through dual sine-wave superposition in the vertex shader, driving vertex displacement and normal generation.
- **Planar reflection** via a mirror camera with oblique clipping and back-face flipping, sampled in the fragment shader with normal perturbation.
- **Water depth** from the depth texture, blending:
  - Refraction (Snell's-law-based background sampling + absorption-scattering ramp)
  - Fresnel-mixed reflection & refraction
  - Subsurface scattering (light-direction distortion + depth attenuation)
  - Two-layer foam (sinusoidal threshold + noise-based decay)
- Simplified **Cook-Torrance** specular highlights and additional light support.

#### Beach
A four-layer stylized beach shader:
1. **View-dependent normal blending** — Linearly blends shallow and steep normal maps based on the angle between the view direction and the normal (steepness) to obtain view-angle-varying micro-detail normals.
2. **Oren-Nayar diffuse lighting** — With special roughness handling (scaled light dot product, `lerp(0.5, 1)` brightness adjustment), combined with ambient occlusion and diffuse intensity.
3. **Blinn-Phong specular** — Double power to enhance highlight sharpness.
4. **Glitter effect** — Two time-offset noise textures multiplied together, raised to a power and clamped to produce random bright spots, mixed into the base color and specular.

#### Buoyancy
A **submersion-degree buoyancy model** for floating objects:
- Computes the immersion ratio (0–1) for each sampling point based on depth below the water surface.
- Determines the buoyancy application point by weighted average, applying upward acceleration equal to the average immersion × `gravityFloating`.
- Per-point drag as linear damping proportional to velocity, scaled by immersion and constrained to the local Z-axis.
- Additional angular and vertical damping to suppress oscillation.

---

## Dependencies

| Package | Version | Purpose |
|---|---|---|
| Unity Built-in Render Pipeline | — | Core rendering |
| No third-party packages required | — | Pure shader / script-based solution |

---

## References

### Project Repository
- **Stylized Scene Rendering** — GitHub. https://github.com/Limona777/Stylized-Scene-Rendering

### Academic & Technical Foundations
- **Oren-Nayar Reflectance Model** — Oren, M., & Nayar, S. K. (1994). *Generalization of the Lambertian model and implications for machine vision*. International Journal of Computer Vision, 14(3), 227–251.
- **Cook-Torrance Specular BRDF** — Cook, R. L., & Torrance, K. E. (1982). *A reflectance model for computer graphics*. ACM SIGGRAPH Computer Graphics, 15(3), 307–316.
- **Rayleigh & Mie Atmospheric Scattering** — Hosek, L., & Wilkie, A. (2012). *An analytic model for full spectral sky-dome radiance*. ACM SIGGRAPH.

### Implementation Inspiration
- **Planar Reflection (Water)** — Unity Community / Standard Assets water implementation reference.
- **Heat Wave Distortion (Speed Lines / Refraction)** — bzyzhang. *练习项目(十四)：速度线效果的实现*. Zhihu. https://zhuanlan.zhihu.com/p/427866097

### Art Reference
- Stylized natural scene construction (desert, ocean, beach) — original art direction.
