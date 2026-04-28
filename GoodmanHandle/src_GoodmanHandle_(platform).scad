// Крепление для подводного фонаря, фиксирующее его на тыльной стороне кисти
// Goodman handle (platform)
// vеrsion 0.1.0
//
// OpenSCAD model
// =============================================
use <../NevaDiversLogo/logoND_small.scad>

// === Глобальные ПАРАМЕТРЫ === TODO: вынести в отдельный фаил!!!
lengthGrip          = 110;         // ширина хвата ручки (ширина внутренней части), мм
widthHandle         = 20;          // ширина площадки, мм
thickness           = 5;           // толщина площадки, мм

cutoutRadius        = 2.0;         // радиус круглых вырезов (слота), мм
cutoutSlotLength    = 30;          // длина прорези (слота), мм

edgeRadius          = thickness*0.49;           // скругление внешних фасок

// Переключатель качества для ускорения предпросмотра
preview_mode = false;  // true = быстрый рендер ($fn=8), false = нормальное качество ($fn=30)

// --- локальные параметры ---
widthDetail     = widthHandle;
lengthDetail    = lengthGrip;
widthRails      = (widthHandle/2 - edgeRadius - cutoutRadius)/3;



module flat_body() {
    polygon(points = [
        [0,                             0],
        [0,                             edgeRadius + widthRails],
        [widthRails,                    edgeRadius + widthRails],
        [widthRails,                    edgeRadius + widthRails*2],
        [0,                             edgeRadius + widthRails*2],
        [0,                             widthDetail - (edgeRadius+widthRails*2)],
        [widthRails,                    widthDetail - (edgeRadius+widthRails*2)],
        [widthRails,                    widthDetail - (edgeRadius+widthRails)],
        [0,                             widthDetail - (edgeRadius+widthRails)],
        [0,                             widthDetail],
        [lengthDetail,                  widthDetail],
        [lengthDetail,                  widthDetail - (edgeRadius+widthRails)],
        [lengthDetail - widthRails,     widthDetail - (edgeRadius+widthRails)],
        [lengthDetail - widthRails,     widthDetail - (edgeRadius+widthRails*2)],
        [lengthDetail,                  widthDetail - (edgeRadius+widthRails*2)],
        [lengthDetail,                  edgeRadius+widthRails*2],
        [lengthDetail - widthRails,     edgeRadius+widthRails*2],
        [lengthDetail - widthRails,     edgeRadius+widthRails],
        [lengthDetail,                  edgeRadius + widthRails],
        [lengthDetail, 0]
    ]);
}

module body_3d_rounded() {
    sphere_fn = preview_mode ? 8 : 30;  // оптимизация для скорости (бук старенький)
    
    if (edgeRadius > 0) {
        minkowski() {
            // Компенсация «раздувания» от minkowski:
            // - 2D-контур уменьшаем на edgeRadius
            // - высота выдавливания уменьшается на 2*edgeRadius
            linear_extrude(height = thickness - 2*edgeRadius, convexity = 3)
                offset(r = -edgeRadius) flat_body();
            
            // Сфера скругляет рёбра во всех плоскостях (XY, YZ, XZ)
            sphere(r = edgeRadius, $fn = sphere_fn);
        }
    } else {
        // Без скругления — обычное выдавливание
        linear_extrude(height = widthHandle, convexity = 3)
            flat_body();
    }
}
// --- СБОРКА ---
module build_detail () {
    union() {
        body_3d_rounded();
    }
}

build_detail();