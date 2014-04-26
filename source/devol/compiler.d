/**
*   Copyright: © 2012-2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>,
*             LeMarwin <lemarwin42@gmail.com>,
*             Nazgull09 <nazgull90@gmail.com>
*/
module devol.compiler;

import std.stdio;
import std.array;
import std.stream;
import std.conv;
import std.file;
import devol.singleton;
import core.time;
import core.thread;

public
{
	import devol.typemng;
	import devol.operatormng;
	import devol.population;
	import devol.evolutor;
	import devol.programtype;
}

struct SequentCompilation
{
	static void initPop( PopAbstract pop, WorldAbstract world, ProgTypeAbstract progType )
	{
		foreach( ind; pop )
		{
			ind.invals = progType.initValues( world );
			ind.outvals = new Line[0];		
		}		
	}
	
	static void compilePop( PopAbstract pop, WorldAbstract world, ProgTypeAbstract progType, bool delegate() whenExit )
	{
		foreach ( ind; pop )
		{
		    if(whenExit()) return;

			foreach( line; ind.program )
			{
			    if(whenExit()) return;
				line.compile(ind, world);
			}
		}
	}
	
	static void calcPopFitness( PopAbstract pop, WorldAbstract world, ProgTypeAbstract progType )
	{
		uint i =0;
		ulong summ = 0;
		foreach( ind; pop )
		{
			writeln("Individ №",i++);
			ind.fitness = progType.getFitness(ind, world, 0);
			summ += ind.fitness;
			writeln("Fitness = ", ind.fitness ); 
		}
		auto asumm = cast(double)summ/pop.length;
		writeln("Average fitness = ", asumm);
	}
}

struct GameCompilation(alias stopCond, alias drawStep, alias drawFinal, int roundsPerInd) 
{
	static void initPop( PopAbstract pop, WorldAbstract world, ProgTypeAbstract progType )
	{
		foreach( ind; pop )
		{
			ind.invals = progType.initValues( world );
			ind.outvals = new Line[0];		
		}		
	}
	
	static void compilePop( PopAbstract pop, WorldAbstract world, ProgTypeAbstract progType, bool delegate() whenExit )
	{
		foreach ( ind; pop )
		{
			auto fitts = new double[roundsPerInd];
			foreach(j; 0..roundsPerInd)
			{
			    if(whenExit()) return;
				world.initialize();
				int step = 0;
				ind.initialize();
				while( !stopCond( step, ind, world ) )
				{
					
					foreach( line; ind.program )
					{
					    if(whenExit()) return;
						line.compile(ind, world);
						drawStep(ind, world);
					}
					
					step++;
				}
				fitts[j] = progType.getFitness(ind, world, 0);
			}
			double summ = 0;
			foreach(val; fitts)
				summ+=val;
			ind.fitness = summ/fitts.length;
		}			
	}
	
	static void calcPopFitness( PopAbstract pop, WorldAbstract world, ProgTypeAbstract progType )
	{
		uint i =0;
		ulong summ = 0;
		foreach( ind; pop )
		{
			writeln("Individ №",i++);
			ind.fitness = progType.getFitness(ind, world, 0);
			summ += ind.fitness;
			writeln("Fitness = ", ind.fitness ); 
		}
		
		drawFinal(pop, world);
		auto asumm = cast(double)summ/pop.length;
		writeln("Average fitness = ", asumm);
	}	
}

class Compiler(
	CompStg = SequentCompilation, 
	EvolutorStg = Evolutor, 
	ProgType, 
	PopType,
	WorldType) 
	if( __traits(compiles, "PopAbstract pop = new PopType()") )
	: Singleton!Compiler
{
public: 

	this()
	{
		evolutor = new EvolutorStg();
		pops = new PopType[0];
		world = new WorldType();
		progtype = new ProgType();
	}
	
	this(ProgType progtype)
	{
        evolutor = new EvolutorStg();
        pops = new PopType[0];
        world = new WorldType();
        this.progtype = progtype;
	}
	
	void addPop(PopType pop)
	{
		if (pop is null || !checkPop(pop)) return;
		
		pops ~= pop;
	}
	
	PopType getPop(uint i)
	{
		return pops[i];
	}
	
	PopType addPop(int size, string name="")
	{
		auto pop = new PopType(size);
		
		if (name.empty)
			pop.genName();
		else
			pop.name = name;
		
	
		foreach(ref ind; pop)
		{
			evolutor.generateInitProgram(ind, progtype);
		}
		
		debug writeln("Created population ", pop.name, " size of ", size);
		
		pops ~= pop;
		return pop;
	}
	
	void envolveGeneration(bool delegate() whenExit, string saveFolder = "saves")
	{
		foreach( ref pop; pops )
		{
			writeln("Pop init");
			CompStg.initPop( pop, world, progtype );
			if(whenExit()) return;
			
			writeln("Pop compile");
			CompStg.compilePop( pop, world, progtype, whenExit);
			if(whenExit()) return;
			
			writeln("GENERATION №", pop.generation, " results:");
			CompStg.calcPopFitness( pop, world, progtype );
			scope(exit)
			{
                if(!saveFolder.exists)
                    mkdirRecurse(saveFolder);
                    
			    pop.saveBests(text(saveFolder, "/bests/"));
			    pop.saveAll(text(saveFolder, "/all/"));
			    
			    auto binaryFile = new std.stream.File(text(saveFolder, "/population_", pop.generation, ".dpop"), FileMode.OutNew);
			    scope(exit) binaryFile.close();
			    pop.saveBinary(binaryFile);
		    }
			
			if(whenExit()) return;
			pop = evolutor.formNextPopulation( pop, progtype );
			pop.generation = pop.generation + 1;
			if(whenExit()) return;
		}
	}
	
	PopType loadPopulation(InputStream stream)
	{
	    PopType pop = cast(PopType)PopType.loadBinary(stream);
	    assert(pop !is null);
	    pops ~= pop;
	    return pop;
	}
	
protected:
	
	PopType[] pops;
	WorldAbstract world;
	ProgTypeAbstract progtype;
	EvolutorStg evolutor;
	
	bool checkPop(PopAbstract pop)
	{
		foreach(p; pops)
		{
			if (p == pop) return false;
		}
		return true;
	}

}
