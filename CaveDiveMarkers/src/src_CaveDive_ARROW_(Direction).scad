// Указатель направления для пещерного дайвинга
// Cave Diving Marker - Arrow (Direction)
// vеrsion 1.4.6
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
cutoutSpacing        = 24;     // расстояние между центрами вертикальных слотов, мм
cutoutSlotLength     = 6.0;    // длина прорези (слота), мм
cutoutOffsetFromBase = 16;     // отступ нижнего выреза от основания, мм

legHoleAngleOffset   = 0;      // доп. поворот относительно перпендикуляра, в градусах
diagonalAngle        = 30;     // угол от первого отверстия, градусах

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
        [baseWidth/2, baseLength]
    ]);
}
module rounding_corners_triangle() {
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
    hull() {
        circle(r = cutoutRadius, $fn=30);
    }
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

    x_center = baseWidth / 2;
    y_pos_1  = cutoutOffsetFromBase;          // центр первого вертикального слота
    y_pos_2  = y_pos_1 + cutoutSpacing;         // центр второго вертикального слота

    // ПЕРВЫЙ ВЕРТИКАЛЬНЫЙ СЛОТ
    translate([x_center, y_pos_1, 0])
        if (ovalHoles_enabled) rotate(180) oval_hole(); else circle_hole();

    // ВТОРОЙ ВЕРТИКАЛЬНЫЙ СЛОТ
    translate([x_center, y_pos_2, 0])
        if (ovalHoles_enabled) rotate(0) oval_hole(); else circle_hole();

    if (legHoles_enabled) {
        // УГЛУБЛЕНИЕ В ОСНОВАНИИ
        translate([x_center, 0, 0])
            circle_hole();        
        
        // УГЛУБЛЕНИЕ НА ЛЕВОМ БЕДРЕ на 1.25 * cutoutRadius выше центра первого слота        
        y_target_left = y_pos_1 + 1.25 * cutoutRadius;
        t_left = min(max(y_target_left / baseLength, 0), 1);

        pos_left = [
            (baseWidth/2) * t_left,
            baseLength * t_left
        ];

        leg_angle_left  = atan2(baseLength, baseWidth/2);
        hole_angle_left = leg_angle_left + 90 + legHoleAngleOffset;

        translate(pos_left)
            rotate(hole_angle_left)
                circle_hole();

        // УГЛУБЛЕНИЕ НА ПРАВОМ БЕДРЕ на 1.0 * cutoutRadius выше центра второго слота
        y_target_right = y_pos_2 + 2.0 * cutoutRadius;
        t_right = min(max(y_target_right / baseLength, 0), 1);

        pos_right = [
            baseWidth + (-baseWidth/2) * t_right,
            baseLength * t_right
        ];

        leg_angle_right  = atan2(baseLength, -baseWidth/2);
        hole_angle_right = leg_angle_right + 90 + legHoleAngleOffset;

        translate(pos_right)
            rotate(hole_angle_right)
                circle_hole();
    }

    // ДИАГОНАЛЬНАЯ ПРОРЕЗЬ ОТ ЦЕНТРА ПЕРВОГО СЛОТА К ПРАВОМУ БЕДРУ
    // параметрический угол и прорезь, выходящая за контур
    slot_extend_factor = 2.5;                   // множитель длины, чтобы наверняка выйти за контур
    slot_width_diag    = 1.5*cutoutRadius;       // ширина прорези

    x_dir = cos(diagonalAngle);
    y_dir = sin(diagonalAngle);

    hull() {
        translate([x_center, y_pos_1, 0])
            circle(r = slot_width_diag/2, $fn=30);

        translate([
            x_center + slot_extend_factor * baseLength * x_dir,
            y_pos_1  + slot_extend_factor * baseLength * y_dir,
            0
        ])
            circle(r = slot_width_diag/2, $fn=30);
    }


    // ДИАГОНАЛЬНАЯ ПРОРЕЗЬ ОТ ЦЕНТРА ВТОРОГО СЛОТА К ЛЕВОМУ БЕДРУ
    // зеркальный угол: 180 + diagonalAngle
    diagonalAngle_sym = 180 + diagonalAngle;
    x_dir_sym = cos(diagonalAngle_sym);
    y_dir_sym = sin(diagonalAngle_sym);

    hull() {
        translate([x_center, y_pos_2, 0])
            circle(r = slot_width_diag/2, $fn=30);

        translate([
            x_center + slot_extend_factor * baseLength * x_dir_sym,
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
                        rounding_corners_triangle();
                    sphere(r = edgeRadius, $fn=16);
                }
            } else {
                linear_extrude(height = thickness, center = true, convexity=3)
                    rounding_corners_triangle();
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
                    text(txt_DiveCenter, size=3, font=txtFonts, halign = "center", $fn=30);
            translate([(baseWidth / 2), 6]) 
                text(txt_Name, size=5, font=txtFonts, halign = "center", $fn=30);
        }
    }
}

// --- СБОРКА ---
cave_marker();

// --- ИНФОРМАЦИЯ О МОДЕЛИ ---
echo(str("=== Cave Diving Marker - Arrow (Direction) ==="));
echo(str("Длина (высота) указателя: ", baseLength, " мм"));
echo(str("Ширина основания указателя: ", baseWidth, " мм"));
echo(str("Толщина указателя: ", thickness, " мм"));
echo(str("Радиус вырезов для ходового линя: ", cutoutRadius, " мм"));