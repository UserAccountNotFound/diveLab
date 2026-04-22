// Логотип дайв клуба Neva Divers
// Version 1.1
//
// OpenSCAD model
// ---------------------------------------------

// === ПАРАМЕТРЫ ===
$fn = 100;

shortTxtFont    = "Noto Serif:style=Bold";
longTxtFont     = "Noto Sans:style=ExtraCondensed Bold";
txtLogoSize     = 10;
//txtSpacing      = 4;  // расстояние между буквами

// Волна
step            = 0.5;      
length          = 70;    
amplitude       = 2;   
thickness       = 1;   

module ellipse(w, k=0.6) {
    scale([w/2, w*k/2]) circle(r=1);
}

module oval_ring(w, t, k=0.6) {
    difference() {
        ellipse(w, k);
        ellipse(w - 2*t, k);
    }
}

// --- ВОЛНА ---
module wave() {
    // Смещение для центрирования волны внутри овала
    translate([-25, -12, 0])
    for (i = [-20 : step : length]) {
        translate([i, amplitude * sin(i * 8), 0])
            circle(r = thickness, $fn = 20);
    }
}

// Маска, которая закрывает всё пространство НИЖЕ линии волны
module wave_bottom_mask() {
    translate([-25, -12, 0])
    for (i = [-20 : step : length]) {
        translate([i, amplitude * sin(i * 8) - 25, 0])
            square([step * 1.5, 50], center=true);
    }
}

// --- КОРОТКАЯ ФОРМА (ND) ---
module txt_short_form () {
    translate([-4.5, 0, 0])
        text("N", font = shortTxtFont, size = 14, halign = "center", valign = "center");
    translate([4.5, 0, 0])
        text("D", font = shortTxtFont, size = 14, halign = "center", valign = "center");
}

// --- ТЕКСТ ПО ЭЛЛИПТИЧЕСКОЙ ДУГЕ ---
module arc_text_ellipse(text_str, start_angle, end_angle, rx, ry, txt_size,
                        font=shortTxtFont, flip=false, txtSpacing=1) {

    chars = [for (i = [0 : len(text_str)-1]) text_str[i]];
    n = len(chars);

    // Базовый шаг по углу
    base_step = n > 1 ? (end_angle - start_angle) / (n - 1) : 0;

    // Поправка на желаемый интервал
    step = base_step * txtSpacing;

    // Центрируем строку, чтобы её не "уводило" при изменении spacing
    total_span = step * (n - 1);
    offset = (end_angle - start_angle - total_span) / 2;

    for (i = [0 : n-1]) {
        a_deg = start_angle + offset + i * step;

        x = rx * cos(a_deg);
        y = ry * sin(a_deg);

        dx = -rx * sin(a_deg);
        dy =  ry * cos(a_deg);

        tangent = atan2(dy, dx);
        normal = tangent + (flip ? 0 : 180);

        translate([x, y, 0])
            rotate(normal)
                text(chars[i], size=txt_size, font=font,
                     halign="center", valign="center", $fn=30);
    }
}

module txt_upper_ellipse() {
    // Эллипс текстовой дуги (по форме внешнего эллипса)
    innerOval       = 100;          // общая ширина эллипса
    innerOvalK      = 0.67;          // отношение высоты/ширины (0.6)
    
    // радиусы эллипса, на котором лежит текст
    rx = innerOval / 2;              // 55
    ry = innerOval * innerOvalK / 2; // 33

    // Уменьшаем высоту, чтобы текст не лез наружу
    rx_txt = rx - txtLogoSize/2;
    ry_txt = ry - txtLogoSize/2;
    
    // текст по верхней дуге эллипса: от 140 до 40 градусов
    arc_text_ellipse("NEVA DIVERS", 130, 50, rx_txt, ry_txt, 8, longTxtFont, false, 0.9);
}

module txt_lower_ellipse() {
    innerOval_bottom = 98;
    innerOvalK_bottom = 0.695;
    
    rx = innerOval_bottom / 2;
    ry = innerOval_bottom * innerOvalK_bottom / 2;

    // нижняя дуга, чуть больше
    rx_txt = rx - txtLogoSize/2;
    ry_txt = ry - txtLogoSize/2;

    arc_text_ellipse("ADVANCED", 195, 245, rx_txt, ry_txt, 6.5, longTxtFont, true, 1.03);
    arc_text_ellipse("TRAINING", 256, 294, rx_txt, ry_txt, 6.5, longTxtFont, true, 1.03);
    arc_text_ellipse("FACILITY", 304, 342, rx_txt, ry_txt, 6.5, longTxtFont, true, 1.03);
}

// --- СБОРКА ЛОГОТИПА ---
module build_logo () {
    union() {
        // 1. Внутренняя рамка
        oval_ring(66, 2, 0.66);

        // 2. Меридианы, обрезанные волной
        difference() {
            intersection() {
                oval_ring(49, 2, 0.87); // Вертикальный эллипс (меридиан)
                ellipse(63, 0.68);      // Ограничение внутренним пространством
            }
            wave_bottom_mask();        // Удаляем всё, что ниже волны
        }

        // 3. Линия волны
        intersection() {
            wave();
            ellipse(66, 0.66); // Чтобы концы волны не вылезали за рамку
        }

        // 4. Линии
        intersection() { // правая
            translate([25, 0, 0]) square([20, 2], center=true);
            ellipse(66, 0.6);
        }
        intersection() { // левая
            translate([-25, 0, 0]) square([20, 2], center=true);
            ellipse(66, 0.6);
        }
        intersection() { // вертикальная
            translate([0, 16, 0]) square([2, 10], center=true);
            ellipse(66, 0.6);
        }

        // 5. Текст
        txt_short_form();
        txt_upper_ellipse();
        txt_lower_ellipse();
        
        // 6. Точки
        translate([-40, 8])circle (2.6);
        translate([40, 8])circle (2.6);
        
        // 7. Внешняя рамка
        oval_ring(108, 2, 0.7);
    }
}

// Рендер
build_logo();
