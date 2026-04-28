$fn = 100;
// === ПАРАМЕТРЫ ===
baseWidth            = 70;          // базовая ширина, мм
baseLength           = 50;          // базовая длина, мм
baseThickness        = 5;           // толщина стенки ручки, мм
cornerRadius         = 5.0;         // радиус скругления углов, мм

cutoutRadius        = 7.5;
cutoutSlotLength    = 40;

module ellipse(w, k=0.75) {
    scale([w/2, w*k/2]) circle(r=1);
}

module leg_cutout () {
    translate([0, baseLength*2])
        ellipse(180);
}

module pee_hole() {
    hull() {
        circle(r = cutoutRadius);
          translate([cutoutSlotLength - 2*cutoutRadius, 0])
            circle(r = cutoutRadius);
    }
}

module basic_flat_body() {
    difference() {
        hull() {
            square(size = [baseWidth, baseLength], center = true);
            translate([baseLength/2, 0]) 
                ellipse(baseWidth);
            translate([-baseLength/2, 0]) 
                ellipse(baseWidth);
        }
        translate([0, baseLength])
            ellipse(baseLength*2.5, 0.45); // вырез для ног
        translate([0, -baseLength])
            ellipse(baseLength*2.5, 0.45);
        translate([-baseWidth, 0])
            circle(baseLength/3);
        translate([-30, 0])
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


// --- СБОРКА ---
module build_model () {
    basic_flat_body_rounded_corners();
}

// Рендер
build_model();