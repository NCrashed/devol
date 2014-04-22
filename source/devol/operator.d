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
import devol.std.line;
import devol.world;
import devol.individ;
import devol.serializable;
import devol.operatormng;

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

abstract class Operator : ISerializable
{
	this(string name, string discr, ArgsStyle style)
	{
		sName = name;
		sDiscr = discr;
		mStyle = style;
		
		args = new ArgInfo[0];
		
		assert(mRetType,"Return type isn't set!");
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
	
	ArgInfo opIndex( size_t i )
	{
		return args[i];
	}
	
	ArgInfo[] opSlice( size_t a, size_t b )
	{
		return args[a..b];
	}
	
	size_t opDollar()
	{
		return args.length;
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
	
	Argument generateArg( size_t i )
	{	
		auto ainfo = args[i];
		return ainfo.type.getNewArg(ainfo.min, ainfo.max, ainfo.exVals);
	}
	
	Argument apply(IndAbstract ind, Line line, WorldAbstract world)
	in
	{
		assert( line.length == args.length, text("Critical error: operator ", name, ", got args count is ", line.length, " but needed ", args.length, "!"));
		foreach(i,ai; args)
		{
			assert( ai.type.name == line[0].type.name, text("Critical error: operator ", name, ", argument №", i, " is type of ", ai.type.name, " but needed ", line[0].type.name, "!"));
		}
	}
	out(result)
	{
		assert( result !is null, text("Critical error: operator ", name, ", return value is null! Forgotten to overload std apply?")); 
	}
	body
	{
		return null;
	}
	
	void saveBinary(OutputStream stream)
	{
	    assert(sName != "", "Operator name is empty string!");
	    stream.write(sName);
	}
	
	static Operator loadBinary(InputStream stream)
	{
	    char[] opname;
	    stream.read(opname);
	    
	    return OperatorMng.getSingleton().getOperator(opname.idup);
	}
	
protected:
	ArgInfo[] args;
	ArgsStyle mStyle;
	string sName;
	string sDiscr;
	Type mRetType;
}
