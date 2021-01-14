

function box_edge_point(p) = (
	(p == "bl" || p == false) ? [0,0]
	: (p == "c" || p == true) ? [.5,.5]
	: p == "br" ? [1,0]
	: p == "tl" ? [0,1]
	: p == "tr" ? [1,1]
	: p == "l" ? [0,.5]
	: p == "r" ? [1,.5]
	: p == "b" ? [.5,0]
	: p == "t" ? [.5,1]
	: assert(false) [0,0]
);

function at_box_edge(edge="b", relpos=0.5, z=undef, dim=[0,0], inset=0, center=false) = 
let(
	d=dim + (is_undef($dim) ? [0,0] : $dim),
	ins=inset + (is_undef($inset) ? 0 : $inset),
	c=center || (!is_undef($center) && $center==true)
)
let(
	x0=ins,
	y0=ins,
	x1=d[0]-ins,
	y1=d[1]-ins,
	x=x0 + relpos*(x1-x0),
	y=y0 + relpos*(y1-y0)
)
concat(
	((c ? -d/2 : [0,0]) +
	(
		edge == "b" ? [x,y0] :
		edge == "t" ? [x,y1] :
		edge == "l" ? [x0,y] :
		edge == "r" ? [x1,y] :
		edge == "dp" ? [x,y] : // positive diagonal
		edge == "dn" ? [x,y1-y] : // negative diagonal
		[0,0]
	)),
	(is_undef(z) ? [] : [z])
);

function corner_points_(w,h,inset=0) = [
	[inset,inset],
	[w-inset,inset],
	[w-inset,h-inset],
	[inset,h-inset]
];

function corner_points_c(w,h,inset=0) = [
	[-w/2+inset,-h/2+inset],
	[w/2-inset,-h/2+inset],
	[w/2-inset,h/2-inset],
	[-w/2+inset,h/2-inset]
];

function corner_points(w,h,inset=0,center=false) =
	center ? corner_points_c(w,h,inset)
	: corner_points_(w,h,inset);

function rect_relpos(w,h,x,y,z,anchor="center") =
	anchor == "bl" ? [x,y,z] :
	anchor == "br" ? [w-x,y,z] :
	anchor == "tl" ? [x,h-y,z] :
	anchor == "tr" ? [w-x,h-y,z] : [w/2+x,h/2+y,z]
;

function rect_relpos_list(w,h,points,center=false) = [
	for(P=[
	for(p=points)
	rect_relpos(w,h, p[0], p[1], p[2], p[3])
	]) [P[0]-(center?w/2:0), P[1]-(center?h/2:0), P[2]]
];

function spaced_coords(spacing, count, x0=0, center=true) =
count <= 1 ? [0] :
[for(i=[0:count-1]) x0+i*spacing+(center?-(count-1)*spacing/2:0)];
/* spaced_coords() testcase
union() {
	n=7;
	s=10;
	c=false;
	x0=0;

	color("blue")
	translate([c ? -n*s/2+x0 : x0, 0])
	cube([n*s,0.4,0.1]);

	for(x=spaced_coords(spacing=s,count=n,center=c,x0=x0))
	translate([x,0])
	color("red")
	cylinder(r=0.2,h=1);
}
*/

function box_perimeter_points_(w,h,nx,ny,Nx,Ny,sx,sy) = concat(
	ny > 0 ? [
	for(c=spaced_coords(h/Ny,ny)) [0,h/2+c*sy],//right
	for(c=spaced_coords(h/Ny,ny)) [w,h/2+c*sy] //left
	] : [],
	nx > 0 ? [
	for(c=spaced_coords(w/Nx,nx)) [w/2+c*sx,0], // bottom
	for(c=spaced_coords(w/Nx,nx)) [w/2+c*sx,h] // top
	] : []
);

// useful with box_perimeter_points
function sig(x) = x < 0 ? -1 : 1;
function offset_coord(x,offs) = sig(x)*max([0, abs(x) + offs]);
function offset_points(points,r) = [
	for(p=points) [offset_coord(p[0],r), offset_coord(p[1],r)]
];
function offset_points_v(points,v) = [
	for(p=points) [offset_coord(p[0],v[0]), offset_coord(p[1],v[1])]
];

/*
get equally spaced coordinates along all four edges of a box
(count) specifies number of points lying on edges
if corners==true: additional 4 points are created in the corners
scl with values <1 is used to clump the points near centres of edges
*/
function box_perimeter_points(dim, count, center=true, corners=false, scl=[1,1]) =
	/*
	let(count_x = is_undef(count[0]) ? count : count[0])
	let(count_y = is_undef(count[1]) ? count : count[1])
	assert(type(dim)=="vector")
	assert(type(count_x)=="float")
	assert(type(count_y)=="float")
	*/
	assert(len(dim)==2)
	assert(len(count)==2)
	let(count_x=count[0])
	let(count_y=count[1])
	concat(
	[
		for (p=box_perimeter_points_(
			dim[0], dim[1],
			count_x, count_y,
			count_x + (corners?1:0), count_y + (corners?1:0),
			scl[0], scl[1]))
		p - (center ? dim/2 : [0,0]),
	],
	corners ? corner_points(dim[0],dim[1],center=center) : []);

module for_endpoints_x(length,inset=0,center=false) {
	for(x=[inset,length-inset])
	translate([(center ? -length/2 : 0) + x, 0])
	children();
}

module brect_ext(dim,b0,b1,b2,b3,org="bl")
{
	p0 = [0,0];
	p1 = [dim[0],0];
	p2 = [dim[0],dim[1]];
	p3 = [0,dim[1]];
	tr_aligned(org,-dim)
	polygon(points=[
		p0 + [0,b0],
		p0 + [b0,0],
		p1 - [b1,0],
		p1 + [0,b1],
		p2 - [0,b2],
		p2 - [b2,0],
		p3 + [b3,0],
		p3 - [0,b3]
	]);
}
module brect(dim,bevel,org="bl")
{
	b=min([dim[0]/2, dim[1]/2, bevel]);
	brect_ext(dim,b,b,b,b,org);
}

