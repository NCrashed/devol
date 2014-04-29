/**
*   Copyright: © 2012-2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>,
*             LeMarwin <lemarwin42@gmail.com>,
*             Nazgull09 <nazgull90@gmail.com>
*/
module devol.individ;

import std.variant;
import std.array;
import std.random;

import devol.serializable;

public
{
	import devol.std.line;	
}

interface IndAbstract
{
	void initialize();
	@property string name();
	@property void name(string name);
	
	@property Line[] program();
	@property void program(Line[] val);
	@property size_t getGenomeSize();
	
	@property Line[] memory();
	
	@property double fitness();
	@property void fitness(double val);
	
	@property Line[] invals();
	@property Line[] outvals();
	@property void invals(Line[] val);
	@property void outvals(Line[] val);
	
	@property IndAbstract dup();
	
	@property string programString();
}

class Individ : IndAbstract, ISerializable
{
	this()
	{
		mProgram = new Line[0];
		mMemory = new Line[0];
		mName = autogenName();
	}
	
	private string autogenName()
	{
		enum alphabet = "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM";
		size_t length = uniform!"[]"(5,8);
		auto builder = appender!string;
		foreach(i; 0..length)
		{
			builder.put(alphabet[uniform(0, alphabet.length)]);
		}
		return builder.data;
	}
	
	@property string name()
	{
		return mName;
	}
	
	@property void name(string name)
	{
		mName = name;
	}
	
    this(Individ ind)
    {
        this();
        loadFrom(ind);
    }
    
    void loadFrom(Individ ind)
    {
        this.program = ind.program;
        this.memory = ind.memory;
        this.invals = ind.invals;
        this.outvals = ind.outvals;
        this.fitness = ind.fitness;
    }
    
	@property Line[] program()
	{
		return mProgram;
	}
	
	size_t getGenomeSize()
	{
	    size_t genome;
	    foreach(line; mProgram)
	    {
	        genome += line.leafs;
	    }
	    return genome;
	}
	
	@property Line[] memory()
	{
		return mMemory;
	}
	
    @property void memory(Line[] val)
    {
        mMemory = val;
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
	
	void saveBinary(OutputStream stream)
	{
	    stream.write(cast(ulong)mProgram.length);
	    foreach(line; mProgram)
	    {
	        line.saveBinary(stream);
	    }
	    
	    stream.write(cast(ulong)mMemory.length);
	    foreach(line; mMemory)
	    {
	        line.saveBinary(stream);
	    }
	    
	    stream.write(cast(ulong)inVals.length);
	    foreach(line; inVals)
	    {
	        line.saveBinary(stream);
	    }
	    
	    stream.write(cast(ulong)outVals.length);
	    foreach(line; outVals)
	    {
	        line.saveBinary(stream);
	    }
	    
	    stream.write(mFitness);
	    stream.write(mName);
	}
	
	static Individ loadBinary(InputStream stream)
	{
	    Line[] loadLineArray(size_t length)
	    {
            auto builder = appender!(Line[]);
            foreach(i; 0..length)
            {
                char[] mark;
                stream.read(mark);
                assert(mark.idup == "line", "Mark is "~mark.idup);
                
                auto line = Line.loadBinary(stream);
                std.stdio.writeln(line.tostring(0));
                builder.put(line);
            }
            return builder.data;
	    }
	    
	    auto ind = new Individ;
	    
	    ulong programLength;
	    stream.read(programLength);
	    ind.mProgram = loadLineArray(cast(size_t)programLength);
	    
	    ulong memoryLength;
        stream.read(memoryLength);
        ind.mMemory = loadLineArray(cast(size_t)memoryLength);
        
        ulong inValsLength;
        stream.read(inValsLength);
        ind.inVals = loadLineArray(cast(size_t)inValsLength);
        
        ulong outValsLength;
        stream.read(outValsLength);
        ind.outVals = loadLineArray(cast(size_t)outValsLength);
        
        stream.read(ind.mFitness);
        char[] buff;
        stream.read(buff);
        ind.mName = buff.idup;
        
        return ind;
	}
	
    protected
    {
    	Line[] mProgram;
    	Line[] mMemory; 	
    	
    	Line[] inVals;
    	Line[] outVals;
    	
    	double mFitness;
    	string mName;
    }
}
