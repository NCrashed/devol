/**
*   Copyright: © 2012-2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>,
*             LeMarwin <lemarwin42@gmail.com>,
*             Nazgull09 <nazgull90@gmail.com>
*/
module devol.population;

import std.stdio;

import std.random;
import std.string;
import std.array;
import std.algorithm;
import std.conv;
import std.file;
import std.path;
import devol.serializable;

public
{
	import devol.individ;
}

interface PopAbstract : ISerializable
{
	void genName(size_t size);
	@property string name();
	@property void name(string val);
	@property uint generation();
	@property void generation(uint val);
	@property size_t length();
	IndAbstract opIndex( size_t i );
	IndAbstract[] opSlice( size_t a, size_t b );
	size_t opDollar();
	int opApply(int delegate(ref IndAbstract) dg);
}

static string getDefChars()
{
	string ret = "qwertyuiopasdfghjklzxcvbnm";
	return ret ~ toUpper(ret);
}

alias Population!(getDefChars, Individ) StdPop;

class Population(alias nameChecker, IndType)
	if ( is(typeof(nameChecker()) == string) )
	: PopAbstract
{
	enum DefNameLength = 10;
	enum DefNameChars = getDefChars();
	
	alias Population!(nameChecker, IndType) thistype;
	alias IndType IndividType;
	
	@property uint generation()
	{
		return iGeneration;
	}
	
	@property void generation(uint val)
	{
		//if (val < iGeneration) return;
		iGeneration = val;
	}
	
	this()
	{
		inds = new Individ[0];
	}
	
	this(size_t size)
	{
		inds = new Individ[size];
		foreach( ref ind; inds)
		{
			ind = new IndType;
		}
	}
	
	void genName(size_t size = DefNameLength)
	{
		auto buff = new char[size];
		string chars = nameChecker();
		foreach(ref c; buff)
		{
			c = chars[uniform(0,chars.length)];
		}
		mName = buff.idup;
	}
	
	@property string name()
	{
		return mName;
	}
	 
	@property void name(string val)
	{
		string chars = nameChecker();
		foreach(i,c; val)
		{
			if ( chars.find(c).empty )
			{
				val = val[0..i] ~ chars[uniform(0,chars.length)] ~ val[i+1..$];
			}
		}
		mName = val;
	}
	
	@property size_t length()
	{
		return inds.length;
	}
	
	IndType opIndex( size_t i )
	{
		return cast(IndType)inds[i];
	}
	
	IndAbstract[] opSlice( size_t a, size_t b )
	{
		return cast(IndAbstract[])(inds[a..b]);
	}
	
	size_t opDollar()
	{
		return inds.length;
	}
	
	int opApply(int delegate(ref IndAbstract) dg)
	{
		int result = 0;
		
		foreach( i,ref ind; inds)
		{
			IndAbstract inda = (ind);
			result = dg(inda);
			if (result) break;
		}
		return result;
	}
	
	auto opBinary(string m)(IndType val)
		if (m == "~")
	{
		inds ~= val;
		return this;
	}
	
	void addIndivid(IndType val)
	{
		if (val is null) return;
		inds ~= val;
	}
	
	void saveBests(string filename)
	{
		if (inds.length == 0) return;

		auto sortedInds = inds.sort!"a.fitness > b.fitness";
		
		Individ best;
		int k = 0;
		
		std.stdio.File* f;
		try
		{
            mkdirRecurse(filename);
                
			f = new std.stdio.File(filename~mName~"_g"~to!string(iGeneration), "w");
		
			do
			{
				best = sortedInds[k++];
				f.writeln("Individ №", k,":");
				f.writeln(best.programString());
				f.writeln("==================================");
			} while( k < sortedInds.length && sortedInds[k].fitness >= best.fitness);
		} catch(Exception e)
		{
			writeln("FAILED TO CREATE FILE TO WRITE RESULTED INDIVIDS!!");
		}
	}
	
	void saveAll(string filename)
	{
		std.stdio.File* f;
		try
		{
		    mkdirRecurse(filename);
		        
			f = new std.stdio.File(filename~mName~"_g"~to!string(iGeneration), "w");
			
			foreach(i,ind;inds)
			{
				f.writeln("Individ №", i,":");
				f.writeln(ind.programString());
				f.writeln("==================================");			
			}	
		} catch(Exception e)
		{
			writeln("FAILED TO CREATE FILE TO WRITE RESULTED INDIVIDS!!");
		}
	}
	
	@property auto dup()
	{
		auto ret = new Population!(nameChecker, IndType);
		ret.iGeneration = iGeneration;
		foreach(ind;inds)
			ret.inds ~= ind.dup;
		ret.mName = mName;
		return ret;
	}
	
	void clear()
	{
		inds.clear();
	}
	
	void saveBinary(OutputStream stream)
	{
	    stream.write(mName);
	    stream.write(iGeneration);
	    
	    stream.write(cast(ulong)inds.length);
	    foreach(ind; inds)
	    {
	        ind.saveBinary(stream);
	    }
	}
	
	static thistype loadBinary(InputStream stream)
	{
	    auto pop = new thistype();
	    char[] popName;
	    stream.read(popName);
	    pop.mName = popName.idup;
	    
	    stream.read(pop.iGeneration);
	    
	    ulong indsLength;
	    stream.read(indsLength);
	    auto builder = appender!(Individ[]);
	    foreach(i; 0..cast(size_t)indsLength)
	    {
	        auto ind = IndType.loadBinary(stream);
	        
	        if(ind is null)
	        {
	            throw new Exception("Loaded ind is null!");
	        }
	        
	        builder.put(new IndType(ind));
	    }
	    pop.inds = builder.data;
	    
	    return pop;
	}
	
    protected
    {
    	uint iGeneration;
    	Individ[] inds;
    	string mName = "";
    }
}
