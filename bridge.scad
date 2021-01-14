
/*       l
   _____________
  /             \
 /               \  h
/        .org     \
*/
module bridge(l, h, a=45, w=10, int=0, ext=1)
{
	x=int + ext;
	rotate(90,[1,0,0])
	lin_extr(w, center=true)
	intersection() {
		outline(-int, ext, true)
		translate([0,-x])
		isosceles(w=l,h=h + x,angle=a,centerX=true,vflip=true);

		translate([-500,0])
		square([1000, h+x]);
	}
}


/*
|   |
|_._|
vflip: put the bar on top instead of bottom
*/
module u_shape(w, h, r_in, r_out, vflip=false)
{
	translate([0, vflip ? h : 0])
	mirror(vflip ? [0,1,0] : [0,0,0])
	difference() {
		translate([-w/2 - r_out, -r_out])
		square([w + 2*r_out, h + r_out]);

		translate([-w/2 + r_in, r_in])
		square([w - 2*r_in, h + r_out]);
	}
}


