/**
*   Copyright: © 2012-2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>,
*             LeMarwin <lemarwin42@gmail.com>,
*             Nazgull09 <nazgull90@gmail.com>
*/
module devol.individ;

import std.variant;

public
{
	import devol.line;	
}

interface IndAbstract
{
	void initialize();
	@property Line[] program();
	@property void program(Line[] val);
	
	@property Line[] memory();
	
	@property double fitness();
	@property void fitness(double val);
	
	@property Line[] invals();
	@property Line[] outvals();
	@property void invals(Line[] val);
	@property void outvals(Line[] val);
	
	@property IndAbstract dup();
}

class Individ : IndAbstract
{
	this()
	{
		mProgram = new Line[0];
		mMemory = new Line[0];
	}
	
	@property Line[] program()
	{
		return mProgram;
	}
	
	@property Line[] memory()
	{
		return mMemory;
	}
	
	@property void program(Line[] val)
	{
		mProgram = val;
	}
	
	@property string programString()
	{
		auto s = "";
		foreach( line; mProgram )
		{
			s ~= line.tostring ~ "\n";
		}
		return s;
	}
	
	@property string memoryString()
	{
		auto s = "";
		foreach( line; mMemory )
		{
			s ~= line.tostring ~ "/0x0A";
		}
		return s;
	}
		
	
	@property double fitness()
	{
		return mFitness;
	}
	
	@property void fitness(double val)
	{
		mFitness = val;
	}
	
	@property Line[] invals()
	{
		return inVals;
	}
	
	@property Line[] outvals()
	{
		return outVals;
	}
	
	@property void invals(Line[] val)
	{
		inVals = val;
	}
	
	@property void outvals(Line[] val)
	{
		outVals = val;
	}
	
	@property Individ dup()
	{
		auto ind = new Individ();
		foreach(line; mProgram)
			ind.mProgram ~= line.dup;
		foreach(line; mMemory)
			ind.mMemory ~= line.dup;	
		foreach(line; inVals)
			ind.inVals ~= line.dup;		
		foreach(line; outVals)
			ind.outVals ~= line.dup;	
		return ind;
	} 
	
	void initialize() {}
	
    protected
    {
    	Line[] mProgram;
    	Line[] mMemory; 	
    	
    	Line[] inVals;
    	Line[] outVals;
    	
    	double mFitness;
    }
}
