
/*
range(): try to emulate python's range
Examples:
	range(1) => [0]
	range(5) => [0,1,2,3,4]
	range(1,5) => [1,2,3,4]
	range(1,5,2) => [1,3]

	range(5,1) => []
	range(5,1,-1) => [5,4,3,2]
*/
function range(a, b, step=1) =
	abs(step) < 1 ? [] :
	is_undef(b) ? range(0, a, step) :
	let(loops=(b-a)/step)
	loops < 1 ? [] :
	loops < 2 ? [a] :
	[for(i=[0:floor(loops)-1]) a + i*step];

function is_odd(x) = x%2 > 0;
function is_even(x) = !is_odd(x);
function even_odd(x,y) = x + (abs((x%2+y%2)-1) > 0.01 ? 1 : 0);

function vabs(vect) = [for(x=vect) abs(x)];

function hadamard(a,b) = [for(i=[0:min(len(a),len(b))-1]) a[i]*b[i]];

// openshit's search() is such bullshit I need my own string_in_list()
function any(v, b=true, i=0) = i<len(v) ? (v[i] ? b : any(v,b,i+1)) : !b;
function string_in_list(s,l) = any([for(s2=l) s==s2]);

// interleave two vectors of equal length
function zip(a,b) =
let(n=min(len(a),len(b))-1)
flatten([for(i=[0:n]) [a[i],b[i]]]);
/*
echo(zip([1,2,3],["a","b","c"]));
==>ECHO: [1, "a", 2, "b", 3, "c"]
*/

// split a vector into shorter vectors of length n
function vchunk(a,n) = [
	for(j=[0:n:len(a)-1])
	[for(i=[0:n-1]) a[j+i]]
];

// centered square
module csquare(dim) { square(dim, center=true); }

// makes the specified org point be the new (0,0)
module tr_aligned(org,SZ=[1,1],sz=[0,0]) {
	p=box_edge_point(org);
	translate(hadamard(p,SZ-sz))
	children();
}

// input : nested list
// output : list with the outer level nesting removed
function flatten(l) = [ for (a = l) for (b = a) b ] ;

function select(vector,indices) = [ for (index = indices) vector[index] ];
function reverse(x) = [ for(i=[1:len(x)]) x[len(x)-i] ];


function vslice(vector, start_incl, end_excl) =
	select(vector, range(start_incl, end_excl));

function drop_first(vector, n=1) =
	assert(n >= 0)
	assert(n < len(vector))
	[for(i=[n:len(vector)-1]) vector[i]];

function recursive_sum(vector, func) =
	assert(len(vector) >= 2)
	func(vector[0], recursive_sum(drop_first(vector), func));

module make_shell_outward(r1, r2)
{
	difference() {
		// truncated_teardrop(r) also good
		minkowski() { children(); sims(r2); }
		minkowski() { children(); sims(r1); }
	}
}

// 2D fillets & chamfers
// if the object vanishes then r is too large
module fillet_concave(r,x=0) { offset(r=-r) offset(delta=r+x) children(); }
module fillet_convex(r,x=0) { offset(r=r) offset(delta=x-r) children(); }
module fillet(r,x=0) { fillet_concave(r) fillet_convex(r,x) children(); }
module chamfer_concave(r,x=0) { offset(delta=-r, chamfer=true) offset(delta=r+x) children(); }
module chamfer(r,x=0) { chamfer_concave(r) chamfer_convex(r,x) children(); }
module chamfer_convex(r,x=0) {
	offset(delta=r, chamfer=true)
	offset(delta=x-r)
	children();
}

/*
// test case
!union() {
	fillet(1.5)
	polygon([[0,0],[10,0],[10,4],[4,4],[4,10],[0,10]]);
}
*/

module lin_extr(h,convexity=2, center=false, twist=0) {
	if ($children > 0)
	// extrudes use the 1st argument as filename by default :O
	linear_extrude(height=h, convexity=convexity, center=center, twist=twist)
	children();
}
module rot_extr(a,convexity=4, center=false) {
	if ($children > 0)
	rotate(center ? -a/2 : 0, [0,0,1])
	rotate_extrude(angle=a, convexity=convexity)
	children();
}

module lin_array(count, delta) {
	for(i=[0:count-0.5])
	translate(i*delta)
	children();
}

module rot_array(count, angle, axis) {
	for(i=[0:count-0.5])
	rotate(i*angle, axis)
	children();
}

module hull_through_points(points) {
	if (len(points) >= 2)
	union() {
		for(i=[1:len(points)-1]) {
			hull() {
				translate(points[i-1]) children();
				translate(points[i]) children();
			}
		}
	}
}

