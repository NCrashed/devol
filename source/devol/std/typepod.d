/**
*   Copyright: © 2012-2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>,
*             LeMarwin <lemarwin42@gmail.com>,
*             Nazgull09 <nazgull90@gmail.com>
*/
module devol.std.typepod;

import std.random;
import std.conv;
import std.stream;

public
{
	import devol.argument;
	import devol.type;
	import devol.std.argpod;
}

alias TypePod!bool 		TypeBool;
alias TypePod!int		TypeInt;
alias TypePod!float		TypeFloat;
alias TypePod!long		TypeLong;
alias TypePod!double	TypeDouble;
alias TypePod!char		TypeChar;
alias TypePod!uint		TypeUInt;

class TypePod(T) : Type
{
	this()
	{
		super("Type"~T.stringof);
	}
	
	override ArgPod!T getNewArg()
	{
		auto arg = new ArgPod!T();
		arg = T.init;
		return arg;
	}
	
	override ArgPod!T getNewArg(string min, string max, string[] exVal)
	{
		auto arg = new ArgPod!T();
		
		bool except( T val, string[] ex)
		{
			foreach( s; ex)
				if (to!T(s) == val)
					return true;
			return false;
		}
		
		static if ( !is(T == bool) )
		{
			do
			{
				arg = uniform!("[]")(to!T(min), to!T(max));
			} while( except( arg.val, exVal) );
		} else 
		{
			do
			{
				arg = (uniform!("[]")(0, 1)) == 1;
			} while( except( arg.val, exVal) );			
		}
		return arg;
	}
	
	override Argument loadArgument(InputStream stream)
	{
	    static if(is(T == bool))
	    {
            ubyte val;
            stream.read(val);
            
            return new ArgPod!T(cast(bool)val);
	    } else
	    {
            T val;
            stream.read(val);
            return new ArgPod!T(val);
	    }
	}	
}
