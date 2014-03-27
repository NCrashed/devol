/**
*   Copyright: © 2012-2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>,
*             LeMarwin <lemarwin42@gmail.com>,
*             Nazgull09 <nazgull90@gmail.com>
*/
module ant.world;

import devol.world;
import ant.progtype;
import ant.operators;
import core.thread;
import core.time;

import std.random;
import std.stdio;
import std.process;
import ant.app;

import derelict.sdl2.sdl;

class AntWorld: WorldAbstract
{
	void initialize()
	{	
		zeros();
		generateMap();
		print();
	}	
	static immutable int size = 18;	
	static int Food=25;
	
	const bool[size][size] getMap()
	{
		return map;
	}
	
	private:
	
	bool[size][size] map;
	
	public:
	

	bool checkForFood(int x, int y)
	{
		if (x>=size || y>=size) return false;
		
		return map[x][y];
	}
	void removeFood(int x, int y)
	{
		map[x][y]=false;
	}
	
	void generateMap()
	{
		writeln("Generating map");
		Ant Grower = new Ant;
		
		Grower.x = size/2+uniform!"[]"(-1,1);
		Grower.y = size/2+uniform!"[]"(-1,1);
		
		Grower.Direction = cast(Ant.Faces)uniform!"[]"(cast(uint)Ant.Faces.min, cast(uint)Ant.Faces.max);
		
		int FC = 1;
		int breakCount = 0;
		
		writeln("Adding delegate");
		Grower.addCheat(delegate bool ()
		{
			final switch(Grower.Direction)
			{
			case Grower.Faces.NORTH:
				if(Grower.y>=2)
				return checkForFood(Grower.x,Grower.y-2)||checkForFood(Grower.x,Grower.y-1)
						||checkForFood(Grower.x-1,Grower.y-2)||checkForFood(Grower.x-1,Grower.y-1)
						||checkForFood(Grower.x+1,Grower.y-2)||checkForFood(Grower.x+1,Grower.y-1);
				break;
			case Grower.Faces.SOUTH:
				if(Grower.y<=size-2)
				return checkForFood(Grower.x,Grower.y+2)||checkForFood(Grower.x,Grower.y+1)
						||checkForFood(Grower.x-1,Grower.y+2)||checkForFood(Grower.x-1,Grower.y+1)
						||checkForFood(Grower.x+1,Grower.y+2)||checkForFood(Grower.x+1,Grower.y+1);
				break;
			case Grower.Faces.EAST:
				if(Grower.x<=size-2)
				return checkForFood(Grower.x+2,Grower.y)||checkForFood(Grower.x+1,Grower.y)
						||checkForFood(Grower.x+2,Grower.y-1)||checkForFood(Grower.x+1,Grower.y-1)
						||checkForFood(Grower.x+2,Grower.y+1)||checkForFood(Grower.x+1,Grower.y+1);
				break;
			case Grower.Faces.WEST:
				if(Grower.x>=2)
				return checkForFood(Grower.x-2,Grower.y)||checkForFood(Grower.x-1,Grower.y)
						||checkForFood(Grower.x-2,Grower.y-1)||checkForFood(Grower.x-1,Grower.y-1)
						||checkForFood(Grower.x-2,Grower.y+1)||checkForFood(Grower.x-1,Grower.y+1);
				break;
			}
			return false;
		});
		writeln("Placing food");
		auto flag = true;
		while(FC!=Food && breakCount < 100)
		{
			writeln("FC = ", FC);
			writeln("Food = ", Food);
			int c = uniform!"[]"(0,1);
			GoForward F = new GoForward;
			TurnLeft L = new TurnLeft;
			TurnRight R = new TurnRight;
			writeln("Choosing direction");
			if(c&&!Grower.MyCheat())
			{
				writeln("Forward");
				F.apply(Grower, null, this);
				
				int d = uniform!"[]"(0,1);
				writeln("Chance to place food: ", d);
				if ( Grower.x >= 1 && Grower.y  >= 1 && Grower.x <= size-1 && Grower.y <= size - 1 )
				{
    				if((d||flag)&&!map[Grower.x][Grower.y])
    				{
    					writeln("Placing food");
    					map[Grower.x][Grower.y] = true;
    					FC++;
    					flag = false;
    				}
    				else
    				{
    					flag = true;
    				}
				}
			}
			else
			{
				writeln("Rotating");
				breakCount++;
				int d = uniform!"[]"(0,1);
				if(d)
				{
					writeln("Left");
					L.apply(Grower, null, this);
				}
				else
				{
					writeln("Right");
					R.apply(Grower,null,this);
				}
			}
			

			
			void printGr()
			{
				writeln("Getting singleton");
				auto app = App.getSingleton();
				assert(app !is null);
				
				app.clear();
				draw(app, app.food, app.empty, app.wall);
				app.draw(app.ants[Grower.Direction], 32u*(Grower.x+1), 32u*(Grower.y+1), 32u, 32u);
				app.present();
			}
			
			printGr();
		}
	}
		void zeros()
		{
			foreach(ref line; map)
			{
				foreach(ref cell; line)
				{
					cell = false;
				}
			}
		}
	
	void print()
	{
		version(linux)
		{
			system("clear");
		}
		foreach( l; map )
		{
			foreach( c; l)
			{
				if (c)
					write("x");
				else
					write("-");
			}
			writeln();
		}
	}
	
	void draw(App app, SDL_Texture* food, SDL_Texture* empty, SDL_Texture* wall)
	{
		assert(food !is null);
		assert(empty !is null);
		
		foreach(uint j, l; map )
		{
			foreach(uint i, c; l)
			{
				if (c)
				{
					//writeln("drawing food at ", (j+1)*32u, " ", (i+1)*32u);
					app.draw(food, (j+1)*32u , (i+1)*32u, 32u, 32u);
				}
				else
				{	
					//writeln("drawing empty at ", (j+1)*32u, " ", (i+1)*32u);
					app.draw(empty, (j+1)*32u , (i+1)*32u, 32u, 32u);
				}
			}
		}		
		
		foreach(uint i; 0..map.length+2)
			app.draw(wall, i*32u, 0, 32u, 32u);
		foreach(uint i; 0..map.length+2)
			app.draw(wall, i*32u, (cast(uint)map.length+1)*32u, 32u, 32u);
		foreach(uint i; 0..map.length+2)
			app.draw(wall, 0, i*32u, 32u, 32u);				
		foreach(uint i; 0..map.length+2)
			app.draw(wall, (cast(uint)map.length+1)*32u, i*32u, 32u, 32u);	
	}
	
	}

