
module line(p0, p1, d)
{
	hull() {
		translate(p0) circle(d=d);
		translate(p1) circle(d=d);
	}
}

/* a0,a1,b0,b1: 2D points
 * ad, bd: diameters of holes
 * beam: width of the bar connecting these 2 holes */
module elongated_hole_arm(a0, a1, ad, b0, b1, bd, tol, wall, beam)
{
	difference() {
		let(xd = 2*(tol + wall))
		union() {
			line(a0, a1, ad + xd);
			line(b0, b1, bd + xd);
			line((a0+a1)/2, (b0+b1)/2, beam);
			children();
		}
		union() {
			line(a0, a1, ad + 2*tol);
			line(b0, b1, bd + 2*tol);
		}
	}
}

