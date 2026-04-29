// Крепление для подводного фонаря, фиксирующее его на тыльной стороне кисти
// Goodman handle (platform)
// vеrsion 0.2.1
//
// OpenSCAD model
// =============================================
use <../NevaDiversLogo/logoND_small.scad>

// === Глобальные ПАРАМЕТРЫ === TODO: вынести в отдельный фаил!!!
lengthGrip          = 110;         // ширина хвата ручки (ширина внутренней части), мм
widthHandle         = 20;          // ширина площадки, мм
thickness           = 5;           // толщина площадки, мм
hole                = 5.0;  // диаметр отверстий для резинки


cutoutSlotLength    = 30;          // длина прорези (слота), мм

edgeRadius          = thickness*0.49;           // скругление внешних фасок

// Переключатель качества для ускорения предпросмотра
preview_mode = false;  // true = быстрый рендер ($fn=8), false = нормальное качество ($fn=30)

// --- локальные параметры ---

cutoutRadius        = hole/2;         // радиус отверстий, мм
widthDetail         = widthHandle;
lengthDetail        = lengthGrip;
widthRails          = (widthHandle/2 - edgeRadius - cutoutRadius)/3;

module body_rounding() {
    hull() {
        color ("green")
        translate([lengthDetail/2,edgeRadius,0])
        rotate([0,90,0])
        cylinder(h=lengthDetail, r=edgeRadius, center=true, $fn=30);

        color ("green")
        translate([lengthDetail/2,(widthDetail-edgeRadius),0])
        rotate([0,90,0])
        cylinder(h=lengthDetail, r=edgeRadius, center=true, $fn=30);
    }
}

module rails() {
    color ("magenta")
    translate([widthRails/2,edgeRadius + widthRails,0])
    cube ([widthRails,widthRails,thickness*2], center=true);
    
    color ("magenta")
    translate([widthRails/2,(widthDetail-(edgeRadius+widthRails)),0])
    cube ([widthRails,widthRails,thickness*2], center=true);

    color ("magenta")
    translate([(lengthDetail-widthRails/2),edgeRadius + widthRails,0])
    cube ([widthRails,widthRails,thickness*2], center=true);
    
    color ("magenta")
    translate([(lengthDetail-widthRails/2),(widthDetail-(edgeRadius+widthRails)),0])
    cube ([widthRails,widthRails,thickness*2], center=true);
}

module circle_hole() {
    hull() {
        circle(r = cutoutRadius, $fn=30);
    }
}
module cutouts() {
    color ("magenta")
    translate([lengthDetail/3, widthDetail/3])
        linear_extrude(height = thickness*2, center = true) {
          circle_hole();
        }

    color ("magenta")
    translate([lengthDetail/3, (widthDetail/3)*2])
        linear_extrude(height = thickness*2, center = true) {
          circle_hole();
        }
    color ("magenta")
    translate([(lengthDetail/3)*2, widthDetail/3])
        linear_extrude(height = thickness*2, center = true) {
          circle_hole();
        }
    color ("magenta")
    translate([(lengthDetail/3)*2, (widthDetail/3)*2])
        linear_extrude(height = thickness*2, center = true) {
          circle_hole();
        }
}

// --- СБОРКА ---
module build_detail () {
    union() {
        difference() {
            body_rounding();
            rails();
            cutouts();
        }
    }
}

build_detail();