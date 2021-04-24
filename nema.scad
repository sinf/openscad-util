use <util.scad>

module nema17_holes()
{
	s=31;
	for(i=[-1,1]) for(j=[-1,1])
	translate([i,j]/2*s)
	circle(r=2.5/2 + 0.3);
}

module nema17_outline()
{
	r=(42.3-31)/2*0.8;
	tol=0.4;
	chamfer_convex(sqrt(2)*r)
	square(42.3 + 2*tol, center=true);
}

