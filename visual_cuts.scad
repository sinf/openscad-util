
use <util.scad>

/* at top of the main file, put something like
/* [visual cuts] * /
cut_x_enable=false;
cut_y_enable=false;
cut_z_enable=false;
cut_x_side=true;
cut_y_side=true;
cut_z_side=true;
cut_x_coord=50; // [0:100]
cut_y_coord=50; // [0:100]
cut_z_coord=50; // [0:100]
*/
module visual_cuts(s=[3e2,3e2,3e2], l=[3e2,3e2,3e2]) {
	if ($preview) {
		cutout_b("x",cut_x_coord,cut_x_enable,!cut_x_side?1:-1,$cutout_s=s[0],$cutout_l=l[0])
		cutout_b("y",cut_y_coord,cut_y_enable,!cut_y_side?1:-1,$cutout_s=s[1],$cutout_l=l[1])
		cutout_b("z",cut_z_coord,cut_z_enable,!cut_z_side?1:-1,$cutout_s=s[2],$cutout_l=l[2])
		children();
	} else {
		children();
	}
}