module sine_extrude(height=1, wavelength=1, amplitude=1, center=false)
{
	dz = $fn>0 ? height/$fn : 0.2;
	z_steps = height / dz;
	dt = dz / wavelength * 360;
	dx = amplitude / dz;
	translate(center ? [0,0,-height/2] : [0,0,0])
	hull_through_points(points=[
		for(i=[0:z_steps]) [
			amplitude*sin(i*dt),
			0,
			i*dz
		]
	])
	children();
}

function circle_segment_angle(r) =
	str($fn)!="undef" ? $fn :
	str($fa)!="undef" && str($fs)!="undef" ? min($fa, 360/(r*PI/$fs)) :
	str($fa)!="undef" ? $fa :
	str($fs)!="undef" ? r*PI/$fs :
	(360/5);
function circle_segment_count(r) = max(5, 360/circle_segment_angle(r));

module line(a,b,r=1) {
	hull() {
		translate(a) circle(r=r);
		translate(b) circle(r=r);
	}
}

function array3_points_s(step_size=[1,1,1],steps=[2,2,2],off=[0,0,0]) = [
	for(i=range(steps[0]))
	for(j=range(steps[1]))
	for(k=range(steps[2]))
	hadamard([i,j,k],step_size) + off
];

function array3_points(dim=[1,1,1],steps=[2,2,2],center=false) =
	let(c=center ? [for(i=[0,1,2]) steps[i]<2 ? 0 : -dim[i]/2] : [0,0,0])
	let(s=[for(i=[0,1,2]) dim[i]/(steps[i]-1)])
	array3_points_s(step_size=s, steps=steps, off=c);

module array3_s(step_size=[1,1,1],steps=[2,2,2],off=[0,0,0]) {
	for(p=array3_points_s(step_size, steps, off))
	translate(p)
	children();
}
module array3(dim=[1,1,1],steps=[2,2,2],center=false) {
	for(p=array3_points(dim, steps, center))
	translate(p)
	children();
}

module rcube(dim,r=1,center=false,chamfer=true)
{
	if (r<=0) {
		cube(dim, center=center);
	} else {
		hull()
		for_cube_corners(dim,-[r,r,r],center) {
			if (chamfer) sims(r); else sphere(r=r);
		}
	}
}

module hollow_cube(dim,center=false, int=1, ext=0, r=0, chamfer=true)
{
	let(cf=chamfer)
	translate(center ? [0,0,0] : dim/2)
	difference() {
		rcube(dim + [ext,ext,ext], r, true, cf);
		rcube(dim - [int,int,int], r, true, cf);
	}
}

module mirror_about(a,org=[0,0,0],dup=false) {
	if (dup) children();
	translate(org)
	mirror(a)
	translate([-org[0],-org[1],-org[2]])
	children();
}

module mirror_dup(axes,org=[0,0,0]) {
	x=len(search("x",axes))>0;
	y=len(search("y",axes))>0;
	z=len(search("z",axes))>0;
	if (x) mirror_about([1,0,0],org) children();
	if (y) mirror_about([0,1,0],org) children();
	if (z) mirror_about([0,0,1],org) children();
	if (x && y) mirror_about([1,0,0],org) mirror_about([0,1,0],org) children();
	if (x && z) mirror_about([1,0,0],org) mirror_about([0,0,1],org) children();
	if (y && z) mirror_about([0,1,0],org) mirror_about([0,0,1],org) children();
	if (x && y && z) {
		mirror_about([1,0,0],org)
		mirror_about([0,1,0],org)
		mirror_about([0,0,1],org)
		children();
	}
	children();
}

// centered cube except for one axis
module xcube(s) { translate([0,s.y,s.z]/-2) cube(s); }
module ycube(s) { translate([s.x,0,s.z]/-2) cube(s); }
module zcube(s) { translate([s.x,s.y,0]/-2) cube(s); }

function normalized(v) = v/norm(v);

function transpose_2(m) = [[m[0][0],m[1][0]],[m[0][1],m[1][1]]];
function transpose_3(m) = [[m[0][0],m[1][0],m[2][0]],[m[0][1],m[1][1],m[2][1]],[m[0][2],m[1][2],m[2][2]]];
function transpose_4(m) = [[m[0][0],m[1][0],m[2][0],m[3][0]],
                           [m[0][1],m[1][1],m[2][1],m[3][1]],
                           [m[0][2],m[1][2],m[2][2],m[3][2]],
                           [m[0][3],m[1][3],m[2][3],m[3][3]]]; 

