// vеrsion 0.1.0

$fn = 100;
// === ПАРАМЕТРЫ ===
girthHip            = 600;          // длина окружности бедра, в мм (нужно мерять у человека)
perineumWidth       = 60;           // измереная ширина промежности

baseWidth            = 80;          // базовая ширина, мм
baseLength           = 50;          // базовая длина, мм
thickness            = 2;           // толщина стенки ручки, мм
cornerRadius         = 5.0;         // радиус скругления углов, мм

cutoutRadius        = 7.5;
cutoutSlotLength    = 50;

//=== Локальные параметры ===
PI = 3.1415926535;

R_hip = girthHip/(2*PI);

module ellipse(w, k=0.75) {
    scale([w/2, w*k/2]) circle(r=1);
}

//module leg_cutout () {
//    translate([0, baseLength*2])
//        ellipse(180);
//}

module pee_hole() {
    hull() {
        circle(r = cutoutRadius);
          translate([-cutoutSlotLength + cutoutRadius*2, 0])
            circle(r = cutoutRadius);
    }
}

module basic_flat_body() {
    difference() {
       hull() {
            square(size = [baseWidth, baseLength], center = true);
            translate([baseLength/2, 0]) 
                ellipse(baseWidth, 0.9);
            translate([-baseLength/4, 0]) 
                ellipse(baseWidth, 0.9);
        }
        
        translate([0, perineumWidth/2+R_hip])
            circle(R_hip); // вырез для ног
        translate([0, -(perineumWidth/2+R_hip)])
            circle(R_hip);
        translate([-(baseLength+cutoutRadius), 0])
            circle(cutoutRadius*2);
        translate([cutoutRadius*2, 0])
            pee_hole();
    }
}

module basic_flat_body_rounded_corners() {
    if (cornerRadius > 0) {
        minkowski() {
            offset(r = -cornerRadius)
                basic_flat_body();
            circle(r = cornerRadius);
        }
    } else {
        basic_flat_body();
    }
}

module tank() {
    difference() {
        hull() {
            translate([cutoutRadius*3, 0,-cutoutRadius])
                sphere(r=cutoutRadius*1.5, $fn=50);
            translate([-cutoutSlotLength+cutoutRadius*4, 0, -cutoutRadius])
                sphere(r=cutoutRadius*1.5, $fn=50);
        }
        linear_extrude(height = thickness*10) {
            basic_flat_body_rounded_corners();
        }
    }
}

module nozzle() {
}

// --- СБОРКА ---
module build_model () {
    union() {
        linear_extrude(height = thickness) {
            basic_flat_body_rounded_corners(); //плоскость прилегания
        }
        tank();
    }
}

// Рендер
build_model();