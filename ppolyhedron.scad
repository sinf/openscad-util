
function _poly_to_tris(p) = [
	for(i=[1:len(p)-2])
	[p[0], p[i], p[i+1]]
];

module _triangle(a, b, c, z0, z1, stick) {
	let(N=cross(b-a, c-a))
	let(n=N/norm(N))
	let(n0=n*z0)
	let(n1=n*z1) {
		color("cyan")
		polyhedron(
			points=[a+n0, b+n0, c+n0, a+n1, b+n1, c+n1],
			faces=[[0,1,2], [0,1,4,3], [1,2,5,4], [2,5,3,0], [3,4,5]]
		);

		color("blue")
		let(p0=(a+b+c)/3)
		let(p1=p0 - n*stick)
		let(r=abs(z1-z0))
		hull() {
			translate(p0) sphere(r=r);
			translate(p1) sphere(r=r);
		}
	}
}

/* debug visuals (incase polyhedron doesnt show up due to degenerate geometry) */
module ppolyhedron(points, faces, convexity=10) {
	if ($preview) {
		for(p=points)
		translate(p)
		color("red")
		sphere(d=0.1, $fn=10);

		for(f0=faces)
		assert(len(f0) >= 3, str("poly_to_tris() input length < 3: ", f0))
		let(t=_poly_to_tris(f0))
		for(f=t)
		assert(len(f) == 3, str("poly_to_tris() failed: ", t))
		let(a=points[f[0]])
		let(b=points[f[1]])
		let(c=points[f[2]])
		assert(!is_undef(a), str("vertex ", f[0], " is undef in polygon ", f0, " len(points)=", len(points)))
		assert(!is_undef(b), str("vertex ", f[1], " is undef in polygon ", f0, " len(points)=", len(points)))
		assert(!is_undef(c), str("vertex ", f[2], " is undef in polygon ", f0, " len(points)=", len(points)))
		let(th=0.01)
		_triangle(a, b, c, -th, th, 0.5);
	} else {
		polyhedron(points=points, faces=faces, convexity=convexity);
	}
}

