
module beveled_solid_box(dim=[100,100,100], r=5, center=false) {
	assert(r > 0, "beveled_solid_box blows up because r <= 0");
	assert(r <= dim[0]/2, "beveled_solid_box blows up because r >= dim[0]/2");
	assert(r <= dim[1]/2, "beveled_solid_box blows up because r >= dim[1]/2");
	assert(r <= dim[2]/2, "beveled_solid_box blows up because r >= dim[2]/2");
	hull()
	for(x=[-1,1]) for(y=[-1,1]) for(z=[-1,1])
	translate(center ? [0,0,0] : dim/2)
	translate([x*dim[0],y*dim[1],z*dim[2]]/2)
	translate([x*-r,y*-r,z*-r])
	hull() {
		cylinder(r1=r, r2=0, h=r, $fn=4);
		mirror([0,0,1]) cylinder(r1=r, r2=0, h=r, $fn=4);
	}
}

module beveled_solid_box2(dim=[100,100,100], r=5, expand=0, center=false) {
	translate(center ? -dim/2 : [0,0,0])
	let(o=[expand, expand, expand])
	translate(-o) beveled_solid_box(dim + 2*o, r=r + expand/sqrt(3));
	// need to adjust r to maintain constant wall thickness in corners
}

module beveled_hollow_box(dim=[100,100,100], r=5, wall_inner=2, wall_outer=0, center=false) {
	difference(convexity=4) {
		beveled_solid_box2(dim, r=r, expand=wall_outer/sqrt(3), center=center);
		beveled_solid_box2(dim, r=r, expand=-wall_inner/sqrt(3), center=center);
	}
}

module beveled_solid_box3(dim=[100,100,100], r=1, expand=0, center=false, fillet=false) {
	translate(center ? -dim/2 : [0,0,0])
	translate([0,0,-expand])
	linear_extrude(height=dim[2]+2*expand, convexity=2) {
		if (fillet) {
			offset(delta=expand)
			fillet_convex(r=r)
			square([dim[0], dim[1]]);
		} else {
			offset(delta=expand)
			chamfer_convex(r=r)
			square([dim[0], dim[1]]);
		}
	}
}

module beveled_hollow_box3(dim=[100,100,100], r=1, wall_inner=2, wall_outer=0, center=false, fillet=false) {
	difference(convexity=4) {
		beveled_solid_box3(dim, r, expand=wall_outer, center=center, fillet=fillet);
		beveled_solid_box3(dim, r, expand=-wall_inner, center=center, fillet=fillet);
	}
}

