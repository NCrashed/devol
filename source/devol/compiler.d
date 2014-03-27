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
	
	static void compilePop( PopAbstract pop, WorldAbstract world, ProgTypeAbstract progType )
	{
		writeln("Entered compile method");
		foreach ( ind; pop )
		{
			writeln("Taking indivi");
			foreach( line; ind.program )
			{
				writeln("Compiling line");
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
	
	static void compilePop( PopAbstract pop, WorldAbstract world, ProgTypeAbstract progType )
	{
		writeln("Entered compile method");

		foreach ( ind; pop )
		{
			auto fitts = new double[roundsPerInd];
			foreach(j; 0..roundsPerInd)
			{
				world.initialize();
				int step = 0;
				ind.initialize();
				while( !stopCond( step, ind, world ) )
				{
					
					foreach( line; ind.program )
					{
						writeln("Compiling line");
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
			//ind.fitness = progType.getFitness(ind, world, 0);
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
		//super(this);
		//if ( OperatorMng.getSingleton() is null )
		//	new OperatorMng();
			
		//if ( TypeMng.getSingleton() is null )
		//	new TypeMng();
			
		evolutor = new EvolutorStg();
		pops = new PopType[0];
		world = new WorldType();
		progtype = new ProgType();
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
	
	void envolveGeneration()
	{
		writeln("Entering comp...");
		foreach( ref pop; pops )
		{
			writeln("Pop init");
			CompStg.initPop( pop, world, progtype );
			
			writeln("Pop compile");
			CompStg.compilePop( pop, world, progtype);
			
			writeln("GENERATION №", pop.generation, " results:");
			CompStg.calcPopFitness( pop, world, progtype );
			pop.saveBests("saves/AntsBests_");
			pop.saveAll("saves/AntsAll_");
			
			Thread.sleep(dur!"msecs"(3000));
			pop = evolutor.formNextPopulation( pop, progtype );
			pop.generation = pop.generation + 1;
		}
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
