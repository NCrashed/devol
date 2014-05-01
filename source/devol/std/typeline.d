/**
*   Copyright: © 2012-2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>,
*             LeMarwin <lemarwin42@gmail.com>,
*             Nazgull09 <nazgull90@gmail.com>
*/
module devol.std.typeline;

import devol.typemng;
import std.stream;

import dyaml.all;

public 
{
	import devol.type;
	import devol.std.line;
	import devol.argument;
}

class TypeLine : Type
{
	this()
	{
		super("TypeLine");
	}
	
	override Argument getNewArg()
	{
		return new Line;
	}
	
	override Argument getNewArg(string min, string max, string[] exVal)
	{
		return new Line;
	}
	
	override Argument loadArgument(InputStream stream)
	{
	    return Line.loadBinary(stream);
	}
	
    override Argument loadArgument(Node node)
    {
        return Line.loadYaml(node);
    }	
}
