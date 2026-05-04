// Крепление для подводного фонаря, фиксирующее его на тыльной стороне кисти
// Goodman handle (GoPro mount)
// vеrsion 1.0.0
//
// OpenSCAD model
// =============================================

$fa = 2;
$fs = 0.25;

widthMount = 8;     // ширина стоек крепления
heightMount = 4;    // высота стоек крепления

module rack(widthMount) {
	color("green")
    rotate([90, 0, 0])
	union()
	{
		translate([3.5, (-7.5), 0])
			cube([4 + heightMount, 15, widthMount]);


		translate([0, (-7.5), 0])
			cube([7.5 + heightMount, 4, widthMount]);

		translate([0, 3.5, 0])
			cube([7.5 + heightMount, 4, widthMount]);

		difference()
		{
			cylinder(h = widthMount, d = 15);

			color("red")
            translate([0, 0, (-1)])
				cylinder(h = widthMount + 2, d = 6);
		}
	}
}


module bolt_mount() {
	color("red")
    rotate([0, 90, 0])                  // доворот углубления для гайки (по оси Y)
	rotate([90, 0, 0])                  // углубления для гайки (по оси X)
		for(i = [0:(360 / 3):359])      // 3 куба
		{
			rotate([0, 0, i])
				cube([4.6765, 8.1, 5], center = true);  //4.6188 = S*tan(30градусов), S=8мм (ключ для гайки М5 )
		}
}

module thin_mounts() {
	union() {

		translate([0, 4, 0])
		rack(3);

		translate([0, 10.5, 0])
		rack(3);
	}
}

module thick_mount() {
	//union() {
		difference() {
			translate([0, (-2.5), 0])
				rack(8);
            
            translate([0, (-8.5), 0])
                bolt_mount();

		}
	//}
}



// --- СБОРКА ---
module mount_GoPro_build() {
	//rotate([90,0,0])
    translate([-10.5, 0, 0])
    union() {
        thin_mounts();
        thick_mount();
    }

}

mount_GoPro_build();

//rack(widthMount);
