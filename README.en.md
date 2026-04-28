<a href="https://www.neva-divers.ru/">
    <img src="https://github.com/UserAccountNotFound/diveLab/blob/main/NevaDiversLogo/render/logoND_full_tech.svg" alt="Neva Divers Logo" title="Neva Divers" align="right" height="120" />
</a>

<!-- README.en.md (EN) -->
[🇬🇧 English](#)  |  [🇷🇺 Русский](README.md)

![Stability](https://img.shields.io/badge/stability-work_in_progress-lightgrey?style=flat&color=ffff00) 
![Visitors](https://hitscounter.dev/api/hit?url=https%3A%2F%2Fgithub.com%2FUserAccountNotFound%2FdiveLab&label=Visitors&icon=github&color=%23198754&message=&style=flat&tz=UTC) 
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) 

[![OpenSCAD](https://img.shields.io/badge/OpenSCAD-007BFF?style=for-the-badge&logo=openscad&logoColor=white)](https://openscad.org/)

# DiveLab Neva Divers - storage OpenSCAD Models <br> for Technical Diving

> A library of parametric 3D models for auxiliary equipment for technical, cave, and recreational diving, written in OpenSCAD:
>
> ***Personalized Directional Markers (Arrow/Cookies/REM):***
>
> - ARROW: Indicates the direction to the nearest exit, helping to find the right path at guideline junctions
>
> - COOKIES: Round markers marking reel transfer points, the start of a transition to another line
>
> - REM: Indicates that a section is occupied (personal marker)
>
> ***Badges and Identification Elements***
>
> ***Mirrors for monitoring buddies, checking equipment, and signaling in low visibility conditions***
>
---

## ⚠️ Warning
These models are intended **exclusively for auxiliary, organizational, and non-critical equipment** (holders, clips, organizers, markers, adapters, etc.).

**Do not use** them in load-bearing systems, life support systems, or components that directly affect dive safety.

> Always conduct your own strength and chemical resistance tests before using in actual dives.

---

## 🛠️ How to Use

### 1. Install OpenSCAD
Download the latest stable version from the [official website](https://openscad.org/downloads.html). Supports Windows, macOS, Linux.

### 2. Configure the Model
Open the `.scad` file and edit the variables block at the beginning:
```openscad
// === PARAMETERS ===
baseWidth            = 50;     // base width, mm
baseLength           = 80;     // height, mm
thickness            = 4;      // thickness, mm
ovalHoles_enabled    = true;   // type of recesses for guideline (oval by default)
legHoles_enabled     = true;   // enable/disable side cutouts for line
cornerRadius         = 2.0;    // corner radius, mm
edgeRadius           = 0.6;    // 3D edge fillet radius, mm
// ========================
```
Press F5 → preview, F6 → render, F7 → export to .stl

### 3. 3D Printing

| Parameter       | Recommendation                                 |
|-----------------|------------------------------------------------|
| Material        | PETG, ASA, Nylon, Carbon-filled PETG           |
| Infill          | ≥40% (for load-bearing elements ≥60%)          |
| Walls           | ≥3 perimeters                                  |
| Post-processing | Dichloromethane smoothing (for ASA) or sanding |
| Storage         | Rinse with fresh water after each dive         |

## 🤝 How to Contribute

1. Fork the repository
2. Create a branch feature/your-idea
3. Make changes while following the parameterization style
4. Open a Pull Request with a description and screenshots

📐 Code Requirements:
- Fork the repository
- Create a branch feature/your-idea
- Make changes while following the parameterization style
- Open a Pull Request with a description and screenshots


### ***Print. Dive. Explore.***