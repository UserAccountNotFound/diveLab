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
//txtLogoSpacing  = 10;  // расстояние между буквами

// Волна
step            = 0.5;      
length          = 70;    
amplitude       = 3;   
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
        translate([i, amplitude * cos(i * 5), 0])
            circle(r = thickness, $fn = 20);
    }
}

// Маска, которая закрывает всё пространство НИЖЕ линии волны
module wave_bottom_mask() {
    translate([-25, -12, 0])
    for (i = [-20 : step : length]) {
        translate([i, amplitude * cos(i * 5) - 25, 0])
            square([step * 1.5, 50], center=true);
    }
}

// --- КОРОТКАЯ ФОРМА (ND) ---
module txt_short_form () {
    translate([-4.5, 0, 0])
        text("N", font = shortTxtFont, size = 15, halign = "center", valign = "center");
    translate([4.5, 0, 0])
        text("D", font = shortTxtFont, size = 15, halign = "center", valign = "center");
}

// --- ТЕКСТ ПО ЭЛЛИПТИЧЕСКОЙ ДУГЕ ---
module arc_text_ellipse(text_str, start_angle, end_angle, rx, ry, txt_size, font=shortTxtFont, flip=false) {

    chars = [for(i=[0:len(text_str)-1]) text_str[i]];
    n = len(chars);

    delta_angle = end_angle - start_angle;
    angle_step = n > 1 ? delta_angle / (n - 1) : 0;

    for(i = [0:n-1]) {
        a_deg = start_angle + i * angle_step;

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
    innerOval       = 104;          // общая ширина эллипса
    innerOvalK      = 0.67;          // отношение высоты/ширины (0.6)
    
    // радиусы эллипса, на котором лежит текст
    rx = innerOval / 2;              // 55
    ry = innerOval * innerOvalK / 2; // 33

    // Уменьшаем высоту, чтобы текст не лез наружу
    rx_txt = rx - txtLogoSize/2;
    ry_txt = ry - txtLogoSize/2;
    
    // текст по верхней дуге эллипса: от 140 до 40 градусов
    arc_text_ellipse("NEVA DIVERS", 134, 46, rx_txt, ry_txt, 8, longTxtFont, false);
}

module txt_lower_ellipse() {
    innerOval_bottom = 106;
    innerOvalK_bottom = 0.66;
    
    rx = innerOval_bottom / 2;
    ry = innerOval_bottom * innerOvalK_bottom / 2;

    // нижняя дуга, чуть больше
    rx_txt = rx - txtLogoSize/2;
    ry_txt = ry - txtLogoSize/2;

    arc_text_ellipse("ADVANCED", 200, 245, rx_txt, ry_txt, 6, longTxtFont, true);
    arc_text_ellipse("TRAINING", 255, 293, rx_txt, ry_txt, 6, longTxtFont, true);
    arc_text_ellipse("FACILITY", 305, 340, rx_txt, ry_txt, 6, longTxtFont, true);
}

// --- СБОРКА ЛОГОТИПА ---
module build_logo () {
    union() {
        // 1. Внутренняя рамка
        oval_ring(80, 2);

        // 2. Меридианы, обрезанные волной
        difference() {
            intersection() {
                oval_ring(60, 2, 0.8); // Вертикальный эллипс (меридиан)
                ellipse(76, 0.6);      // Ограничение внутренним пространством
            }
            wave_bottom_mask();        // Удаляем всё, что ниже волны
        }

        // 3. Линия волны
        intersection() {
            wave();
            ellipse(76, 0.6); // Чтобы концы волны не вылезали за рамку
        }

        // 4. Линии
        intersection() { // правая
            translate([30, 0, 0]) square([25, 2], center=true);
            ellipse(80, 0.6);
        }
        intersection() { // левая
            translate([-30, 0, 0]) square([25, 2], center=true);
            ellipse(80, 0.6);
        }
        intersection() { // вертикальная
            translate([0, 20, 0]) square([2, 10], center=true);
            ellipse(80, 0.6);
        }

        // 5. Текст
        txt_short_form();
        txt_upper_ellipse();
        txt_lower_ellipse();
        
        // 6. Точки
        translate([-45, 8])circle (2.5);
        translate([45, 8])circle (2.5);
        
        // 7. Внешняя рамка
        oval_ring(112, 2, 0.67);
    }
}

// Рендер
build_logo();
