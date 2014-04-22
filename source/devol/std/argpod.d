/**
*   Copyright: © 2012-2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>,
*             LeMarwin <lemarwin42@gmail.com>,
*             Nazgull09 <nazgull90@gmail.com>
*/
module devol.std.argpod;

import std.conv;
import std.random;
import devol.serializable;
import devol.typemng;

class ArgPod(T) : Argument, ISerializable
{
	this()
	{
		super( TypeMng.getSingleton().getType("Type"~T.stringof) );
	}
	
	this(T val)
	{
	    this();
	    opAssign(val);
	}
	
	ref ArgPod!T opAssign(Argument val)
	{
		auto apod = cast(ArgPod!T)(val);
		if (apod is null) return this;
		
		mVal = apod.mVal;
		return this;
	}
	
	ref ArgPod!T opAssign(T val)
	{
		mVal = val;
		return this;
	}
	
	override @property string tostring(uint depth=0)
	{
		return to!string(mVal);
	}
	
	@property T val()
	{
		return mVal;
	}
	
	@property T value()
	{
		return mVal;
	}
	
	override void randomChange()
	{
		static if (!is(T == bool))
		{
			mVal = uniform!"[]"(-mVal.max, mVal.max);
		} else
		{
			mVal = uniform!"[]"(0, 1) != 0;
		}
	}
	
	override void randomChange(string maxChange)
	{
		static if (!is(T == bool))
		{
			T ch;
			try
			{
				ch = to!T(maxChange);
			} catch( Exception e )
			{
				return;
			}
			
			mVal = uniform!"[]"(cast(T)(mVal-ch), cast(T)(mVal+ch));
		} else
		{
			mVal = uniform!"[]"(0, 1) != 0;
		}
	}
	
	override @property Argument dup()
	{
		auto darg = new ArgPod!T();
		darg.mVal = mVal;
		return darg;
	}
	
	void saveBinary(OutputStream stream)
	{
	    static if(is(T == bool))
	    {
	        stream.write(cast(ubyte)mVal);
	    } else
	    {
	        stream.write(mVal);
        }
	}
	
	protected T mVal;
}
