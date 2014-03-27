/**
*   Copyright: © 2012-2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>,
*             LeMarwin <lemarwin42@gmail.com>,
*             Nazgull09 <nazgull90@gmail.com>
*/
module devol.operator;

import std.string;
import std.conv;

import devol.type;
import devol.argument;
import devol.line;
import devol.world;
import devol.individ;

enum ArgsStyle
{
	CLASSIC_STYLE,
	MASS_STYLE,
	BINAR_STYLE,
	UNAR_STYLE,
	NULAR_STYLE,
	CONTROL_STYLE
}

struct ArgInfo
{
	Type type;
	string[] exVals;
	string min;
	string max;
}

abstract class Operator
{
	this(string name, string discr, ArgsStyle style)
	{
		sName = name;
		sDiscr = discr;
		mStyle = style;
		
		args = new ArgInfo[0];
		
		assert(mRetType,"Return type isn't setted!");
	}
	
	@property int argsNumber()
	{
		return cast(uint)(args.length);
	}
	
	@property ArgsStyle style()
	{
		return mStyle;
	}
	
	@property string name()
	{
		return sName;
	}
	
	@property string disrc()
	{
		return sDiscr;
	}
	
	@property Type rtype()
	{
		return mRetType;
	}
	
	ArgInfo opIndex( uint i )
	{
		return args[i];
	}
	
	ArgInfo[] opSlice( uint a, uint b )
	{
		return args[a..b];
	}
	
	uint opDollar()
	{
		return cast(uint)(args.length);
	}
	
	int opApply(int delegate(ref ArgInfo) dg)
	{
		int result = 0;
		
		foreach( i, ref arg; args)
		{
			result = dg(arg);
			if (result) break;
		}
		return result;
	}
	
	Argument generateArg( uint i )
	{	
		auto ainfo = args[i];
		return ainfo.type.getNewArg(ainfo.min, ainfo.max, ainfo.exVals);
	}
	
	Argument apply(IndAbstract ind, Line line, WorldAbstract world)
	in
	{
		assert( line.length == args.length, text("Critical error: operator ", name, ", geted args count is ", line.length, " but needed ", args.length, "!"));
		foreach(i,ai; args)
		{
			assert( ai.type.name == line[0].type.name, text("Critical error: operator ", name, ", argument №", i, " is type of ", ai.type.name, " but needed ", line[0].type.name, "!"));
		}
	}
	out(result)
	{
		assert( result !is null, text("Critical error: operator ", name, ", return value is null! Forgeted to overload std apply?")); 
	}
	body
	{
		return null;
	}
	
protected:
	ArgInfo[] args;
	ArgsStyle mStyle;
	string sName;
	string sDiscr;
	Type mRetType;
}
