// Ходовой Маркер для пещерного дайвинга
// Cave Diving Marker - Cookies (Non-Direction)
// vеrsion 1.1
//
// OpenSCAD model
// =============================================

use <../../NevaDiversLogo/logoND_small.scad>

// === ПАРАМЕТРЫ ===
baseSize             = 60;     // диаметр основания, мм
thickness            = 4;      // толщина, мм
ovalHoles_enabled    = true;   // тип углублений для ходового линя (по умолчанию овальный)
legHoles_enabled     = true;   // включить/отключить боковые вырезы для линя
cornerRadius         = 2.0;    // радиус скругления углов, мм
edgeRadius           = 0.6;    // радиус 3D‑фаски рёбер, мм

cutoutRadius         = 2.0;    // радиус круглых вырезов и углублений, мм
cutoutSpacing        = 25;     // расстояние между центрами вертикальных слотов, мм
cutoutSlotLength     = 6.0;    // длина прорези (слота), мм
cutoutOffsetFromCenter = 12;     // отступ от центра, мм

legHoleAngleOffset   = 0;      // доп. поворот относительно перпендикуляра, в градусах (не трогать)
legHole_y1           = 32;     // Y для левого бокового отверстия
legHole_y2           = 63;     // Y для правого бокового отверстия
diagonalAngle        = 0;      // угол прорезей от первого отверстия, в градусах

enable_logo          = true;        // вкл/выкл логотип
logo_scale           = 0.35;        // масштаб (0.5-1.0) 

txtHeight            = 0.3;           // высота выпуклого текста
txtFonts             = "Noto Sans:style=Bold";
txtSize              = 6;
txtStr1              = "Текст1";

centerBody = baseSize/2;

// --- 2D: Основное тело ---
module flat_body() {
    translate([centerBody, centerBody, 0])
    circle (d=baseSize, $fn=360);
};

// --- 2D: Отверстия / Прорези ---
module circle_hole() {
    circle(r = cutoutRadius, $fn=36);
}
module oval_hole() {
    hull() {
        circle(r = cutoutRadius, $fn=36);
        translate([0, cutoutSlotLength - 2*cutoutRadius, 0])
            circle(r = cutoutRadius, $fn=36);
    }
}

// --- 2D: Размещение отверстий/углублений/прорезей ---
module all_cutouts() {

    yPos_1  = centerBody + cutoutOffsetFromCenter;        // центр первого вертикального слота
    yPos_2  = centerBody - cutoutOffsetFromCenter;        // центр второго вертикального слота

    // Центральные вертикальные слоты
    translate([centerBody, yPos_1, 0])
        if (ovalHoles_enabled) rotate(0) oval_hole(); else circle_hole();

    translate([centerBody, yPos_2, 0])
        if (ovalHoles_enabled) rotate(180) oval_hole(); else circle_hole();

    // Центральные отверстия на "основании" и "крышке"
    if (legHoles_enabled) {
        translate([centerBody, 0, 0]) circle_hole();  // низ
        translate([centerBody, baseSize, 0]) circle_hole(); // верх
    }

    // Диагональные прорези (адаптированы для круга)
    slot_extend_factor = 1.8;  // меньше для круга
    slot_width_diag    = 2*cutoutRadius;

    // Первая прорезь
    x_dir = cos(diagonalAngle);
    y_dir = sin(diagonalAngle);
    hull() {
        translate([centerBody, yPos_1, 0])
            circle(r = slot_width_diag/2, $fn=30);
        translate([
            centerBody + slot_extend_factor * (baseSize/2) * x_dir,
            yPos_1 + slot_extend_factor * (baseSize/2) * y_dir,
            0
        ])
            circle(r = slot_width_diag/2, $fn=36);
    }

    // Вторая прорезь (через 180 градусов)
    diagonalAngle_sym = 180 + diagonalAngle;
    x_dir_sym = cos(diagonalAngle_sym);
    y_dir_sym = sin(diagonalAngle_sym);
    hull() {
        translate([centerBody, yPos_2, 0])
            circle(r = slot_width_diag/2, $fn=36);
        translate([
            centerBody + slot_extend_factor * (baseSize/2) * x_dir_sym,
            yPos_2 + slot_extend_factor * (baseSize/2) * y_dir_sym,
            0
        ])
            circle(r = slot_width_diag/2, $fn=36);
    }
}

// --- 3D: ОСНОВНОЕ ТЕЛО МАРКЕРА ---
module cave_marker() {
    union() {
        difference() {
            if (edgeRadius > 0) {
                minkowski() {
                    linear_extrude(height = thickness - 2*edgeRadius, center = true, convexity=3)
                        flat_body();
                    sphere(r = edgeRadius, $fn=16);
                }
            } else {
                linear_extrude(height = thickness, center = true, convexity=3)
                    flat_body();
            }

            // вырезаем все углубления и прорези
            linear_extrude(height = thickness + 2, center = true)
                all_cutouts();
        }

        y_pos_txt_1 = centerBody - txtSize/2; // центр первого первого текстового поля
        
        color ("blue")
        // наносим лого 
        if (enable_logo) {
            translate([centerBody-baseSize/4, baseSize*0.6, thickness/2])
                rotate ([0, 0, diagonalAngle+90])
                    linear_extrude(height=txtHeight, convexity=3)
                        scale(logo_scale) build_logo(); 
        } 
        
        // наносим надписи
        color ("magenta")
        translate([0, 0, thickness/2])       
        linear_extrude(height = txtHeight) {
            translate([centerBody+baseSize/4, baseSize/6])
            //translate([centerBody, y_pos_txt_1]) 
                rotate ([0, 0, diagonalAngle+90])
                    text(txtStr1, size=txtSize, font=txtFonts, halign = "left", $fn=30);
        }
    }
}
// 
// --- СБОРКА ---
cave_marker();