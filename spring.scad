

/*
       _      
      / \ 
-\   |   \-
 |   |  
  \_/   

p: number of curves, must be >=1
dy: length of straight segment (or amplitude of above graph). >=0
w: thickness of the line in XY plane, must be >0
h: thickness of the line along Z axis, must be >0
r: radius of the curves, must be >0
dx: if negative, then length of the spring will be (2*r+4*p*r)
	if positive, then r will be adjusted to make spring length be dx
*/
module serpentine_spring(p=5,dy=5,w=1,h=1,r=3,dx=-1)
{
	r=dx<0 ? r : dx/(4*p+2);
	dy=dy+4*r;
	for(curve=[[0,-r,0,90],
		for(i=[1:p]) [i*4*r-2*r,-dy/2+r,180,360],
		for(i=[1:p]) [i*4*r,dy/2-r,0,180],
		[p*4*r+2*r,r,180,270]])
	{
		x=curve[0];
		y=curve[1];
		a0=curve[2];
		a1=curve[3];
		translate([x,y])
		rotate(a0,[0,0,1])
		rotate_extrude(angle=a1-a0)
		translate([r,0])
		square([w,h],center=true);
	}
	for(i=[0:2*p-2]) {
		translate([3*r+2*i*r-w/2,-dy/2+r,-h/2])
		cube([w,dy-2*r,h]);
	}
	translate([r-w/2,-dy/2+r,-h/2])
	cube([w,dy/2-2*r,h]);
	translate([p*4*r+r-w/2,r,-h/2])
	cube([w,dy/2-2*r,h]);
}
/* test code
union() {
	p=4;
	w=0.5;
	h=1;
	r=1;
	dx=8;
	dy=0;
	serpentine_spring(p=p, dy=dy, w=w, h=h, r=r, dx=dx, $fs=0.3);

	translate([0,0,-1])
	color("red", 0.5)
	cube([2*r + 4*p*r,1,1]);

	translate([0,2,-1])
	color("green", 0.5)
	cube([dx,1,1]);
}
*/

