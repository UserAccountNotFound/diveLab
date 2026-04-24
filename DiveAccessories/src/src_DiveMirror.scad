// Держатель зеркала для дайвинга
// Diving Mirror Holder
// version 1.6.5
//
// OpenSCAD model
// =============================================

use <../../LogoDiveCenter/logoND_small.scad>

// === ПАРАМЕТРЫ ===
mirrorSize          = 75;            // диаметр зеркала, мм
depthMirrorSlot     = 4;             // глубина посадочного места зеркала, мм
baseWidth           = 77;            // диаметр основания, мм
bunjeeHoleDia       = 5;             // диаметр отверстий для банджи, мм
wallThickness       = 4;             // мм — толщина стенки корпуса
bungeeOffsetX       = 25;            // расстояние от центра (0) до центров цилиндров по оси X, мм
bungeeHoleOvershoot = 5;              // запас длины цилиндра по оси Y, мм

txtHeight           = 0.6;            // высота выпуклого текста
txtFont             = "Noto Sans:style=Bold";
txtSize             = 5;              // размер шрифта
txtSpacing          = 4.3;            // растояние между буквами
txtStrSec0          = "текст1";
txtStrSec90         = "текст2";
txtStrSec180        = "текст3";
txtStrSec270        = "текст4";

bottomTxtStr90      = "* ТРУДНО БЫТЬ ГЛУБЖЕ НАС *"; 
bottomTxtStr270     = "КАПИТАН";      // текст на дне
bottomTxtSize       = 5;              // размер шрифта на дне
bottomTxtHeight     = 0.6;            // высота выпуклого текста на дне
bottomTxtSpacing    = 4.3;

enable_logo         = true;           // вкл/выкл логотип
logo_scale          = 0.5;            // масштаб (0.5-1.0) 

// Расчётные параметры
innerDiameter = baseWidth - 2 * wallThickness;
baseLength = (depthMirrorSlot + 2) + (bunjeeHoleDia + 2);
bottomTextZ     = bunjeeHoleDia + 2 - bottomTxtHeight;      // высота от низа (мм)
bottomTextY     = innerDiameter/2-bottomTxtSize;     // расстояние от центра по Y (мм)

// --- ОТВЕРСТИЯ ДЛЯ БАНДЖИ (2 цилиндра, параллельны оси Y) ---
module bungee_holes() {
    // Длина цилиндра: перекрывает весь диаметр по Y + запас с двух сторон
    holeLength = baseWidth + 2 * bungeeHoleOvershoot;
    holeZ = (bunjeeHoleDia/2) + 2; // центрирование по высоте корпуса

    // Цилиндр 1 (положительное направление X)
    translate([bungeeOffsetX, 0, holeZ])
        rotate([90, 0, 0]) // поворот из Z в Y
            cylinder(h=holeLength, d=bunjeeHoleDia, $fn=30, center=true);

    // Цилиндр 2 (отрицательное направление X)
    translate([-bungeeOffsetX, 0, holeZ])
        rotate([90, 0, 0])
            cylinder(h=holeLength, d=bunjeeHoleDia, $fn=30, center=true);
}

// --- Текст на цилиндрической (боковой) поверхности ---
module surface_text(text_str, angle, txt_radius, height_pos, txt_height, size=4, spacing=13, font=txtFont) {
    length = len(text_str);
    
    if (length > 0) {  // Проверка пустой строки
        // количество интервалов между символами
        angle_offset = ((length - 1) * spacing) / 2;
        
        for(i = [0:1:length-1]) {
            // Позиция каждого символа относительно центра
            char_angle = angle + (i * spacing - angle_offset);
            
            rotate([0, 0, char_angle]) 
            translate([txt_radius, 0, height_pos])
            rotate([90, 0, 90]) 
            linear_extrude(height=txt_height)
            text(text_str[i], size=size, font=font, halign="center", valign="center", $fn=30);
        }
    }
}

// --- Текст по поверхности нижнего основания ---
module arc_bottom_text(text_str, start_angle, txt_radius, z_pos, txt_height, txt_size, txt_spacing, txt_rotate) {
    chars = [for(i=[0:len(text_str)-1]) text_str[i]];
    char_angle = txt_spacing / txt_radius * 180 / PI;  // угол на символ
    if (txt_rotate) {
        for(i = [0:len(chars)-1]) {
            char_angle_pos = start_angle + i * char_angle - (len(chars)-1) * char_angle / 2;
            
            rotate([0, 0, -char_angle_pos+90])
            translate([0, txt_radius, z_pos])
            rotate([180, 180, 0])  // Дополнительный поворот на 180° по X
            mirror([1,0,0])
            linear_extrude(height=txt_height)
            text(chars[i], size=txt_size, font=txtFont, 
                 halign="center", valign="center", $fn=30);
        }
    } else {
        for(i = [0:len(chars)-1]) {
            char_angle_pos = start_angle + i * char_angle - (len(chars)-1) * char_angle / 2;
            
            rotate([0, 0, char_angle_pos+90])
            translate([0, txt_radius, z_pos])
            mirror([1,0,0])
            //rotate([0, 0, 0])
            linear_extrude(height=txt_height)
            text(chars[i], size=txt_size, font=txtFont, 
                 halign="center", valign="center", $fn=30);
        }
    }
}

// === Модель ===
module dive_mirror_holder() {
    union(){
        difference() {
            // Основной корпус
            cylinder(h=baseLength, d=baseWidth, $fn=360);
            
            // Внутренняя полость
            translate([0, 0, -1])
                cylinder(h=(bunjeeHoleDia + 3), d=innerDiameter, $fn=360);

            // Посадочное место под зеркало
            translate([0, 0, (baseLength - depthMirrorSlot)])
                cylinder(h=(depthMirrorSlot + 1), d=mirrorSize, $fn=360);
            
            // Отверстия для банджи
            bungee_holes();
        }
        
        if (enable_logo) {
            translate([0, 0, bottomTextZ])
                rotate([0, 0, -90])
                    mirror([0,1,0])
                        linear_extrude(height=txtHeight)
                            scale(logo_scale) build_logo(); 
        }
        
        // Надписи
        surface_text(txtStrSec0, 0, baseWidth/2 - 1, baseLength/2, txtHeight, txtSize, txtSpacing, txtFont);
        surface_text(txtStrSec90, 90, baseWidth/2 - 1, baseLength/2, txtHeight, txtSize, txtSpacing, txtFont);
        surface_text(txtStrSec180, 180, baseWidth/2 - 1, baseLength/2, txtHeight, txtSize, txtSpacing, txtFont);
        surface_text(txtStrSec270, 270, baseWidth/2 - 1, baseLength/2, txtHeight, txtSize, txtSpacing, txtFont);
        
        arc_bottom_text(bottomTxtStr90, 0, bottomTextY, bottomTextZ, bottomTxtHeight, bottomTxtSize, bottomTxtSpacing, false);

        arc_bottom_text(bottomTxtStr270, 180, bottomTextY, bottomTextZ, bottomTxtHeight, bottomTxtSize, txtSpacing, true);
    }
}

// Сборка
dive_mirror_holder();

// --- ИНФОРМАЦИЯ О МОДЕЛИ ---
echo(str("=== Diving Accesories - DiveMirror 75mm (Holder) ==="));
echo(str("Расчетный диаметр банджи: ", bunjeeHoleDia, " мм"));