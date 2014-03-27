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

public
{
	import devol.individ;
}

interface PopAbstract
{
	void genName(int size);
	@property string name();
	@property void name(string val);
	@property uint generation();
	@property void generation(uint val);
	@property ulong length();
	IndAbstract opIndex( uint i );
	IndAbstract[] opSlice( uint a, uint b );
	uint opDollar();
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
public:
	static int 		DefNameLength = 10;
	static string 	DefNameChars = getDefChars();
	 
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
		inds = new IndType[0];
	}
	
	this(uint size)
	{
		inds = new IndType[size];
		foreach( ref ind; inds)
		{
			ind = new IndType;
		}
	}
	
	void genName(int size = DefNameLength)
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
	
	@property ulong length()
	{
		return inds.length;
	}
	
	IndType opIndex( uint i )
	{
		return inds[i];
	}
	
	IndAbstract[] opSlice( uint a, uint b )
	{
		return cast(IndAbstract[])(inds[a..b]);
	}
	
	uint opDollar()
	{
		return cast(uint)(inds.length);
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
		
		IndType best;
		int k = 0;
		
		File* f;
		try
		{
		    mkdirRecurse(filename);
			f = new File(filename~mName~"_g"~to!string(iGeneration), "w");
		
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
		File* f;
		try
		{
		    mkdirRecurse(filename);
			f = new File(filename~mName~"_g"~to!string(iGeneration), "w");
			
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
	
    protected
    {
    	uint iGeneration;
    	IndType[] inds;
    	string mName = "";
    }
}
