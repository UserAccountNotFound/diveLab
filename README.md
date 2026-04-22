<a href="https://www.neva-divers.ru/">
    <img src="https://github.com/UserAccountNotFound/diveLab/blob/main/LogoDiveCenter/render/logoND_full_transparent.svg" alt="Neva Divers Logo" title="Neva Divers" align="right" height="60" />
</a>
![Stability](https://img.shields.io/badge/stability-work_in_progress-lightgrey?style=flat&color=ffff00)

# DiveLab Neva Divers - OpenSCAD Models for Technical Diving

![Visitors](https://hitscounter.dev/api/hit?url=https%3A%2F%2Fgithub.com%2FUserAccountNotFound%2FdiveLab&label=Visitors&icon=github&color=%23198754&message=&style=flat&tz=UTC)
[![Downloads](https://img.shields.io/github/downloads/UserAccountNotFound/diveLab/total?color=007BFF&label=скачивания&style=for-the-badge)](https://github.com/UserAccountNotFound/diveLab/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![OpenSCAD](https://img.shields.io/badge/OpenSCAD-007BFF?style=for-the-badge&logo=openscad&logoColor=white)](https://openscad.org/)

> 📦 Параметрические 3D-модели вспомогательного оборудования для технического дайвинга, написанные на OpenSCAD.  

---

## ⚠️ Предупреждение ⚠️
Данные модели предназначены **исключительно для вспомогательного, организационного и некоммерческого оборудования** (держатели, клипсы, органайзеры, метки, адаптеры и т.п.).  
**Не используйте** их в силовых узлах, системах жизнеобеспечения или элементах, от которых напрямую зависит безопасность погружения.  
Всегда проводите самостоятельные тесты на прочность и химическую стойкость перед использованием в реальных погружениях.

---

## 🛠️ Как использовать

### 1. Установка OpenSCAD
Скачайте последнюю стабильную версию с [официального сайта](https://openscad.org/downloads.html). Поддерживаются Windows, macOS, Linux.

### 2. Настройка модели
Откройте файл `.scad` и отредактируйте блок переменных в начале:
```openscad
// === ПАРАМЕТРЫ ===
baseWidth            = 50;     // ширина основания, мм
baseLength           = 80;     // высота, мм
thickness            = 4;      // толщина, мм
ovalHoles_enabled    = true;   // тип углублений для ходового линя (по умолчанию овальный)
legHoles_enabled     = true;   // включить/отключить боковые вырезы для линя
cornerRadius         = 2.0;    // радиус скругления углов, мм
edgeRadius           = 0.6;    // радиус 3D‑фаски рёбер, мм
// ========================
```
Нажмите F5 → предпросмотр, F6 → рендер, F7 → экспорт в .stl

### 3. 3D-печать

| Параметр | Рекомендация |
|----------|--------------|
| Материал | PETG, ASA, Nylon, Carbon-filled PETG |
| Заполнение | ≥40% (для силовых элементов ≥60%) |
| Стенки | ≥3 периметра |
| Постобработка | Сглаживание ацетоном (для ASA) или шлифовка |
| Хранение | Промывка пресной водой после каждого погружения |
