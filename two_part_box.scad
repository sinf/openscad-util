use <util.scad>

module two_part_box(
	z, // middle z of the seam
	top=true, // which part to produce
	tol=0.5, // xy tolerance
	tol_z=0.2, // z tolerance
	h=4, // height of seam
	wall=3, // thickness of box wall
	margin=5 // normally don't care but adjust if cut isn't succesful
	)
{
	if (top) {
		difference() {
			cutout_b("z",z-h/2+tol_z,t=-1)
			children();

			translate([0,0,z-h/2])
			lin_extr(h+tol_z)
			outline(r_in=-wall/2-tol/2, r_ext=margin, delta=true)
			hull()
			z_slice(z)
			children();
		}
	} else {
		difference() {
			cutout_b("z",z+h/2-tol_z,t=1)
			children();

			translate([0,0,z+h/2])
			mirror([0,0,1])
			lin_extr(h+tol_z)
			offset(delta=-wall/2+tol/2)
			hull()
			z_slice(z)
			children();
		}
	}
}

