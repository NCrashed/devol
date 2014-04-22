/**
*   Copyright: © 2012-2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>,
*             LeMarwin <lemarwin42@gmail.com>,
*             Nazgull09 <nazgull90@gmail.com>
*/
module devol.typemng;

import std.stdio;
import std.conv;

import devol.singleton;

public
{
	import devol.std.typeline;
	import devol.std.typevoid;
	import devol.std.typescope;
}

class TypeMng : Singleton!TypeMng
{
	static this()
	{
		auto tm = new TypeMng;
	}
	
	this()
	{
		registerType!(TypeVoid)();
		registerType!(TypeLine)();
		registerType!(TypeScope)();
	}
	
	void registerType(T)()
		if ( __traits(compiles, "Type t = new T()" ) )
	{	
		Type t = new T();
		
		if ( t.name in mTypes )
			throw new Exception(text("Type ", t.name," already registered!"));
		
		mTypes[t.name] = t;
	}
	
	
	Type getType(string name)
	{
		if ( name !in mTypes )
			throw new Exception(name~" type isn't registered!");
			
		return mTypes[name];
	}
		
	@property Type[] types()
	{
		return mTypes.values;
	}
	 
	@property string[] strings()
	{
		return mTypes.keys;
	}
	
	protected Type[string] mTypes;
}
