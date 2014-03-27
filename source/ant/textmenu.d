/**
*   Copyright: © 2012-2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>,
*             LeMarwin <lemarwin42@gmail.com>,
*             Nazgull09 <nazgull90@gmail.com>
*/
module ant.textmenu;

import std.variant;
import std.process;
import std.stdio;

alias Variant delegate(Menu self, Variant[] args...) MenuMethod;

class Menu
{
	
	private MenuMethod[string] 	methods;
	private string[]	   		indexMethods;
		
	this()
	{
		indexMethods = new string[0];
	}
	
	void addMethod(string name, MenuMethod m)
	{
		methods[name] = m;
		indexMethods  ~= name;
	}
	
	void removeMethod(string name)
	{
		foreach( i,m; indexMethods )
		{
			if ( m == name )
				indexMethods = indexMethods[0..i] ~
					indexMethods[i+1..$];
		}
		methods.remove(name);
	}
	
	Variant call(string methodName, Variant[] args...)
	{
		version(Windows) 	{ system("cls"); }
		version(linux)		{ system("clear"); }
		return methods[methodName](this,args);
	}
	
	Variant call(uint index, Variant[] args...)
	{
		version(Windows) 	{ system("cls"); }
		version(linux)		{ system("clear"); }	
		return methods[indexMethods[index-1]](this,args);	
	}
	
	Variant opDispatch(string m, Args...)(Args args)
	{
		Variant[] packedArgs = new Variant[args.length];
		foreach(i,arg;args)
		{
			packedArgs[i] = Variant(arg);
		}
		return call(m,packedArgs);
	}
	
	void printMenu()
	{
		version(Windows) 	{ system("cls"); }
		version(linux)		{ system("clear"); }
		auto i = 1;
		foreach(v;indexMethods)
		{
			writeln(i++,".",v);
		}
	}
}
	
	
	/*menu.addMethod("Exit", 
		delegate Variant(Menu, Variant[]...) 
		{
			writeln("Exiting...");
			exit = true;
			return Variant();
		}
	);
	
	menu.addMethod("Types",
		delegate Variant(Menu, Variant[]...)
		{
			writeln("Registered types:");
			foreach( s; tmng.strings )
			{
				writeln(s);
			}
			return Variant();
		});
		
	menu.addMethod("Operators",
		delegate Variant(Menu, Variant[]...)
		{
			writeln("Registered operators:");
			foreach( s; opmng.strings )
			{
				writeln(s);
			}
			return Variant();
		});

	menu.addMethod("AddPopulation",
		delegate Variant(Menu, Variant[]...)
		{
			comp.addPop(10);
			return Variant();
		});
	
	menu.addMethod("PrintPopulation",
		delegate Variant(Menu, Variant[]...)
		{
			auto pop = comp.getPop(0);
			
			version(Windows)
			{
				uint num = 1;
				foreach(ind; pop)
				{
					writeln("Individ №",num++," length ", ind.program.length);
					writeln(ind.programString);
				}
			}		
			version(linux)
			{
				auto buff = File("tmp.txt", "w");
				uint num = 1;
				foreach(ind; pop)
				{
					buff.writeln("Individ №",num++," length ", ind.program.length);
					buff.writeln(ind.programString);
				}
				system("less tmp.txt");
			}
			
			return Variant();
		});
	
	menu.addMethod( "CompilePopulation",
		delegate Variant(Menu, Variant[]...)
		{
			writeln("Compiling...");
			comp.envolveGeneration();
			writeln("Done.");
			return Variant();
		});
		
	//===========================================================	
	while(!exit)
	{
		menu.printMenu();
		uint ch = 0;
		
		do
		{
			write("Choice: ");
			auto input = readln();
			
			try
			{
				ch = parse!uint(input);
			} catch(Exception e)
			{
				writeln("Enter valid number!");
			} 
		} while( ch <= 0 );
		menu.call( ch );
		writeln("Put char to return...");
		getchar();
	}*/
