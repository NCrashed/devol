/**
*   Copyright: © 2012-2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>,
*             LeMarwin <lemarwin42@gmail.com>,
*             Nazgull09 <nazgull90@gmail.com>
*/
module ant.progtype;

import std.stdio;

import devol.programtype;
import devol.world;
import devol.individ;
import devol.std.line;

import devol.typemng;
import devol.std.typepod;
import devol.std.plus;
import devol.std.opif;
import devol.operatormng;

import ant.world;
import ant.sense;
import ant.operators;

import dyaml.all;

class AntProgType : ProgTypeAbstract
{
	this()
	{
		auto tmng = TypeMng.getSingleton();
		auto omng = OperatorMng.getSingleton();
		
		tmng.registerType!TypeBool();
		tmng.registerType!TypeInt();
		
		omng.registerOperator!If();
		omng.registerOperator!Plus();
		omng.registerOperator!OpSense();
		omng.registerOperator!GoForward();
		omng.registerOperator!TurnLeft();
		omng.registerOperator!TurnRight();
	}
	
	@property uint progMinSize()
	{
		return 4;
	}
	
	@property uint progMaxSize()
	{
		return 8;
	}
	
	@property float newOpGenChance()
	{
		return 0.3;
	}
	
	@property float newScopeGenChance()
	{
		return 0.1;
	}
	
	@property float newLeafGenChance()
	{
		return 0.6;
	}
	
	@property uint scopeMinSize()
	{
		return 2;
	}
	
	@property uint scopeMaxSize()
	{
		return 5;
	}
	
	@property float mutationChance()
	{
		return 0.3;
	}
	
	@property float crossingoverChance()
	{
		return 0.7;
	}
	
	@property float mutationChangeChance()
	{
		return 0.5;
	}
	
	@property float mutationReplaceChance()
	{
		return 0.3;
	}
	
	@property float mutationDeleteChance()
	{
		return 0.2;
	}
	
	@property float mutationAddLineChance()
	{
		return 0.1;
	}
	
	@property float mutationRemoveLineChance()
	{
		return 0.05;
	}
	
	@property string maxMutationChange()
	{
		return "100";
	}
	
	@property float copyingPart()
	{
		return 0.1;
	}
	
	size_t deleteMutationRiseGenomeSize()
	{
	    return 5;
	}
	
	size_t maxGenomeSize()
	{
	    return 10;
	}
	
	Line[] initValues(WorldAbstract pWorld)
	{
		return new Line[0];
	}
		
	double getFitness(IndAbstract pInd, WorldAbstract pWorld, double time)
	{
		return (cast(Ant)(pInd)).FoodCount;
	}
}

alias bool delegate() Cheat;
class Ant : Individ
{
	this()
	{
		x = AntWorld.size/2;
		y = AntWorld.size/2;
		Direction = Faces.EAST;
		FoodCount = 0;
	}
	
	this(Individ ind)
	{
	    this();
	    loadFrom(ind);
	}
	
	int x,y; 			//Ant's position;
	enum Faces			//What direction is it looking
	{
		NORTH,
		SOUTH,
		EAST,
		WEST
	};
	override void initialize(WorldAbstract world)
	{
		x = AntWorld.size/2;
		y = AntWorld.size/2;
	}
	Faces Direction;
	bool IsFood;
	int FoodCount;
	int prevFoodCount;
	
	Cheat MyCheat = null;
	void addCheat(Cheat a)
	{
		MyCheat = a;
	}
	bool isCheater() { return MyCheat != null; }
		
	override @property Ant dup()
	{
		auto ind = new Ant();
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
	
	static Ant loadYaml(Node node)
	{
	    auto ind = Individ.loadYaml(node);
	    auto ant = new Ant();
	    
        foreach(line; ind.program)
            ant.mProgram ~= line.dup;
        foreach(line; ind.memory)
            ant.mMemory ~= line.dup;    
        foreach(line; ind.invals)
            ant.inVals ~= line.dup;     
        foreach(line; ind.outvals)
            ant.outVals ~= line.dup;    
        
        return ant;
	} 
}
