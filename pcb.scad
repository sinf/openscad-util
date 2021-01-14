
use <util.scad>
use <snapfit.scad>

module pcb_stand(h=10,w=4,P=0.8,b=1,t=0.4,z=1) {
	/* t is tolerance
       : x=0
       :
     _ : ...y=h+z
    | |:
    | |_ ...y=h
    |   |
    |   |
    |___|...y=0
    :   :x=P
    :x=-b
	*/
	difference() {
		translate([-w/2,-b,0])
		cube([w,b+P,h+z]);

		translate([-w/2-1,-t,h-t])
		cube([w+2,t+P+1,t+z+1]);
	}
}

module two_sided_pcb_holder(w, h, thickness,
	stand_h=10,
	stand_x=8,
	stand_w=4,
	snap_w=4,
	ghost=false)
{
	mirror_dup("xy", org=[w/2,h/2,0])
	translate([w/2 + stand_x,0])
	pcb_stand(w=stand_w, h=stand_h);

	pcb_mount_rect(w,h,
		z_offset=stand_h,
		board_thickness=thickness,
		snap_w=snap_w,
		screw_d=3.3,
		snaps_nx=1,
		snaps_ny=0,
		sticks=false);

	if (ghost) {
		#
		translate([w/2, h/2, stand_h])
		cube_centerXY([w,h,thickness]);
	}
}

