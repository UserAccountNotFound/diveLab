// Крепление для подводного фонаря, фиксирующее его на тыльной стороне кисти
// Goodman handle (handle)
// vеrsion 1.1.0
//
// OpenSCAD model
// =============================================
use <../NevaDiversLogo/logoND_small.scad>

// === ПАРАМЕТРЫ ===
widthGrip           = 100;         // ширина хвата ручки (ширина внутренней части), мм
heightHandle        = 70;          // высота самой ручки (включая толщину детали), мм
widthHandle         = 20;          // ширина самой ручки, мм
thickness           = 5;           // толщина стенки ручки, мм

innerCornerRadius   = 10.0;        // радиус ВНУТРЕННИХ (вогнутых) углов выреза, мм
bottomCornerRadius  = 15.0;        // радиус НИЖНИХ внешних углов, мм

cutoutRadius        = 2.0;         // радиус круглых вырезов (слота), мм
cutoutSlotLength    = 30;          // длина прорези (слота), мм

edgeRadius          = thickness*0.49;           // скругление внешних фасок
// =================

// Переключатель качества для ускорения предпросмотра
preview_mode = false;  // true = быстрый рендер ($fn=8), false = нормальное качество ($fn=30)

// === ПРОВЕРКИ ПАРАМЕТРОВ ===
assert(thickness > 0, "Толщина стенки должна быть > 0");
assert(innerCornerRadius + thickness < heightHandle, 
        "Внутренние скругления не должны перекрывать высоту");
assert(bottomCornerRadius >= thickness, 
        "bottomCornerRadius должен быть ≥ thickness");
assert(edgeRadius <= min(thickness/2) , 
        "edgeRadius не должен превышать половину толщины!");
assert(2*edgeRadius < widthHandle, 
        "edgeRadius не должен превышать половину ширины ручки");
assert(cutoutSlotLength < heightHandle - (thickness + innerCornerRadius), 
       "Длина слота превышает доступное место на прямой стенке!");


// --- контур с постоянной толщиной стенки ---
module flat_body() {
    // Вспомогательная функция: генерация точек дуги
    function arc_points(cx, cy, r, start_angle, end_angle, segments=20) = 
        [for (i = [0:segments]) 
            let(a = start_angle + (end_angle - start_angle) * i / segments)
            [cx + r * cos(a), cy + r * sin(a)]
        ];

    // --- 1. НИЖНИЕ ВЫПУКЛЫЕ УГЛЫ ---
    // Внешние дуги
    R_bot_out = bottomCornerRadius;
    R_bot_in  = max(0, R_bot_out - thickness); // внутренняя дуга (если >0)
    
    left_bottom_outer  = arc_points(R_bot_out, R_bot_out, R_bot_out, 180, 270, 15);
    right_bottom_outer = arc_points((widthGrip+(thickness*2)) - R_bot_out, R_bot_out, R_bot_out, 270, 360, 15);
    
    // Внутренние дуги (только если радиус положительный)
    left_bottom_inner  = (R_bot_in > 0.1) ? 
        arc_points(R_bot_out, R_bot_out, R_bot_in, 180, 270, 15) : [[R_bot_out, R_bot_out]];
    right_bottom_inner = (R_bot_in > 0.1) ? 
        arc_points((widthGrip+(thickness*2)) - R_bot_out, R_bot_out, R_bot_in, 270, 360, 15) : [[(widthGrip+(thickness*2)) - R_bot_out, R_bot_out]];

    // --- 2. ВНУТРЕННИЕ ВОГНУТЫЕ УГЛЫ ---
    // Здесь "внутренний" угол выреза — это вогнутая дуга
    R_inner_in  = innerCornerRadius;                    // радиус вогнутой дуги
    R_inner_out = R_inner_in + thickness;              // сопряжённая выпуклая дуга
    
    // Центры дуг смещены на thickness от "острого" угла [thickness, thickness]
    cx_left  = thickness + R_inner_in;   // центр вогнутой дуги
    cy_left  = thickness + R_inner_in;
    
