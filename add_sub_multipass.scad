
/* This is how I'm supposed to organize a very complicated object:

add_odd_sub_even() {
	pass(1) {
		stuff();
	}
	pass(2) {
		stuff();
	}
	...
}
*/

module pass(i)
{
	if ($pass == i)
		children();
}

module add_odd_sub_even(n=10)
{
	// ugly workaround to recursion
	difference() {
		union() {
			difference() {
				union() {
					difference() {
						union() {
							difference() {
								if (n>=1) let($pass=1) union() children();
								if (n>=2) let($pass=2) union() children();
							}
							if (n>=3) let($pass=3) children();
						}
						if (n>=4) let($pass=4) union() children();
					}
					if (n>=5) let($pass=5) children();
				}
				if (n>=6) let($pass=6) union() children();
			}
			if (n>=7) let($pass=7) children();
		}
		if (n>=8) let($pass=8) union() children();
	}
}

