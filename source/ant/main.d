/**
*   Copyright: © 2012-2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>,
*             LeMarwin <lemarwin42@gmail.com>,
*             Nazgull09 <nazgull90@gmail.com>
*/
module main;

import std.stdio;
import std.process;
import std.conv;
import core.time, core.thread;

import devol.compiler;

import ant.progtype;
import ant.world;
import ant.app;

import derelict.sdl2.sdl;

alias Population!( getDefChars, Ant ) AntPopulation;

alias 	GameCompilation!(
    
	function bool(ref int x, ind, world) // stopCond
	{
		auto ai = cast(Ant)(ind);
		auto aw = cast(AntWorld)(world);
		
		if (ai.prevFoodCount < ai.FoodCount)
			x = 0;
		ai.prevFoodCount = ai.FoodCount;
		return x > 5 || aw.Food <= ai.FoodCount;
	},
	
	function void(ind, world) // draw step
	{
		auto ai = cast(Ant)(ind);
		auto aw = cast(AntWorld)(world);
		auto app = App.getSingleton();
		
		version(linux)
			system("clear");
		version(Windows)
			system("cls");
		
		app.clear();	
			
		foreach(uint j,ref l; aw.getMap() )
		{
			foreach(uint i,ref c; l)
			{
				if ( j == ai.x && i == ai.y )
				{
				    app.draw(app.ants[ai.Direction], (j+1)*32u, (i+1)*32u, 32u, 32u);
				}
				else if (c)
					app.draw(app.food, (j+1)*32u , (i+1)*32u, 32u, 32u);
				else
					app.draw(app.empty, (j+1)*32u , (i+1)*32u, 32u, 32u);
			}
		}
		
		foreach( i; 0..aw.size+2)
			app.draw(app.wall, i*32u, 0, 32u, 32u);
		foreach( i; 0..aw.size+2)
			app.draw(app.wall, i*32u, (aw.size+1)*32u, 32u, 32u);
		foreach( i; 0..aw.size+2)
			app.draw(app.wall, 0, i*32u, 32u, 32u);				
		foreach( i; 0..aw.size+2)
			app.draw(app.wall, (aw.size+1)*32u, i*32u, 32u, 32u);	
		
		app.present();									
	},
	function void(pop, world) // draw final
	{
		auto ap = cast(AntPopulation)(pop);
		auto aw = cast(AntWorld)(world);			
	},
	1
)MyCompilaton;

alias Compiler!(
	MyCompilaton,
	Evolutor, 
	AntProgType, 
	AntPopulation, 
	AntWorld) 
AntCompiler;

void main(char[][] args)
{
	auto app = new App;
	scope(exit) destroy(app);
	
    auto comp = new AntCompiler;
    auto tmng = TypeMng.getSingleton();
    auto opmng = OperatorMng.getSingleton();
    
    writeln("testing population");
    auto pop = comp.addPop(30);
    
    while(!app.shouldExit) {comp.envolveGeneration(() => app.shouldExit);}
}
