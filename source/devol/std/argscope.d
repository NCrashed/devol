/**
*   Copyright: © 2012-2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>,
*             LeMarwin <lemarwin42@gmail.com>,
*             Nazgull09 <nazgull90@gmail.com>
*/
module devol.std.argscope;

import std.conv;
import std.random;
import std.algorithm;
import std.stream;

import devol.std.container;
import devol.std.random;
import devol.std.typescope;
import devol.typemng;
import devol.std.line;

class ArgScope : Container
{
	private Line[] lines;
	
	this(Type t)
	{
		lines = new Line[0];
		super( t );
	}

	override @property string tostring(uint depth=0)
	{
		string ret = "";
		
		foreach( l; lines )
		{
			ret ~= l.tostring(depth) ~ to!char(0x0A);
		}
		
		return ret;
	}

	override void randomChange()
	{
		
	}
	
	override void randomChange(string maxChange)
	{
		
	}
	
	override Argument getRandomElement()
	{
		return lines[uniform(0, lines.length)];
	}
	
	override Argument getRandomElement(double[] chances)
	{
		Argument ret;
		randomRange!(
			(int k)
			{
				ret = lines[k];
			}
			)(chances[0..lines.length]);
		return ret;
	}
	
	override void replaceRandomElement(Argument narg)
	{
		if (cast(Line)(narg) is null) return;
		lines[uniform(0, lines.length)] = cast(Line)(narg);
	}
	
	override void replaceRandomElement(double[] chances, Argument narg)
	{
		if (cast(Line)(narg) is null) return;
		randomRange!(
			(int k)
			{
				lines[k] = cast(Line)(narg);
			}
			)(chances[0..lines.length]);		
	}
	
	override void replaceRandomElement(Argument delegate(Type t) del)
	{
		auto i = uniform(0, lines.length);
		Line l = cast(Line)del( lines[i].operator.rtype );
		if (l !is null)
			lines[ i ] = l;
	}
	
	override void replaceRandomElement(Argument delegate(Type t) del, double[] chances)
	{
		randomRange!((int k)
			{
				Line l = cast(Line)del( lines[k].operator.rtype );
				if (l !is null)
					lines[k] = l;
			})(chances[0..lines.length]);		
	}
	
	override Argument getRandomLeaf()
	{
		return null;
	}
	
	override Argument getRandomLeaf(double[] chances)
	{
		return null;
	}
	
	override uint getLeafCount()
	{
		return 0;
	}
	
	override void addElement( Argument arg )
	{
		auto l = cast(Line)arg;
		if (l is null) return;
		lines ~= l;
	}
	
	override void removeElement(size_t i)
	{
		if (i>0 && i<lines.length) return;
		lines.remove(i);
	}
	
	override void removeAll()
	{
		lines.clear();
	}


	override Line opIndex( size_t i )
	{
		return lines[i];
	}
	
	int opApply(int delegate(Line) dg)
	{
		int result = 0;
		
		foreach( i, l; lines)
		{
			result = dg(l);
			if (result) break;
		}
		return result;
	}
	
	override int opApply(int delegate(Argument) dg)
	{
		int result = 0;
		
		foreach( i, l; lines)
		{
			result = dg(l);
			if (result) break;
		}
		return result;
	}
	
	override @property ulong children()
	{
		ulong res = 1;
		foreach( l; lines)
			res+=l.children;
		return res;
	}
	
	override @property ulong leafs()
	{
		ulong res = 0;
		foreach( l; lines)
			res+=l.children;
		return res;
	}
	
	override @property Argument dup()
	{
		auto dscope = new ArgScope(type);
		
		foreach(l; lines)
			dscope.lines ~= l.dup();
			
		return dscope;
	}
	
	override void opIndexAssign( Argument val, size_t i )
	{
		auto l = cast(Line)(val);
		if (l !is null)
			lines[i] = l;
	}
	
	override Argument[] opSlice( size_t a, size_t b )
	{
		return cast(Argument[])lines[a .. b];
	}
	
	override size_t opDollar()
	{
		return lines.length;
	}
	
	override @property size_t length()
	{
		return lines.length;
	}
	
	static ArgScope loadBinary(InputStream stream)
	{
	    ulong length;
	    stream.read(length);
	    
	    auto ascope = new ArgScope(TypeMng.getSingleton().getType("TypeVoid"));
	    
	    foreach(i; 0..cast(size_t)length)
	    {
	        char[] mark;
	        stream.read(mark);
	        assert(mark.idup == "line");
	        
	        ascope.addElement(Line.loadBinary(stream));
	    }
	    return ascope;
	}
	
	void saveBinary(OutputStream stream)
	{
	    stream.write("scope");
	    
	    stream.write(cast(ulong)lines.length);
	    foreach(line; lines)
	    {
	        line.saveBinary(stream);
	    }
	}
}
