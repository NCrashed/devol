/**
*   Copyright: © 2012-2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>,
*             LeMarwin <lemarwin42@gmail.com>,
*             Nazgull09 <nazgull90@gmail.com>
*/
module ant.sense;

import devol.operator;
import devol.operatormng;
import devol.argument;

import devol.individ;
import devol.line;
import devol.world;

import devol.typemng;

import devol.type;
import devol.std.typepod;
import devol.std.argpod;

import ant.progtype;
import ant.world;

class OpSense : Operator
{
	TypePod!bool booltype;
	this()
	{
		booltype = cast(TypePod!bool)(TypeMng.getSingleton().getType("Typebool"));
		assert(booltype, "We need void type!");
		
		mRetType = booltype;
		super("<O>", "Sense", ArgsStyle.NULAR_STYLE);
	}
	
	override Argument apply(IndAbstract individ, Line line, WorldAbstract world)
	{
		auto ind = cast(Ant)(individ);	
		auto Wrld = cast(AntWorld)(world);	
		ind.IsFood = false;
		final switch(ind.Direction)
		{
			case ind.Faces.NORTH:
				if(ind.y<=Wrld.size-1)
					ind.IsFood = Wrld.checkForFood(ind.x,ind.y+1);
				break;
			case ind.Faces.SOUTH:
				if(ind.y>=2)
				    ind.IsFood = Wrld.checkForFood(ind.x,ind.y-1);
				break;
			case ind.Faces.EAST:
				if(ind.x<=Wrld.size-1)
				    ind.IsFood = Wrld.checkForFood(ind.x-1,ind.y);
		        break;
			case ind.Faces.WEST:
				if(ind.x>=2)
				    ind.IsFood = Wrld.checkForFood(ind.x+1,ind.y);
			    break;
		}
		ArgPod!bool ret = booltype.getNewArg();
		ret = ind.IsFood;
		return ret;
	}
}
