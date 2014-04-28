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

interface SequentCompilation
{
	final void initPop( PopAbstract pop, WorldAbstract world, ProgTypeAbstract progType )
	{
		foreach( ind; pop )
		{
			ind.invals = progType.initValues( world );
			ind.outvals = new Line[0];		
		}		
	}
	
	final void compilePop( PopAbstract pop, WorldAbstract world, ProgTypeAbstract progType, bool delegate() whenExit )
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
	
	final void calcPopFitness( PopAbstract pop, WorldAbstract world, ProgTypeAbstract progType )
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

interface GameCompilation
{
    bool stopCond(ref int step, IndAbstract ind, WorldAbstract world);
    void drawStep(IndAbstract ind, WorldAbstract world);
    void drawFinal(PopAbstract pop, WorldAbstract world);
    int roundsPerInd();
    
	final void initPop( PopAbstract pop, WorldAbstract world, ProgTypeAbstract progType )
	{
		foreach( ind; pop )
		{
			ind.invals = progType.initValues( world );
			ind.outvals = new Line[0];		
		}		
	}
	
	final void compilePop( PopAbstract pop, WorldAbstract world, ProgTypeAbstract progType
	    , bool delegate() whenExit, void delegate(double) updater , bool delegate() pauser)
	{
        bool continuation(double progress)
        {
            updater(progress);
            if(whenExit()) return false; 
            while(pauser()) updater(progress);
            return true;
        }
        
		foreach (i, ind; pop )
		{
		    if(!continuation(0.0)) return;
		    double popProgress = (i+1) / cast(double)pop.length;
		    
		    version(Verbose) std.stdio.writeln(ind.programString);
		    
			auto fitts = new double[roundsPerInd];
			foreach(j; 0..roundsPerInd)
			{
			    version(Verbose)std.stdio.writeln("Round: ", j);
			    
			    double prevIndProgress = j / cast(double)roundsPerInd;
			    double indProgress = (j+1) / cast(double)roundsPerInd;
			    
			    if(!continuation(prevIndProgress * popProgress)) return;
			    
			    version(Verbose)std.stdio.writeln("World initialization: ");
				world.initialize();
				int step = 0;
				
				version(Verbose) std.stdio.writeln("Individ initialization: ");
				ind.initialize();
				while( !stopCond( step, ind, world ) )
				{
				    version(Verbose) std.stdio.writeln("Step ", step);
					foreach( line; ind.program )
					{
					    version(Verbose) std.stdio.writeln("line : ", line.tostring);
					    if(whenExit()) return;
						line.compile(ind, world);
						drawStep(ind, world);
					}
					
					step++;
				}
				version(Verbose) std.stdio.writeln("Saving fitness ");
				fitts[j] = progType.getFitness(ind, world, 0);
				
				if(!continuation(indProgress * popProgress)) return;
			}
			double summ = 0;
			foreach(val; fitts)
				summ+=val;
			ind.fitness = summ/fitts.length;
			
			if(!continuation(popProgress)) return;
		}			
	}
	
	final void calcPopFitness( PopAbstract pop, WorldAbstract world, ProgTypeAbstract progType )
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

	this(CompStg compStrategy)
	{
	    compStg = compStrategy;
		evolutor = new EvolutorStg();
		pops = [];
		world = new WorldType();
		progtype = new ProgType();
	}
	
	this(CompStg compStrategy, ProgType progtype)
	{
	    compStg = compStrategy;
        evolutor = new EvolutorStg();
        pops = [];
        world = new WorldType();
        this.progtype = progtype;
	}
	
	void addPop(PopType pop)
	{
		if (pop is null || !checkPop(pop)) return;
		
		pops ~= pop;
	}
	
	void clean()
	{
	    pops = [];
	}
	
	PopType getPop(size_t i)
	{
		return pops[i];
	}
	
	PopType addPop(size_t size, string name="")
	{
		auto pop = new PopType(size);
		
		if (name.empty)
			pop.genName();
		else
			pop.name = name;
		
	
		foreach(ind; pop)
		{
			evolutor.generateInitProgram(ind, progtype);
		}
		
		debug writeln("Created population ", pop.name, " size of ", size);
		
		pops ~= pop;
		return pop;
	}
	
	void envolveGeneration(bool delegate() whenExit, string saveFolder,
	    void delegate(double) updater , bool delegate() pauser)
	{
	    bool continuation(double progress)
	    {
	        updater(progress);
            if(whenExit()) return false; 
            while(pauser()) updater(progress);
            return true;
	    }
	    
		foreach(i, ref pop; pops )
		{
		    double progressPart = (i+1) / cast(double) pops.length;
		    
			writeln("Pop init");
			compStg.initPop( pop, world, progtype );
			if(!continuation(1.0 / 4.0 * progressPart)) return;
			
			writeln("Pop compile");
			compStg.compilePop( pop, world, progtype, whenExit
			    , (val)
			    {
			        updater(1.0 / 4.0 * progressPart + val / 4.0 * progressPart );
			    }
			    , pauser);
			if(!continuation(2.0 / 4.0 * progressPart)) return;
			
			writeln("GENERATION №", pop.generation, " results:");
			compStg.calcPopFitness( pop, world, progtype );
			if(!continuation(3.0 / 4.0 * progressPart)) return;
			
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
			
			pop = evolutor.formNextPopulation( pop, progtype );
			pop.generation = pop.generation + 1;
			if(!continuation(progressPart)) return;
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
	
	CompStg compStg;
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
