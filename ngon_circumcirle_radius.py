
from math import *
import argparse

def ngon_circumcircle_radius(Ri,theta):
    return Ri / cos(theta/2)

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("r", type=float, help="circle radius")
    ap.add_argument("n", type=int, help="n-gon vertex count")
    args=ap.parse_args()

    r=args.r
    n=args.n
    theta=2*pi/n
    c=ngon_circumcircle_radius(r, theta)
    print("radius of circle =", args.r)
    print("theta =", degrees(theta), "deg")
    print("ngon circumcircle radius=", c)

if __name__ == "__main__":
    main()


