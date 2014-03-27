/**
*   Copyright: © 2012-2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>,
*             LeMarwin <lemarwin42@gmail.com>,
*             Nazgull09 <nazgull90@gmail.com>
*/
module devol.argument;

import devol.type;

abstract class Argument
{
	this(Type type)
	{
		pType = type;
	}
	
	@property Type type()
	{
		assert(pType);
		return pType;
	}
	
	@property string tostring(uint depth=0)
	{
		return "";
	}
	
	@property ulong children()
	{
		return 1;
	}
	
	@property ulong leafs()
	{
		return 1;
	}
	
	private Type pType; 
	
	void randomChange();
	void randomChange(string maxChange);
	@property Argument dup();
}
