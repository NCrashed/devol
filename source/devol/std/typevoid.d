/**
*   Copyright: © 2012-2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>,
*             LeMarwin <lemarwin42@gmail.com>,
*             Nazgull09 <nazgull90@gmail.com>
*/
module devol.std.typevoid;

import devol.type;
import devol.std.argscope;
import devol.std.line;
import std.stream;

public
{
	import devol.std.argvoid;	
}

class TypeVoid : Type
{
	this()
	{
		super("TypeVoid");
	}
	
	override Argument getNewArg()
	{
		return new ArgVoid;
	}
	
	override Argument getNewArg(string min, string max, string[] exVal)
	{
		return new ArgVoid;
	}
	
	override Argument loadArgument(InputStream stream)
	{
	    char[] cont;
	    stream.read(cont);
	    
	    if(cont == "line")
	    {
	        return Line.loadBinary(stream);
	    } 
	    else if(cont == "scope")
	    {
	        return ArgScope.loadBinary(stream);
	    } 
	    else if(cont == "plain")
	    {
	        return new ArgVoid;
	    }
	    
	    throw new Exception("Unknown void container!");
	}	
}
