
/* extrudes a 2D shape into a square pipe.
 * the shape should lie on X axis and defines profile of the pipe wall
 * shape should be above Y axis (y>0).
 */
/* Example:
profile_square_pipe(s=20, off=1)
union() {
	difference() {
		square([6,1]);
		translate([2,0]) circle(r=0.5);
	}
	square([1,2]);
}
*/
module square_pipe_profile(s, off=0, convexity=2) {
	union() {
		for(i=[0,1,2,3])
		let(x=[1,0,0,1][i]*s)
		let(y=[1,1,0,0][i]*s)
		translate([x,y])
		rotate(i*90-.001,[0,0,1])
		rotate_extrude(angle=90.002, convexity=convexity)
		translate([off,0])
		rotate(90,[0,0,1])
		mirror([0,1,0])
		children();

		translate([s,s]/2)
		for(i=[0,1,2,3])
		rotate(i*90,[0,0,1])
		translate([s/2,-s/2-off])
		rotate(-90,[0,1,0])
		linear_extrude(height=s, convexity=convexity)
		mirror([0,1,0])
		children();
	}
}

