/**
*   Copyright: © 2012-2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>,
*             LeMarwin <lemarwin42@gmail.com>,
*             Nazgull09 <nazgull90@gmail.com>
*/
module ant.operators;

import std.stdio;

import ant.world;
import ant.progtype;
import devol.operator;
import devol.operatormng;
import devol.argument;

import devol.individ;
import devol.std.line;
import devol.world;

import devol.typemng;

import devol.type;
import devol.std.typevoid;
import std.process;

class GoForward : Operator
{
	Type voidtype;
	this()
	{
		voidtype = TypeMng.getSingleton().getType("TypeVoid");
		mRetType = voidtype;
		super("FORWARD","Moves ant 1 step forward", ArgsStyle.NULAR_STYLE);
	}
	
	override Argument apply(IndAbstract individ, Line line, WorldAbstract world)
	{
		//writeln("Appling GoForward");
		auto ind = cast(Ant)(individ);	
		auto Wrld = cast(AntWorld)(world);
		//writeln("Casting success: ", ind !is null, " " ,Wrld !is null);	
		final switch(ind.Direction)
		{
			case ind.Faces.SOUTH:
				if(ind.y<Wrld.size-1)
					ind.y+=1;
				break;
			case ind.Faces.NORTH:
				if(ind.y>1)
					ind.y-=1;
				break;
			case ind.Faces.WEST:
				if(ind.x>1)
					ind.x-=1;
				break;
			case ind.Faces.EAST:
				if(ind.x<Wrld.size-1)
					ind.x+=1;
				break;
		}
		//writeln("checking food");
		if(Wrld.checkForFood(ind.x, ind.y) && !ind.isCheater())
			{
				//writeln("eating");
				ind.FoodCount++;
				Wrld.removeFood(ind.x,ind.y);
			}
		//writeln("return");
		return voidtype.getNewArg();
	}
}

class TurnLeft : Operator
{
	Type voidtype;
	this()
	{
		voidtype = TypeMng.getSingleton().getType("TypeVoid");
		mRetType = voidtype;
		super("LEFT", "Ant turns counterclockwise", ArgsStyle.NULAR_STYLE);
	}
	
	override Argument apply(IndAbstract individ, Line line, WorldAbstract world)
	{
		//writeln("Appling TurnLeft");
		auto ind = cast(Ant)(individ);
		//writeln("Casting success: ", ind !is null);
		final switch(ind.Direction)
		{
			case ind.Faces.NORTH:
				ind.Direction = ind.Faces.WEST;
				break;
			case ind.Faces.SOUTH:
				ind.Direction = ind.Faces.EAST;
				break;
			case ind.Faces.EAST:
				ind.Direction = ind.Faces.NORTH;
				break;
			case ind.Faces.WEST:
				ind.Direction = ind.Faces.SOUTH;
				break;
		}
		return voidtype.getNewArg();
	}
}

class TurnRight : Operator
{
	Type voidtype;
	this()
	{
		voidtype = TypeMng.getSingleton().getType("TypeVoid");
		mRetType = voidtype;
		super("RIGHT", "Ant turns clockwise", ArgsStyle.NULAR_STYLE);
	}
	
	override Argument apply(IndAbstract individ, Line line, WorldAbstract world)
	{
		//writeln("Appling TurnRight");
		auto ind = cast(Ant)(individ);
		//writeln("Casting success: ", ind !is null);
		final switch(ind.Direction)
		{
			case ind.Faces.NORTH:
				ind.Direction = ind.Faces.EAST;
				break;
			case ind.Faces.SOUTH:
				ind.Direction = ind.Faces.WEST;
				break;
			case ind.Faces.EAST:
				ind.Direction = ind.Faces.SOUTH;
				break;
			case ind.Faces.WEST:
				ind.Direction = ind.Faces.NORTH;
				break;
		}
		return voidtype.getNewArg();
	}
}




