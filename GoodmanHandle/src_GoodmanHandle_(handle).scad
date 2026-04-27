// Крепление для подводного фонаря, фиксирующее его на тыльной стороне кисти
// Goodman handle (handle)
// vеrsion 1.0.0
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

edgeRadius          = 2;           // скругление внешних фасок
// =================

// --- МОДУЛЬ: контур с постоянной толщиной стенки ---
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

    // --- 2. ВНУТРЕННИЕ ВОГНУТЫЕ УГЛЫ (вырез под ручку) ---
    // Здесь "внутренний" угол выреза — это вогнутая дуга
    R_inner_in  = innerCornerRadius;                    // радиус вогнутой дуги
    R_inner_out = R_inner_in + thickness;              // сопряжённая выпуклая дуга
    
    // Центры дуг смещены на thickness от "острого" угла выреза [thickness, thickness]
    cx_left  = thickness + R_inner_in;   // центр вогнутой дуги (внутри материала)
    cy_left  = thickness + R_inner_in;
    
    cx_right = (widthGrip+(thickness*2)) - thickness - R_inner_in;
    cy_right = thickness + R_inner_in;
    
    // Вогнутые дуги (обход ПО часовой: углы убывают)
    left_inner_concave  = arc_points(cx_left, cy_left, R_inner_in, 270, 180, 12);
    right_inner_concave = arc_points(cx_right, cy_right, R_inner_in, 360, 270, 12);

    // --- СБОРКА КОНТУРА (строго по часовой стрелке) ---
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
        
        // Горизонталь выреза (дно "паза")
        [ [thickness + R_inner_in, thickness] ],
        
        // Левый вогнутый угол выреза
        left_inner_concave,
        
        // Левая внутренняя стенка вверх
        [ [thickness, thickness + R_inner_in], [thickness, heightHandle] ]
        // Замыкание на [0, heightHandle] происходит автоматически
    );
    
    polygon(points = points);
}

module flat_body_with_rounded_corners() {
    if (edgeRadius > 0) {
        minkowski() {
            offset(r = -edgeRadius)
                flat_body();
            circle(r = edgeRadius, $fn=30);
        }
    } else {
        flat_body();
    }
}

module hole() {
    hull() {
        circle(r = cutoutRadius, $fn=30);
          translate([0, -(cutoutSlotLength - 2*cutoutRadius)])
            circle(r = cutoutRadius, $fn=30);
    }
}

// --- Размещение отверстий/углублений/прорезей ---
module cutouts() {
    z_center = widthHandle/2;
    y_pos  = heightHandle - widthHandle/2;            // центр первого вертикального слота по оси Y
    x_pos_1  = thickness/2;                           // центр первого вертикального слота по оси X
    x_pos_2  = thickness + widthGrip + thickness/2;   // центр второго вертикального слота по оси X
    
    color ("red")
      rotate([0, -90, 0])
        translate([z_center, y_pos, -x_pos_1])        // !!! поебень с координатами из-за вращения
          linear_extrude(height = thickness*2, center = true, convexity=3) {
            hole();
        }
    color ("red")
      rotate([0, -90, 0])
        translate([z_center, y_pos, -x_pos_2]) 
          linear_extrude(height = thickness*2, center = true, convexity=3) {
            hole();
        }
}

// --- СБОРКА ---
module build_detail () {
    union() {
        difference() {
            linear_extrude(height = widthHandle, convexity=3) {
                flat_body_with_rounded_corners();
            }    
                cutouts();
        }
    }
}

build_detail();