
$fa=5;
$fs=0.5;

smoothing=10;
wall=1;
d1=10;
d2=30;
h1=10;
h2=10;
r1=d1/2;
r2=d2/2;
h3=r2-r1;
assert(d1 <= d2);

main();

module main() {
	funnel_wall(r1=r1, r2=r2, h1=h1, h2=h2, h3=h3, w=wall, o2=smoothing);
}

module funnel(r1,r2,h1,h2,h3,o=0,o2=0) {
	/* o: extra wall thickness
	 * o2: smoothing
	*/
	rotate_extrude(angle=360, convexity=4)
	let(dz=o*(1-1/sqrt(2)))
	let(top=h1+h2+h3+o2+100)
	let(x0=-100-o2)
	let(x1=max(r1,r2)+100+o+o2)
	let(y0=-100-o2)
	intersection() {
		offset(r=o2) offset(delta=-o2) // round convex edge
		offset(r=-o2) offset(delta=o2) // round concave edge
		polygon(points=[
			[x0,y0],
			[r1+o, y0],
			[r1+o, h1-dz],
			[r2+o, h1+h3-dz],
			[r2+o, top],
			[x0, top]]);
		square([x1,h1+h3+h2]);
	}
}

module funnel_wall(r1,r2,h1,h2,h3,w,o2) {
	difference(convexity=8) {
		funnel(r1,r2,h1,h2,h3,w,o2=o2);
		translate([0,0,-50])
		funnel(r1,r2,h1+50,h2+50,h3,0,o2=o2);
	}
}

