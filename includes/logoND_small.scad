// Малый логотип дайв клуба Neva Divers
// Version 1.1
//
// OpenSCAD model
// =============================================

// === ПАРАМЕТРЫ ===
$fn = 100;
short_font = "Noto Serif:style=Medium";

// Параметры волны
step = 0.5;      
length = 70;    
amplitude = 3;   
thickness = 1;   

module ellipse(w, k=0.6) {
    scale([w/2, w*k/2]) circle(r=1);
}

module oval_ring(w, t, k=0.6) {
    difference() {
        ellipse(w, k);
        ellipse(w - 2*t, k);
    }
}

module wave() {
    // Смещение для центрирования волны внутри овала 80
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
        // Рисуем узкие полоски, уходящие вниз
        translate([i, amplitude * cos(i * 5) - 25, 0])
        square([step * 1.5, 50], center=true);
    }
}

module txt_short_form () {
    translate([-4.5, 0, 0]) // Приподнят, чтобы не "тонул" в волне
    text("N", font = short_font, size = 15, halign = "center", valign = "center");
    translate([4.5, 0, 0]) // Приподнят, чтобы не "тонул" в волне
    text("D", font = short_font, size = 15, halign = "center", valign = "center");
}

// --- Сборка ---
module build_logo () {
    union() {
        // 1. Внутреннее кольцо (рамка 80)
        oval_ring(80, 2);

        // 2. Меридианы, обрезанные волной
        difference() {
            intersection() {
                oval_ring(60, 2, 0.8); // Вертикальный эллипс (меридиан)
                ellipse(76, 0.6);      // Ограничение внутренним пространством
            }
            wave_bottom_mask();        // Удаляем всё, что ниже волны
        }

        // 3. Сама линия волны
        intersection() {
            wave();
            ellipse(76, 0.6); // Чтобы концы волны не вылезали за рамку
        }
        // 4. Линии
        intersection() { // правая
            translate([30, 0, 0]) square([25, 2], center=true);
            ellipse(80, 0.6); // Чтобы концы волны не вылезали за рамку
        } 
        intersection() { // левая
            translate([-30, 0, 0]) square([25, 2], center=true);
            ellipse(80, 0.6); // Чтобы концы волны не вылезали за рамку
        }
        intersection() { //вертикальная
            translate([0, 20, 0]) square([2, 10], center=true);
            ellipse(80, 0.6); // Чтобы концы волны не вылезали за рамку
        }     
        
        // 6. Текст
        txt_short_form();
    }
}

// Запуск рендера
build_logo();
