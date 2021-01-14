use <util.scad>

module snapfit_cantilever(b,h=1.5,P=2,alpha=60,A=1,F=1,beta=90) {
	/*
                           _F_    _
	\<-A (bevel radius)    /   \    | P
	.\___________b________/%   *\  _/
     __________________________|   <- h
	 /<- thickness=2*h
	/                     __  __
	                      q    u

	.=origin
	*=alpha (forward angle)
	%=beta (return angle)

	A > 0.38 (mm)

	*/

	u = P/tan(alpha);
	q = P/tan(beta);

	polygon(
	[[0,A], [A,0], [b,0],
	[b+q,P], [b+q+F,P], [b+q+F+u,0],
	[b+q+F+u,-h],
	[A,-2*h],
	[0,-2*h-A]]);
}

module snapfit_u_lever_notch(d=6, w=0.8, n0=4, n1=5, nd=0.75, x=1, h=5)
{
	render(convexity=4)
	intersection() {
		translate([d/2-nd, 0])
		polygon(points=[
			[nd+x, n0-nd-x], [0,n0],
			[0,n1], [nd+x, n1+nd+x]
		]);
		if (h > 0) {
			translate([-d/2, abs(n1+n0)/2 - h/2])
			square([d+nd+x+1, h]);
		}
	}
}

module skateboard_ramp(s,x=0) {
	if (s>0)
	difference() {
		square([s+x,s+x]);
		translate([s,s]) circle(r=s+.02);
	}
}

/*   _     <- y=h
    / \
   /   \_ nd: notch depth
  |     ||  w: wall thickness (expands inward)
  |     |/  <- n1 (notch top)
__|..d..|\_ <- n0 (notch bottom)
^   ^     ^ l (lip length)
|   y=0
a (arm length)
origin (0,0) is at where letter d is in above drawing
*/
module snapfit_u_lever(d=6, h=12, w=0.8, n0=4, n1=5, nd=0.75, a=5, l=3, a_bevel=1.5, l_bevel=1, $fs=0.5, $fa=5)
{
	r = d/2;
	render(convexity=10)
	difference() {
		union() {
			outline_inner(w, delta=true)
			difference() {
				union() {
					translate([0, h-r]) circle(d=d);
					translate([-r, 0]) square([d + nd, h-r]);
				}

				// notch
				translate([!is_undef($snap_extra_tol) ? -$snap_extra_tol : 0,0])
				snapfit_u_lever_notch(d=d, w=w, n0=n0, n1=n1, nd=nd, x=10, h=-1);

				// chamfer topright corner where arc and vertical wall meet
				translate([r,h-r])
				let(x=nd+1)
				polygon(points=[[0,0],[x,-x],[x,1],[0,1]]);
			}
			ap = max(0, a);
			lp = max(0, l);
			if (ap+lp > 0) {
				// arm and lip
				translate([-r-ap, 0]) square([ap+d+lp, w]);
			}
			if (a > 0) {
				translate([-r+.01, w-.01])
				mirror([1,0,0])
				skateboard_ramp(min(a,a_bevel));
			}
			if (l > 0) {
				translate([r+nd-.01, w-.01])
				skateboard_ramp(min(l,l_bevel));
			}
		}
		// remove bottom wall
		translate([-r+w, -1]) square([d-2*w+nd, 1.01+w]);
	}
}

module snapfit_u_lever_p(params) {
	snapfit_u_lever(
		params[0], params[1], params[2], params[3],
		params[4], params[5], params[6], params[7],
		params[8], params[9]);
}

/*
! union() {
	chamfer(r=0.38)
	snapfit_u_lever(l=2);
	color("red")
	offset(delta=-0.3)
	snapfit_u_lever_notch(x=5);
}

*/

/*
    _____
   /     \
  /      /
 /     /
/    /
*/
module overhang_hook(w, h, angle=45, $fs=0.5, $fa=5)
{
	fillet_convex(0.75)
	shearAlongY([tan(angle), 1, 0])
	translate([-w,0])
	square([w, h]);
}

module snapfit_circle(r, w=2, num=6) {
	a=w/(2*3.14159265*r)*360;

	for(i=[0:num-1]) {
		rotate(i*360/num-a/2,[0,0,1])
		rotate_extrude(angle=a)
		translate([r,0])
		rotate(90,[0,0,1])
		children();
	}
}

