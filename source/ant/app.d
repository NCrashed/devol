/**
*   Copyright: © 2012-2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>,
*             LeMarwin <lemarwin42@gmail.com>,
*             Nazgull09 <nazgull90@gmail.com>
*/
module ant.app;

import std.stdio;
import std.process;
import std.exception;
import std.conv;
import std.string;
import std.concurrency;
import core.time;

import derelict.sdl2.sdl;
import derelict.sdl2.ttf;

import devol.singleton;
import devol.population;

import ant.progtype;
import ant.util;

class App: Singleton!App
{
public:
	this()
	{
		version(linux)
			DerelictSDL2.load();
		version(Windows)
			DerelictSDL2.load();
			
		writeln("Loaded derelict");
		
		enforce(SDL_Init(SDL_INIT_EVERYTHING) == 0, text("Could not initialize SDL: ", SDL_GetError()));
		writeln("SDL initilized!");
		
		/*if(TTF_Init() < 0)
		{
			writefln("Could not initialize SDL_TTF: %s.\n", SDL_GetError());
			return;
		}*/
		
		window = SDL_CreateWindow("Ant evolution!", 100, 100, 1024, 1024, SDL_WINDOW_SHOWN);
	    enforce(window !is null, "Failed to create window! ", SDL_GetError().fromStringz);
	    writeln("Window is created!");
	    
		renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
		enforce(renderer !is null, "Failed to create renderer! ", SDL_GetError().fromStringz);
		
		auto info = new SDL_RendererInfo();
		SDL_GetRendererInfo(renderer, info);
		writeln("Renderer is initialized! Information: ", info.name.fromStringz);
		
		empty = loadSurface("../media/textures/Empty.bmp");
		food = loadSurface("../media/textures/Cherry.bmp");
		wall = loadSurface("../media/textures/Wall.bmp");
		
		ants[Ant.Faces.NORTH] = loadSurface("../media/textures/AntN.bmp");
		ants[Ant.Faces.SOUTH] = loadSurface("../media/textures/AntS.bmp");
		ants[Ant.Faces.EAST] = loadSurface("../media/textures/AntE.bmp");
		ants[Ant.Faces.WEST] = loadSurface("../media/textures/AntW.bmp");
		
		SDL_RenderClear(renderer);
	}
	
	static void eventThread( Tid tid, immutable App app )
	{
		SDL_Event event;

		
		bool done = false;
		while ( !done && SDL_WaitEvent(&event) ) {
			switch (event.type) {
				case SDL_KEYDOWN:
					//done = 1;
					send(tid, true);
				break;
				default:
				
				break;
			}
		}
	}
	
	SDL_Texture* loadSurface(string name)
	{
	    SDL_Surface* bmp = SDL_LoadBMP(name.toStringz);
	    if(bmp is null)
	    {
	        enforce(false, text("Failed to load surface ", name, "! ", SDL_GetError().fromStringz));
	    }
	    
        SDL_Texture* tex = SDL_CreateTextureFromSurface(renderer, bmp);
        SDL_FreeSurface(bmp);
        if (tex is null)
        {
            enforce(false, text("Failed to create texture from surface  ", name, "! ", SDL_GetError().fromStringz));
        }
        
        return tex;
	}
	
	void clear()
	{
	    if(drawFrame) SDL_RenderClear(renderer);
	}
	
    void draw(SDL_Texture* tex, uint x, uint y, uint w, uint h)
    {
        if(drawFrame)
            SDL_RenderCopy(renderer, tex, null, new SDL_Rect(x, y, w, h));
        
    }
    
    void present()
    {
        drawFrame = !drawFrame; 
        SDL_RenderPresent(renderer);
    }
    
	~this()
	{
	    SDL_DestroyTexture(empty);
	    SDL_DestroyTexture(food);
	    SDL_DestroyTexture(wall);
	    foreach(tex; ants)
	    {
	        SDL_DestroyTexture(tex);
	    }
	    
		SDL_DestroyRenderer(renderer);
        SDL_DestroyWindow(window);
        SDL_Quit();
    }
	
	SDL_Texture* empty;
	SDL_Texture* food;
	SDL_Texture* wall;
	SDL_Texture*[Ant.Faces] ants;
	SDL_Texture* screen;
	
    private
    {
        SDL_Window* window;
        SDL_Renderer* renderer;
        SDL_Event event;
        bool drawFrame = true;
	}
}


