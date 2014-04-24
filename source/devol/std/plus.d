/**
*   Copyright: © 2012-2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>,
*             LeMarwin <lemarwin42@gmail.com>,
*             Nazgull09 <nazgull90@gmail.com>
*/
module devol.std.plus;

import std.stdio;

import devol.typemng;

public
{
	import devol.individ;
	import devol.world;
	import devol.operator;
	import devol.std.typepod;
}

class Plus : Operator
{
	TypePod!int inttype;
	
	enum description = "Arithmetic operator that adds two arguments and returns the result.";
	
	this()
	{
		inttype = cast(TypePod!int)(TypeMng.getSingleton().getType("Typeint"));
		assert(inttype, "We need int type!");
		
		mRetType = inttype;
		super("+", description, ArgsStyle.BINAR_STYLE);
		
		ArgInfo a1;
		a1.type = inttype;
		a1.min = "-1000";
		a1.max = "+1000";
		
		args ~= a1;
		args ~= a1;
	}
	
	/// TODO: enable adding not only ints
	override Argument apply(IndAbstract ind, Line line, WorldAbstract world)
	{
		//debug writeln("Plus: Getting return type");
		auto ret = inttype.getNewArg();
		
		//debug writeln("Plus: casting arugments");
		auto a1 = cast(ArgPod!int)(line[0]);
		auto a2 = cast(ArgPod!int)(line[1]);
		
		//debug writeln( line[0].type.name );
		//debug writeln( line[0].type.name );
		
		assert( a1 !is null, "Critical error: Operator plus, argument 1 isn't a right value!");
		assert( a2 !is null, "Critical error: Operator plus, argument 2 isn't a right value!");
		
		//debug writeln("Plus: adding arguments");
		ret = a1.val + a2.val;
		//debug writeln("Plus: succes");
		return ret;
	}	
}

unittest
{
	/*auto tm = new TypeMng();
	tm.registerType!(TypePod!int)();
	
	auto pOp =  new Plus();
	auto ind =  new Individ();
	
	class DummyWorld : WorldAbstract
	{
		void init() {}
	}
	auto world = new DummyWorld();
	
	auto a1 = pOp.inttype.getNewArg();
	a1.val = 10;
	auto a2 = pOp.inttype.getNewArg();
	a2.val = 23;
	
	auto line = new Line();
	line.op = pOp;
	line[0] = a1;
	line[1] = a2;
	assert( line.compile( ind, world ).val ==  );*/
}