module speaker_mount(
	diameter=57,
	edge_h=0.7,
	edge_r_above=1.75,
	edge_r_below=3,
	stand=8, // makes cantilevers longer to reduce stress
	n=5, // number of cantilevers
	lever_w=3,
	stand_w=6
	)
{
	R=diameter/2;

	// hooks
	snapfit_circle(r=R, w=lever_w, num=n)
	snapfit_cantilever(
		b=edge_h+stand+0.4,
		h=1.2,
		P=edge_r_above,
		alpha=20,
		beta=65,
		A=0.4,
		F=0.4);

	// stand
	snapfit_circle(r=R, w=stand_w, num=n)
	translate([0,0.7])
	square([stand,edge_r_below-0.7]);
}

module slots(w=10, r=1, n=4, spacing=3, extrude=1, center_z=false)
{
	for(i=[1:n]) {
		dx=w/2-r;
		translate([0, -(n-1)*spacing/2-n*r+(i-1)*spacing+2*i*r])
		hull() {
			translate([-dx,0,0]) cylinder(r=r, h=extrude, center=center_z);
			translate([dx,0,0]) cylinder(r=r, h=extrude, center=center_z);
		}
	}
}

module slots_circle(R=10, r=1, spacing=3, extrude=1, center_z=false)
{
	n=2*R/(spacing+2*r);
	for(i=[0:n-1]) {
		t=(i+0.5)/(n-1);
		dx=R*sqrt(1-pow((2*t-1),2));

		translate([0, -(n-1)*spacing/2-n*r+(i-1)*spacing+2*i*r])
		hull() {
			translate([-dx,0,0]) cylinder(r=r, h=extrude, center=center_z);
			translate([dx,0,0]) cylinder(r=r, h=extrude, center=center_z);
		}
	}
}

// one snapfit at the middle of each rectangle's edge
function pcb_snaps_4_sided(w,h) = [
	[w,h/2,90], // right
	[0,h/2,270], // left
	[w/2,0,0], // bottom
	[w/2,h,180] // top
];

// spaced snapfits on all four sides
function pcb_snaps_4_sided_n(w,h,nx,ny,s=[1,1]) = [
	for(c=spaced_coords(h/ny,ny)) [w,h/2+s[1]*c,90],//right
	for(c=spaced_coords(h/ny,ny)) [0,h/2+s[1]*c,270],//left
	for(c=spaced_coords(w/nx,nx)) [w/2+s[0]*c,0,0], // bottom
	for(c=spaced_coords(w/nx,nx)) [w/2+s[0]*c,h,180] // top
];

module translated_and_rotated(xyR) {
	for(p=xyR) {
		translate([p[0],p[1]])
		rotate(p[2],[0,0,1])
		children();
	}
}

module pcb_mount_xx(snap_points, support_sticks, z_offset=15, board_thickness=2, snap_w=2, screw_d=3, xy_tolerance=0.25)
{
	// snap_points: {x,y,angle}, angles 0=bottom, 90=right, 180=top, 270=left
	for(p=snap_points) {
		translate([p[0],p[1]])
		rotate(p[2],[0,0,1])
		rotate(-90,[0,1,0])
		linear_extrude(height=snap_w, center=true)
		translate([0,-xy_tolerance])
		snapfit_cantilever(
			b=z_offset+board_thickness+0.2,
			h=1.2,
			P=1.0,
			alpha=20,
			A=1.0,
			F=0.4,
			beta=60);
	}
	for(p=support_sticks) {
		translate([p[0],p[1]])
		difference() {
			cylinder(r=screw_d/2+1.25, h=z_offset);
			translate([0,0,-1]) cylinder(d=screw_d, h=z_offset+2);
		}
	}
}

module pcb_mount_rect(w,h, z_offset=15, board_thickness=2, snap_w=4, screw_d=3, centerX=false, centerY=false, sticks=true, snaps_nx=1, snaps_ny=1, sticks_inset=5, sticks_coord_scale=[1,1], xy_tolerance=0.25)
{
	translate([centerX?-w/2:0, centerY?-h/2:0])
	pcb_mount_xx(
		pcb_snaps_4_sided_n(w,h,snaps_nx,snaps_ny,sticks_coord_scale),
		sticks ? corner_points(w,h,inset=sticks_inset) : [],
		z_offset,
		board_thickness,
		snap_w,
		screw_d,
		xy_tolerance=xy_tolerance);
}


