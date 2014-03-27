/**
*   Copyright: © 2012-2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>,
*             LeMarwin <lemarwin42@gmail.com>,
*             Nazgull09 <nazgull90@gmail.com>
*/
module devol.singleton;

class Singleton(Class)
{
	this()
	{
		msSingleton = cast(Class)(this);
	}
	
	static Class getSingleton()
	{
		return msSingleton;
	}
	
	private static Class msSingleton = null;
}
