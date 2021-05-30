use <util.scad>

nema17_hole_r=2.5/2 + 0.3;
nema17_hole_dist=31;
nema17_side_len=42.3;

module nema17_holes()
{
	s=nema17_hole_dist;
	for(i=[-1,1]) for(j=[-1,1])
	translate([i,j]/2*s)
	circle(r=nema17_hole_r);
}

module nema17_outline()
{
	r=(nema17_side_len-nema17_hole_dist)/2;
	tol=0.4;
	chamfer_convex(sqrt(2)*r)
	square(nema17_side_len + 2*tol, center=true);
}

module nema17_x_support_plate(r=1)
{
	s=nema17_hole_dist;
	union()
	for(i=[-1,1])
	for(j=[-1,1])
	hull() {
		circle(r=nema17_hole_r + r);
		translate([i,j]/2*s) circle(r=nema17_hole_r + r);
	}
}

