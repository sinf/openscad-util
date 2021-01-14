

/* FDM friendly rail profile
slopes are 45 degrees
width of top is implicit
  ____
 /    \  hsa: height of slope above
 |    |  hm:  height of middle section
 \.  ./  hsb: height of slope below
  |  |  hl: height of leg
    wb: width of base
*/
module rail_profile(wb=3,hl=2,hm=0.5,hsa=1,hsb=2)
{
	p0 = [wb/2, 0];
	p1 = p0 + [0, hl];
	p2 = p1 + [hsb,hsb];
	p3 = p2 + [0, hm];
	p4 = p3 + [-hsa,hsa];
	side1=[p0,p1,p2,p3,p4];
	side2=reverse([for(p=side1) [-p[0],p[1]]]);
	polygon(points=concat(side1,side2));
}


