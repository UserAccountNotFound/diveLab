// Указатель направления для пещерного дайвинга
// Cave Diving Marker - REM (Non Direction)
// vеrsion 1.2
//
// OpenSCAD model
// =============================================


// === ПАРАМЕТРЫ ===
baseWidth            = 50;     // ширина основания, мм
baseLength           = 80;     // высота, мм
thickness            = 4;      // толщина, мм
ovalHoles_enabled    = true;   // тип углублений для ходового линя (по умолчанию овальный)
legHoles_enabled     = true;   // включить/отключить боковые вырезы для линя
cornerRadius         = 2.0;    // радиус скругления углов, мм
edgeRadius           = 0.6;    // радиус 3D‑фаски рёбер, мм

cutoutRadius         = 2.0;    // радиус круглых вырезов и углублений, мм
cutoutSpacing        = 25;     // расстояние между центрами вертикальных слотов, мм
cutoutSlotLength     = 6.0;    // длина прорези (слота), мм
cutoutOffsetFromBase = 35;     // отступ нижнего выреза от основания, мм

legHoleAngleOffset   = 0;      // доп. поворот относительно перпендикуляра, в градусах (не трогать)
legHole_y1           = 32;     // Y для левого бокового отверстия
legHole_y2           = 63;     // Y для правого бокового отверстия
diagonalAngle        = 25;     // угол прорезей от первого отверстия, в градусах

txtHeight            = 3;      // высота выпуклого текста
txtFonts             = "Free Schoolbook:style=Bold";
txt_DiveCenter       = "Neva Divers";
txt_Name             = "Повар";         


// === ПРОВЕРКИ ===
assert(thickness >= 2*edgeRadius, "thickness слишком маленькое значение для edgeRadius");
assert(cutoutRadius <= thickness/2, "cutoutRadius слишком большое значение для толщины");

// --- 2D: Основное тело ---
module flat_body() {
    polygon(points = [
        [0,            0],
        [baseWidth,   0],
        [baseWidth, baseLength],
        [0, baseLength]
    ]);
}
module rounding_corners_flat_body() {
    if (cornerRadius > 0) {
        minkowski() {
            offset(r = -cornerRadius)
                flat_body();
            circle(r = cornerRadius, $fn=30);
        }
    } else {
        flat_body();
    }
}

// --- 2D: Отверстия / Прорези ---
module circle_hole() {
    circle(r = cutoutRadius, $fn=30);
}
module oval_hole() {
    hull() {
        circle(r = cutoutRadius, $fn=30);
        translate([0, cutoutSlotLength - 2*cutoutRadius, 0])
            circle(r = cutoutRadius, $fn=30);
    }
}

// --- 2D: Размещение отверстий/углублений/прорезей ---
module all_cutouts() {

    y_pos_1  = cutoutOffsetFromBase;          // центр первого вертикального слота
    y_pos_2  = y_pos_1 + cutoutSpacing;         // центр второго вертикального слота

    // ПЕРВЫЙ ВЕРТИКАЛЬНЫЙ СЛОТ
    translate([(baseWidth / 2), y_pos_1, 0])
        if (ovalHoles_enabled) rotate(180) oval_hole(); else circle_hole();

    // ВТОРОЙ ВЕРТИКАЛЬНЫЙ СЛОТ
    translate([(baseWidth / 2), y_pos_2, 0])
        if (ovalHoles_enabled) rotate(0) oval_hole(); else circle_hole();

    if (legHoles_enabled) {
        // УГЛУБЛЕНИЕ В ОСНОВАНИИ
        translate([(baseWidth / 2), 0, 0])
            circle_hole();        
        // УГЛУБЛЕНИЕ В КРЫШКЕ
        translate([(baseWidth / 2), baseLength, 0])
            circle_hole();
        // ЛЕВОЕ БОКОВОЕ УГЛУБЛЕНИЕ на ЛЕВОЙ ГРАНИ
        translate([0, legHole_y1, 0])
            circle_hole();
        
        // ПРАВОЕ БОКОВОЕ УГЛУБЛЕНИЕ на ПРАВОЙ ГРАНИ
        translate([baseWidth, legHole_y2, 0])
            circle_hole();
    }

