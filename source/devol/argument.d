/**
*   Copyright: © 2012-2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>,
*             LeMarwin <lemarwin42@gmail.com>,
*             Nazgull09 <nazgull90@gmail.com>
*/
module devol.argument;

import devol.type;
import devol.serializable;
import std.array;
import std.conv;

import dyaml.all;

import devol.std.line;
import devol.std.argscope;

abstract class Argument : ISerializable
{
	this(Type type)
	{
		pType = type;
	}
	
	@property Type type()
	{
		assert(pType);
		return pType;
	}
	
	@property string tostring(uint depth=0)
	{
		return "";
	}
	
	@property ulong children()
	{
		return 1;
	}
	
	@property ulong leafs()
	{
		return 1;
	}
	
	private Type pType; 
	
	Node saveYaml();
	
	static Argument loadYaml(Type type, Node node)
	{
	    switch(node["class"].as!string)
	    {
            case("line"):
            {
                return Line.loadYaml(node);
            }
            case("scope"):
            {
                return ArgScope.loadYaml(node);
            }
            case("plain"):
            {
                return type.loadArgument(node);
            } 
            default:
            {
                assert(false, "Failed to load! Unknown label!");
            }
	    }
	}
	
	string genDot(ref size_t nameIndex, out string nodeName)
	{
		auto builder = appender!string;
		nodeName = "n"~to!string(nameIndex++);
		builder.put(nodeName);
		builder.put("; \n");
		
		builder.put(nodeName);
		builder.put("[label=\"");
		builder.put(tostring(0));
		builder.put("\"] ;\n");
		
		return builder.data;
	}
	
	void randomChange();
	void randomChange(string maxChange);
	@property Argument dup();
}
