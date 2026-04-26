// Именной Бейдж для дайв оборудования
// Badge - Diving Tank
// vеrsion 1.0.0
//
// OpenSCAD model
// =============================================
use <../NevaDiversLogo/logoND_small.scad>

// === ПАРАМЕТРЫ ===
baseWidth            = 18;          // ширина основания, мм
baseLength           = 50;          // высота, мм
thickness            = 3;           // толщина, мм

cornerRadius         = 5.0;         // радиус скругления углов, мм
edgeRadius           = 0.6;         // радиус 3D‑фаски рёбер, мм
hole                 = 3;           // диаметр отверстий под баджи

enable_logo          = true;        // вкл/выкл логотип
logo_scale           = 0.2;        // масштаб (0.5-1.0)

txtFonts             = "Xanmono:style=Regular";
txtStr1              = "Капитан";

// --- 2D: тело ---
module flat_body() {
    polygon(points = [
        [0,            0],
        [0,   baseWidth],
        [baseLength,   baseWidth],
        [baseLength, 0]
    ]);
}

module body_rounded_corners() {
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

module body_frame() {
    difference() {
        body_rounded_corners();

        // внутренний контур с «отступом» >= thickness
        offset(r = -thickness/2)
            body_rounded_corners();
    }
}

module valve(){
    union() {
        translate([-(baseWidth/20)*6, (baseWidth/20)*8, 0])
            square([(baseWidth/20)*6, (baseWidth/20)*4]);
        
        translate([-(baseWidth/20)*5, (baseWidth/20)*6, 0])
            square([(baseWidth/20)*3, (baseWidth/20)*2]);
        
        translate([-(baseWidth/20)*6, (baseWidth/20)*10, 0])
            circle(r = (baseWidth/20)*2, $fn=30);
        
        color("red") // должно стать углублением
        translate([-(baseWidth/20)*6, (baseWidth/20)*10, 0])
            circle(r = (baseWidth/20)*1.5, $fn=30);
        
        translate([-(baseWidth/20)*3.5, (baseWidth/20)*8, 0])
            polygon(points=[[0,0],[-(baseWidth/20)*2,(baseWidth/20)*6],[(baseWidth/20)*2,(baseWidth/20)*6]]);        
    }
}

module circle_hole() {
    hull() {
        circle(r = hole/2, $fn=30);
    }
}
module cutouts() {
    color ("magenta")
    translate([(baseWidth/20)*4, (baseWidth/20)*15,thickness/2])
        linear_extrude(height = thickness*2, center = true) {
        circle_hole();
        }

    color ("magenta")
    translate([(baseWidth/20)*4, (baseWidth/20)*5,thickness/2])
        linear_extrude(height = thickness*2, center = true) {
        circle_hole();
        }
}



// --- СБОРКА  ---
module build_bange () {
    difference() {
        union() {
            linear_extrude(height = thickness/2, convexity=3) {
                body_rounded_corners();
            }
            linear_extrude(height = thickness, convexity=3) {
                valve();
            }
            translate([0,0,thickness/2])
            linear_extrude(height = thickness/2, convexity=3) {
                body_frame();
            }
            // ответстия
       
            // лого 
            color ("blue")
            if (enable_logo) {
                translate([(baseWidth/20)*12, (baseWidth/2), thickness/2])
    //                rotate([0, 0, 90])
                            linear_extrude(height=thickness/2, convexity=3)
                                scale(logo_scale) build_logo(); 
            }
            // имя 
            color ("magenta")
            translate([(baseWidth), (baseWidth/2), thickness/2])
                linear_extrude(height = thickness/2, convexity=3) {
                    text(txtStr1, size=3, font=txtFonts, halign = "left", valign="center", $fn=30);
                }
        }
        cutouts();
    }
}

// Рендер
build_bange();
