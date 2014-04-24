/**
*   Copyright: © 2012-2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>,
*             LeMarwin <lemarwin42@gmail.com>,
*             Nazgull09 <nazgull90@gmail.com>
*/
module devol.operatormng;

import std.stdio;
import std.random;
import std.array;
import std.conv;

import devol.singleton;

public
{
	import devol.operator;
	import devol.type;
}

class OperatorMng : Singleton!OperatorMng
{
	static this()
	{
		new OperatorMng();
	}
	
	void registerOperator(T)()
		if ( __traits(compiles, "Operator t = new T()" ) )
	{
		Operator t = new T();
		
		if ( t.name in operators )
			throw new Exception(text("Operator ", t.name, " is already registered!"));
		
		operators[t.name] = t;		
	}
	
	Operator getOperator(string name)
	{
		if ( name !in operators )
			throw new Exception(text("Operator ", name," isn't registered!"));
			
		return operators[name];
	}
	
	Operator getRndOperator()
	{
		if (operators.keys.empty) return null;
		
		return operators.values[uniform(0,operators.length)];
	}

	Operator getRndOperator(Type retType)
	{
		if (operators.keys.empty || retType is null) return null;
		
		auto buff = new Operator[0];
		
		foreach(op; operators)
		{
			if ( retType.isConvertable(op.rtype) )
				buff ~= op;
		}
		if (buff.empty) return null;
		
		return buff[uniform(0,buff.length)];
	}
	
	@property string[] strings()
	{
		auto ret = new string[0];
		foreach(s; operators.keys)
		{
			ret ~= s;
		}
		return ret;
	}
	
    int opApply(int delegate(ref Operator) dg)
    {
        int result = 0;
    
        foreach(operator; operators)
        {
            result = dg(operator);
            if (result) break;
        }
        return result;
    }

	protected Operator[string] operators;
}