function m_orient(tr=[0,0,0], n=[0,0,1]) =
	(abs(n.x)+abs(n.y)) < 1e-5 ?
		(n.z < 0
		? [[1,0,0,tr.x],[0,-1,0,tr.y],[0,0,-1,tr.z],[0,0,0,1]]
		: [[1,0,0,tr.x],[0,1,0,tr.y],[0,0,1,tr.z],[0,0,0,1]])
	:
	/*
	 * a: always on xy plane
	 * a x n: up
	 * n x (a x n): right
	 */
	let(a=cross(n, [0,0,1]))
	let(v=normalized(cross(a, n)))
	let(u=-normalized(cross(n, v)))
	let(m=normalized(n))
	transpose_4([
		[u.x, u.y, u.z, 1],
		[v.x, v.y, v.z, 1],
		[m.x, m.y, m.z, 1],
		[tr.x, tr.y, tr.z, 1]]);

module rotate_to(n=[0,0,1]) {
	multmatrix(m_orient(n=n))
	children();
}

function parse_vector(v) =
	str(v)!=v ? v :
		(v=="x" ? [1,0,0]
		: (v=="y" ? [0,1,0]
		: (v=="z" ? [0,0,1]
		: undef)));

module cutout(n=[0,0,1], p=[0,0,0], cond=true) {
	s=is_undef($cutout_s) ? 5e2 : $cutout_s;
	l=is_undef($cutout_l) ? 5e2 : $cutout_l;
	if (cond) {
		difference() {
			union()
			children();

			color("pink")
			multmatrix(m_orient(p,n))
			translate([-s/2,-s/2,0])
			cube([s,s,l]);
		}
	} else {
		children();
	}
}

function basis(i) = [
	(i==0 || str(i)=="x") ? 1 : 0,
	(i==1 || str(i)=="y") ? 1 : 0,
	(i==2 || str(i)=="z") ? 1 : 0
];

module cutout_b(axis="x", coord=0, cond=true, t=1) {
	let(b=basis(axis))
	cutout(b*t, b*coord, cond)
	children();
}

// produces no geometry if r is much greater than dim
// if r exceeds dim a little then the sides aren't straight anymore
module rsquare(dim, r=1, center=false) {
	hull()
	translate(center?[0,0]:dim/2)
	for(p=[[-1,-1],[-1,1],[1,-1],[1,1]]) {
		c=[p[0]/2*dim[0], p[1]/2*dim[1]];
		intersection() {
			translate(c-r*p) {
				if (!is_undef($rsq_sharp) && $rsq_sharp) {
					rotate(45,[0,0,1]) square(2*r, center=true);
				} else {
					circle(r=r);
				}
			}

			translate(c/2)
			square(dim/2, center=true);
		}
	}
}

function points_equal(a,b,epsilon=0.001) =
	abs(a[0]-b[0])<epsilon &&
	abs(a[1]-b[1])<epsilon &&
	abs(a[2]-b[2])<epsilon;

module d_offset(delta=0) {
	if (abs(delta) <= 1e-5) {
		// openscad offset() breaks if delta=0
		children();
	} else {
		offset(delta=delta)
		children();
	}
}
/* outline test case
! union() {
	s=5;
	d=1;
	translate([0,0,.1])
	color("red",.5) lin_extr(10) outline_inner(d,-.01,true) square(s);
	color("green",.5) lin_extr(8) square(s);
	translate([0,0,-0.1])
	color("blue",.5) lin_extr(6) outline_mid(d,0,true) square(s);
	color("yellow",.5) lin_extr(4) outline_outer(d,0,true) square(s);
}
*/

module outline(r_in,r_ext,delta=false) {
	if (delta) {
		difference() {
			d_offset(delta=r_ext) children();
			d_offset(delta=r_in) children();
		}
	} else {
		difference() {
			offset(r=r_ext) children();
			offset(r=r_in) children();
		}
	}
}

module outline_inner(width,off=0,delta=false) {
	outline(off-width, off, delta) children();
}
module outline_outer(width,off=0,delta=false) {
	outline(off, off+width, delta) children();
}
module outline_mid(width,off=0,delta=false) {
	outline(off-width/2, off+width/2, delta) children();
}

