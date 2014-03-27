/**
*   Copyright: © 2012-2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>,
*             LeMarwin <lemarwin42@gmail.com>,
*             Nazgull09 <nazgull90@gmail.com>
*/
module devol.std.typescope;

public
{
	import devol.type;
	import devol.argument;
	import devol.std.argscope;
}

class TypeScope : Type
{
	this()
	{
		super("TypeScope");
	}
	
	override ArgScope getNewArg()
	{
		return new ArgScope(this);
	}
	
	override ArgScope getNewArg(string min, string max, string[] exVal)
	{
		return new ArgScope(this);
	}
		
}