    cx_right = (widthGrip+(thickness*2)) - thickness - R_inner_in;
    cy_right = thickness + R_inner_in;
    
    // Вогнутые дуги (обход ПО часовой: углы убывают)
    left_inner_concave  = arc_points(cx_left, cy_left, R_inner_in, 270, 180, 12);
    right_inner_concave = arc_points(cx_right, cy_right, R_inner_in, 360, 270, 12);

    // --- СБОРКА (строго по часовой стрелке) ---
    points = concat(
        // Левая внешняя стенка
        [ [0, heightHandle], [0, R_bot_out] ],
        
        // Левый нижний внешний угол
        left_bottom_outer,
        
        // Прямой низ
        [ [(widthGrip+(thickness*2)) - R_bot_out, 0] ],
        
        // Правый нижний внешний угол
        right_bottom_outer,
        
        // Правая внешняя стенка
        [ [(widthGrip+(thickness*2)), R_bot_out], [(widthGrip+(thickness*2)), heightHandle] ],
        
        // Верхняя кромка до выреза
        [ [(widthGrip+(thickness*2)) - thickness, heightHandle] ],
        
        // Правая внутренняя стенка вниз до начала вогнутого скругления
        [ [(widthGrip+(thickness*2)) - thickness, heightHandle], 
          [(widthGrip+(thickness*2)) - thickness, thickness + R_inner_in] ],
        
        // Правый вогнутый угол выреза
        right_inner_concave,
        
        // Горизонталь ручки
        [ [thickness + R_inner_in, thickness] ],
        
        // Левый вогнутый угол выреза
        left_inner_concave,
        
        // Левая внутренняя стенка вверх
        [ [thickness, thickness + R_inner_in], [thickness, heightHandle] ]
    );
    
    polygon(points = points);
}

module body_3d_rounded() {
    sphere_fn = preview_mode ? 8 : 30;  // оптимизация для скорости (бук старенький)
    
    if (edgeRadius > 0) {
        minkowski() {
            // Компенсация «раздувания» от minkowski:
            // - 2D-контур уменьшаем на edgeRadius
            // - высота выдавливания уменьшается на 2*edgeRadius
            linear_extrude(height = widthHandle - 2*edgeRadius, convexity = 3)
                offset(r = -edgeRadius) flat_body();
            
            // Сфера скругляет рёбра во всех плоскостях (XY, YZ, XZ)
            sphere(r = edgeRadius, $fn = sphere_fn);
        }
    } else {
        // Без скругления — обычное выдавливание
        linear_extrude(height = widthHandle, convexity = 3)
            flat_body();
    }
}

// --- Отверстия ---
module hole() {
    hull() {
        circle(r = cutoutRadius, $fn=30);
          translate([0, cutoutSlotLength - 2*cutoutRadius])
            circle(r = cutoutRadius, $fn=30);
    }
}

// --- позиционирование в плоскости YZ ---
module hole_3d() {
    // Поворот на 90° вокруг Y: ось Z → становится осью X
    rotate([0, 90, 0])
        linear_extrude(height = thickness*2, center = true, convexity = 3)
            hole();
}

// --- позиционирование отверстий ----
module cutouts() {
    y_pos = heightHandle - widthHandle/2;
    
    // X: центры левой и правой стенок
    x_cut_left  = thickness/2;
    x_cut_right = (widthGrip + thickness*2) - thickness/2;
    
    // Z: центр детали по ширине
    z_pos = (widthHandle-edgeRadius*2) / 2;
    
    // левая 
    color("red")
    translate([x_cut_left, y_pos, z_pos])
      rotate([180,0,0])
        hole_3d();
    
    // Правая
    color("red")
    translate([x_cut_right, y_pos, z_pos])
      rotate([180,0,0])
        hole_3d();
}

// --- СБОРКА ---
module build_detail () {
    union() {
        difference() {
            body_3d_rounded();          
            cutouts();
        }
    }
}

build_detail();