    // ДИАГОНАЛЬНАЯ ПРОРЕЗЬ ОТ ЦЕНТРА ПЕРВОГО СЛОТА К ПРАВОМУ БЕДРУ
    // параметрический угол и прорезь, выходящая за контур

    slot_extend_factor = 2.5;                   // множитель длины, чтобы наверняка выйти за контур
    slot_width_diag    = 2*cutoutRadius;       // ширина прорези

    x_dir = cos(diagonalAngle);
    y_dir = sin(diagonalAngle);

    hull() {
        translate([(baseWidth / 2), y_pos_1, 0])
            circle(r = slot_width_diag/2, $fn=30);

        translate([
            (baseWidth / 2) + slot_extend_factor * baseLength * x_dir,
            y_pos_1  + slot_extend_factor * baseLength * y_dir,
            0
        ])
            circle(r = slot_width_diag/2, $fn=30);
    }

    // ДИАГОНАЛЬНАЯ ПРОРЕЗЬ ОТ ЦЕНТРА ВТОРОГО СЛОТА К ЛЕВОМУ БЕДРУ
    // симметричный угол: 180 + diagonalAngle
    diagonalAngle_sym = 180 + diagonalAngle;
    x_dir_sym = cos(diagonalAngle_sym);
    y_dir_sym = sin(diagonalAngle_sym);

    hull() {
        translate([(baseWidth / 2), y_pos_2, 0])
            circle(r = slot_width_diag/2, $fn=30);

        translate([
            (baseWidth / 2) + slot_extend_factor * baseLength * x_dir_sym,
            y_pos_2  + slot_extend_factor * baseLength * y_dir_sym,
            0
        ])
            circle(r = slot_width_diag/2, $fn=30);
    }
}

// --- 3D: ОСНОВНОЕ ТЕЛО МАРКЕРА ---
module cave_marker() {
    union() {
        difference() {
            if (edgeRadius > 0) {
                minkowski() {
                    linear_extrude(height = thickness - 2*edgeRadius, center = true, convexity=3)
                        rounding_corners_flat_body();
                    sphere(r = edgeRadius, $fn=16);
                }
            } else {
                linear_extrude(height = thickness, center = true, convexity=3)
                    rounding_corners_flat_body();
            }

            // вырезаем все углубления и прорези
            linear_extrude(height = thickness + 2, center = true)
                all_cutouts();
        }


        y_pos_txt_1 = cutoutOffsetFromBase + (cutoutSpacing * 0.4); // центр первого первого текстового поля
        
        // наносим надписи        
        linear_extrude(height = txtHeight) {
            translate([(baseWidth / 2), y_pos_txt_1]) 
                rotate ([0, 0, diagonalAngle])
                    text(txt_DiveCenter, size=5, font=txtFonts, halign = "center", $fn=30);
            translate([(baseWidth / 2), 16]) 
                text(txt_Name, size=5, font=txtFonts, halign = "center", $fn=30);
        }
    }
}
// 
// --- СБОРКА ---
cave_marker();

// --- ИНФОРМАЦИЯ О МОДЕЛИ ---
echo(str("=== Cave Diving Marker - REM (Non Direction) ==="));
echo(str("Длина (высота) указателя: ", baseLength, " мм"));
echo(str("Ширина основания указателя: ", baseWidth, " мм"));
echo(str("Толщина указателя: ", thickness, " мм"));
echo(str("Радиус вырезов для ходового линя: ", cutoutRadius, " мм"));
echo(str("Боковые отверстия на левой грани Y=", legHole_y1, "мм; на правой Y=", legHole_y2, "мм"));