module frustum(dim1, dim2, h) {
	polyhedron(points=[
		[-dim1[0]/2, -dim1[1]/2, 0],
		[-dim1[0]/2, dim1[1]/2, 0],
		[dim1[0]/2, -dim1[1]/2, 0],
		[dim1[0]/2, dim1[1]/2, 0],
		[-dim2[0]/2, -dim2[1]/2, h],
		[-dim2[0]/2, dim2[1]/2, h],
		[dim2[0]/2, -dim2[1]/2, h],
		[dim2[0]/2, dim2[1]/2, h]],
		faces=[
		[1,0,2,3],
		[7,6,4,5],
		[5,4,0,1],
		[2,0,4,6],
		[3,2,6,7],
		[7,5,1,3]],
		convexity=2);
}

module serial_hull() {
	union() {
		for(i=[1:$children-1]) {
			hull() {
				children(i-1);
				children(i);
			}
		}
	}
}

module hull_to_first() {
	union() {
		for(i=[1:$children-1]) {
			hull() {
				children(0);
				children(i);
			}
		}
	}
}

module shear_x(p) {
  multmatrix([
    [1,0,0,0],
    [p.y/p.x,1,0,0],
    [p.z/p.x,0,1,0]
  ]) children();
}

module shear_y(p) {
  multmatrix([
    [1,p.x/p.y,0,0],
    [0,1,0,0],
    [0,p.z/p.y,1,0]
  ]) children();
}

// shear such that point will translate by [p.x,p.y] as z-axis is traversed by p.z units
module shear_z(p) {
  multmatrix([
    [1,0,p.x/p.z,0],
    [0,1,p.y/p.z,0],
    [0,0,1,0]
  ]) children();
}


// make a + shape
// s: length of the four legs
// w: width of a legs
module plus(s=0.2,w=1) {
	union() {
		square([s,w],center=true);
		square([w,s],center=true);
	}
}

module sweep_to(v) {
	hull() {
		children();
		translate(v) children();
	}
}

/* _|_ */
module T_profile(w, h, thickness=1) {
	t=thickness/2;
	union() {
		translate([-w/2,0]) square([w, thickness]);
		translate([-t,t]) square([thickness, h-thickness]);
	}
}

module cintersection(enable) {
	if (enable && $children > 1) {
		intersection() {
			children(0);
			for(i=[1:$children-1]) children(i);
		}
	} else {
		children(0);
	}
}

module cminkowski(enable) {
	if (enable) {
		minkowski() {
			children(0);
			children(1);
		}
	} else {
		if ($children > 1) {
			for(i=[2:$children])
			children(i-1);
		} else {
			children();
		}
	}
}

/*
width at y=0 is constant (w)
width at the top is varied according to side angle

if vflip==true, then width at y=h is (constant) w
and width at y=0 is varied according to side angle
*/
module isosceles(w,h,angle,centerX=false,centerY=false,vflip=false) {
	translate([centerX?-w/2:0, centerY?-h/2:0]) {
		if (angle==0) {
			square([w,h]);
		} else {
			x=h*tan(abs(angle))*sign(angle);
			if (vflip)
				polygon([[-x,0], [w+x,0], [w,h], [0,h]]);
			else
				polygon([[0,0], [w,0], [w+x,h], [-x,h]]);
		}
	}
}

module capsule(d=1, r=-1, h=1,center=false)
{
	r_ = r < 0 ? d/2 : r;
	translate([0,0,center ? -h/2 : 0])
	hull() {
		translate([0,0,r_]) sphere(r=r_);
		translate([0,0,h-r_]) sphere(r=r_);
	}
}

module rotate_extrude_2d(angle,steps,axis=[0,0,1])
{
	a=angle/steps;
	union()
	for(i=[0:steps-1]) {
		hull() {
			rotate(a*i, axis) children();
			rotate(a*(i+1), axis) children();
		}
	}
}

module gear_sausage_hole(a=90, R=5, r=1, h=0, steps=-1)
{
	rotate_extrude_2d(angle=a, steps=steps<0?circle_segment_count(R):steps)
	rotate(-a/2,[0,0,1])
	translate([0,R])
	hull() {
		translate([0,-h]) circle(r=r);
		translate([0,h]) circle(r=r);
	}
}

module rotated_copies(count, arc=360, axis=[0,0,1], center=true)
{
	a=arc/(count-1);
	for(i=[0:count-1])
	rotate(i*a - (center?arc/2:0), [0,0,1])
	children();
}

// cube with arguments similar to cylinder()
module dh_cube(d=-1, r=-1, h=0, center=false)
{
	D=d<0 ? r*2 : d;
	R=d<0 ? r : d/2;
	translate([-R,-R,center ? -h/2 : 0])
	cube([D,D,h]);
}

