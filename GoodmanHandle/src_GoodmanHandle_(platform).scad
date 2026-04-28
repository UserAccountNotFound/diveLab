// Крепление для подводного фонаря, фиксирующее его на тыльной стороне кисти
// Goodman handle (platform)
// vеrsion 0.1.0
//
// OpenSCAD model
// =============================================
use <../NevaDiversLogo/logoND_small.scad>

// === ПАРАМЕТРЫ ===
widthGrip           = 100;         // ширина хвата ручки (ширина внутренней части), мм
heightPlatform      = 70;          // высота площадки, мм
thickness           = 5;           // толщина площадки, мм


module flat_body() {
}


// --- СБОРКА ---
module build_detail () {
    union() {

    }
}

build_detail();