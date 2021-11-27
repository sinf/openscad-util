
function ngon_circumcircle_radius(Ri,theta) = Ri / cos(theta/2);

/* produce an octagon that contains circle of specified radius
 * useful for printing artefact-free holes at any orientation */
module circle8(r, d=-1) {
	let(r_=d<0 ? r : d/2)
	rotate(360/8/2, [0,0,1])
	circle(r=ngon_circumcircle_radius(r_, 360/8), $fn=8);
}

module cylinder8(r,h,d=-1,center=false) {
	let(r_=d<0 ? r : d/2)
	rotate(360/8/2, [0,0,1])
	cylinder(r=ngon_circumcircle_radius(r_, 360/8), h=h, center=center, $fn=8);
}