module mirror_hull(axis)
{
	hull() {
		children();
		mirror(axis) children();
	}
}

module washer(d,D,h=-1)
{
	if (h>0) {
		linear_extrude(height=h, convexity=4)
		difference() { circle(d=D); circle(d=d); }
	} else {
		difference() { circle(d=D); circle(d=d); }
	}
}

// beveled washer
module bwasher(d,D,h,bevel=0)
{
	rot_extr(360)
	translate([d,0])
	brect([D-d,h],bevel,"bl");
}

module x_parallel_lines(spacing, count, thickness=1, l=1000)
{
	for(x=spaced_coords(spacing,count,center=true))
	translate([x-thickness/2,-l/2])
	square([thickness, l]);
}

module x_parallel_planes(spacing, count, thickness=1, l=1000, h=1000, centerZ=true)
{
	lin_extr(h, center=centerZ)
	x_parallel_lines(spacing, count, thickness, l);
}

module make_grid(dim, cell=15, thickness=1, center=true)
{
	translate(center ? [0,0] : dim/2) {
		x_parallel_lines(cell, dim[0]/cell, thickness, dim[1]);
		rotate(90,[0,0,1])
		x_parallel_lines(cell, dim[1]/cell, thickness, dim[0]);
	}
}

module sims(r=1, d=-1)
{
	R=d<0 ? r : d;
	hull() {
		cylinder(r1=R, r2=0, h=R, $fn=4);
		mirror([0,0,1]) cylinder(r1=R, r2=0, h=R, $fn=4);
	}
}
/*
!union() {
	sims(10);
	translate([20,0]) sphere(10);
}
*/

module trunc_sphere_45(h)
{
	y=h/2;
	r=y/sin(45);
	s=r+1;
	intersection() {
		sphere(r=r);
		cube([s,s,y]*2, center=true);
	}
}

module teardrop(r=1, a=45)
{
	z=r/cos(a);
	hull() {
		sphere(r=r);
		translate([0,0,-z])
		cylinder(r1=0, r2=1e-5, h=1e-5, $fn=3);
	}
}

module truncated_teardrop(r=1, a=45)
{
	intersection(convexity=2) {
		teardrop(r,a);
		translate([-r-1, -r-1, -r]) cube(2*r+2);
	}
}

module sims(r=1, d=-1)
{
	R=d<0 ? r : d;
	hull($fn=4) {
		cylinder(r1=R, r2=0, h=R);
		mirror([0,0,1]) cylinder(r1=R, r2=0, h=R);
	}
}
/*
!union() {
	sims(10);
	translate([20,0]) sphere(10);
}
*/

function type(x)=
(
   x==undef?undef
//   : floor(x)==x? "int"
   : ( abs(x)+1>abs(x)?"float"
     : str(x)==x?"str"
     : str(x)=="false"||str(x)=="true"?"bool"
     : (x[0]==x[0])&&len(x)!=undef? "vector" // range below doesn't have len
     : let( s=str(x)
         , s2= split(slice(s,1,-1)," : ")
         )
         s[0]=="[" && s[len(s)-1]=="]"
         && all( [ for(x=s2) isint(int(x)) ] )?"range"
        :"unknown"
    )
);

// truncated pyramid
module tpyramid(s1, s2, h, c=-1)
{
	intersection() {
		rotate(45, [0,0,1])
		cylinder(r1=s1*sqrt(2), r2=s2*sqrt(2), h=h);

		let(x=1+max(s1,s2))
		let(z=c<0 ? h+1 : c)
		cube([x,x,2*z], center=true);
	}
}

/* w: width, r: round radius
children: 2d shape */
module rounded_box(w=50,r=1,shrink=0)
{
	x=r+shrink;
	minkowski() {
		translate([0,0,x])
			lin_extr(w-2*x)
			offset(delta=-x)
			children();
		sims(r=r);
	}
}

module z_slice(z)
{
	projection(cut=true)
	translate([0,0,-z])
	children();
}

// need explicit $fn because otherwise hole and sink facets don't match
module screw_hole(z0=0, z1=5, d=3.5, sink=5, $fn=18)
{
	d1=d;
	d2=d1+sink;
	translate([0,0,z0])
	cylinder(d=d1, h=z1-z0);
	if (sink) {
		translate([0,0,z1-sink])
		cylinder(d1=d1, d2=d2, h=sink+.01);
	}
}

// rot2(angle_deg)*[x,y]
function rot2(a) = [[cos(a), -sin(a)], [sin(a), cos(a)]];


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

