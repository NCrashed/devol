/**
*   Copyright: © 2012-2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>,
*             LeMarwin <lemarwin42@gmail.com>,
*             Nazgull09 <nazgull90@gmail.com>
*/
module devol.std.argvoid;

import devol.argument;
import devol.typemng;
import std.stream;

class ArgVoid : Argument
{
	this()
	{
		super( TypeMng.getSingleton().getType("TypeVoid") );
	}
	
	ref ArgVoid opAssign(Argument val)
	{
		return this;
	}
	
	override @property string tostring(uint depth=0)
	{
		return "void";
	}
	
	override void randomChange()
	{
		
	}
	
	override void randomChange(string maxChange)
	{
		
	}
	
	override @property Argument dup()
	{
		return new ArgVoid();
	}
	
	void saveBinary(OutputStream stream)
	{
	}
}
