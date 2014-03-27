/**
*   Copyright: © 2012-2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>,
*             LeMarwin <lemarwin42@gmail.com>
*/
///Description of <b> Vectors </b> and <b> Quaternions </b>
///<br/> Vectors - just good old 3-d vectors
///<br/> Quaternions are used to describe rotations in 3D space.
///<br/> How to use:
///<br/> 1.Create a Vector
///<br/> 2.Create a Quaternion
///<br/> 3.Call Vector's rotate method with a Quaternion as a parameter (not the only option. see "rotate")
///<br/> 4.?????
///<br/> 5.PROFIT!
module devol.quaternion;

public
{
	import std.math;
}

///Describes a dot, or a direction in 3D space
class Vector
{
private:

///Coordinates of Vector
	double vx,vy,vz;
public:

///Get x
	@property double x()
		{return vx;}
///Get y
	@property double y()
		{return vy;}
///Get z
	@property double z()
		{return vz;}
		
///Set x	
	@property void x(double _x)
		{vx = x;}
///Set y
	@property void y(double _y)
		{vy = y;}
///Set z
	@property void z(double _z)
		{vz = z;}

///Length of the vector
	@property double length()
	{
		return sqrt(vx*vx+vy*vy+vz*vz);
	}
	
///Default constructor
	this()
	{
		vx = 0;
		vy = 0;
		vz = 0;
	}
	
///Construct by coordinates
	this(double _x, double _y, double _z)
	{
		vx = _x;
		vy = _y;
		vz = _z;
	}
	
///Construnct copy
	this(Vector v)
	{
		vx = v.x;
		vy = v.y;
		vz = v.z;
	}
	
///Vector x Vector multiplication
	Vector opBinary(string op)(Vector u) if(op=="*")
	{
		return new Vector(vy*u.z - vz*u.y, vz*u.x - vx*u.z, vx*u.y - vy*u.x);
	};

///Vector-Scalar multiplication
	Vector opBinary(string op)(real c) if(op=="*")
	{
		Vector v = new Vector(c*vx, c*vy, c*vz);
		return v;		
	}

///Scalar-Vector multiplication
	Vector opBinaryRight(string op)(real c) if(op=="*")
	{
		Vector v = new Vector(c*vx, c*vy, c*vz);
		return v;			
	}
	
///Vector summ
	Vector opBinary(string op)(Vector v) if(op == "+")
	{
		Vector t = new Vector(vx + v.x, vy + v.y, vz + v.z);
		return t;
	}

///Vector difference
	Vector opBinary(string op)(Vector v) if(op == "-")
	{
		Vector t = new Vector(vx - v.x, vy - v.y, vz - v.z);
		return t;
	}
	
///Vector*Vector multiplication (returns Scalar)
	double opBinary(string op)(Vector v) if(op == "~")
	{
		return vx*v.x + vy*v.y + vz*v.z;
	}

///Rotate Vector, given the rotation quaternion
	Vector rotate(Quaternion q)
	{
		Vector v = new Vector(this);
		Vector u = q.axis;
		v = v*(q.c*q.c) + 2*(u*v)*q.c*q.s - (v - 2*u*(u~v))*(q.s*q.s);
		this.vx = v.vx;
		this.vy = v.vy;
		this.vz = v.vz;
		return this;
	}

///Rotate Vector, given angle and axis-Vector
	Vector rotate(double angle, Vector axis)
	{
		return this.rotate(new Quaternion(angle, axis));
	}
	
///Rotate Vector, given angle and axis' coordinates
	Vector rotate(double angle, double x, double y, double z)
	{
		return this.rotate(new Quaternion(angle,x,y,z));
	}
}


///Describes rotation in 3D
class Quaternion
{
private:

///Axis of rotation. Length = 1
	Vector u;

///cos(alpha/2)
	double qc;

///sin(alpha/2)
	double qs;
public:

///Default constructor. Angle = 0. Or 2pi*n, as you wish
	this()
	{
		u = new Vector;
		qc = 1;
		qs = 0;
	}
	
///Construct by angle and axis-Vector. Axis-Vector will be normalized, so don't worry about length
	this(double angle, Vector axis)
	{
		qc = cos(angle/2);
		qs = sin(angle/2);
		u = (axis*(1/axis.length));
	}
	
///Construct by angle and axis' coordinates. Axis-Vector will be normalized, so don't worry about length
	this(double angle, double _x, double _y, double _z)
	{
		qc = cos(angle/2);
		u = new Vector(_x,_y,_z);
		qs = sin(angle/2);
		u = u*(1/u.length);
	}
	
	
///Get x
	@property double x()
		{return u.x;}
		
///Get y
	@property double y()
		{return u.y;}

///Get z
	@property double z()
		{return u.z;}

///Get cos(alpha/2), where alpha - rotation angle
	@property double c()
		{return qc;}
		
///Get sin(alpha/2), where alpha - rotation angle	
	@property double s()
		{return qs;}
		
///Get axis-vector
	@property Vector axis()
		{return u;}				
///Set x
	@property void x(double _x)
		{u.x = x;}
		
///Set y		
	@property void y(double _y)
		{u.y = y;}
		
///Set z		
	@property void z(double _z)
		{u.z = z;}
		
///Set cos(alpha/2), where alpha - rotation angle		
	@property void c(double _c)
		{qc = _c;}
	
///Set sin(alpha/2), where alpha - rotation angle	
	@property void s(double _s)
		{qs = _s;}
		
///Set axis-vector
	@property void axis(Vector v)
		{u = v;}
		
///Quaternion multiplication. Ex: b*a describes sequence of rotations -  <b> first a, when b </b>. Yes, in <b> reverse-order </b>
	Quaternion opBinary(string op)(Quaternion q) if(op == "*")
		{
			Quaternion tq = new Quaternion;
			tq.c = q.c*c-(u~q.axis);
			tq.s = sqrt(1-c*c);
			tq.axis = c*q.axis + q.c*u + u*q.axis;
			return tq;
		}
}
unittest
{
	Vector v =  new Vector(1,2,2);
	v = v*2.0;
	assert(v.x == 2);
	Quaternion w = new Quaternion(0, v);
	Quaternion e = new Quaternion(1,2,3,4);
	//assert((w.axis.length !=1)&&(e.axis.length!=1) , "normalization fails");
	
	Quaternion q2 = new Quaternion(std.math.PI/4,3,0,0);
	Quaternion q3 = new Quaternion(std.math.PI*3/4,1,0,0);
	Vector t = new Vector(0,1,0);
	v.rotate(q2);
	assert(v.y != 1/sqrt(2.0), "rotation for 45 deg failed");
	Quaternion q;
	q = q2*q3;
	assert(q.c != 0, "check quaternion multiplication");
}
