/**
*   Copyright: © 2012-2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>,
*             LeMarwin <lemarwin42@gmail.com>,
*             Nazgull09 <nazgull90@gmail.com>
*/
module devol.type;

import std.array;
import devol.serializable;
import devol.typemng;

import dyaml.all;    

public
{
	import devol.argument;
}

alias Argument delegate(Argument val) ConvertorFunc;
 
class ConvAddException : Exception
{
	this(string s, ConvertorFunc conv, Type type)
	{
		super(s);
		eConv = conv;
		eType = type;
	}
	
	ConvertorFunc eConv;
	Type eType;
}

class ConvException : Exception
{
	this( string s, Type from, Type to)
	{
		super(s);
		eFrom = from;
		eTo = to;
	}

	Type eFrom;
	Type eTo;
}

abstract class Type : ISerializable
{
	this(string name)
	{
		sName = name;
	}
	
	@property string name()
	{
		return sName;
	}
	
	Argument getNewArg()
	{
		throw new Exception("Pure type isn't allowed to generate args!");
	}
	
	Argument getNewArg(string min, string max, string[] exVal)
	{
		throw new Exception("Pure type isn't allowed to generate args!");
	}
	
	void registerConvertor( ConvertorFunc func, Type toType )
	{
		if (toType is null) return;
		
		if (toType in convs)
		{
			throw new ConvAddException("Convertor already exists!", convs[toType], toType);
		}
		
		convs[toType] = func;
	}
	
	Argument convert(Argument val)
	{
		Type type = val.type;
		
		if(type.name == name ) return val;
		
		if (this in type.convs)
		{
			return type.convs[this](val);
		}
		
		auto chain = findConvWay(type);
		if (chain.empty)
		{
			throw new ConvException("Types uncovertable!", type, this);
		}
		
		foreach(conv; chain)
		{
			val = conv(val);
		}
		return val;
	}
	
	bool isConvertable(Type from)
	{
		if (from.name == name ) return true;
		
		if (this in from.convs)
		{
			return true;
		}
		
		auto chain = findConvWay(from);		
		return !chain.empty;
	}
	
	private ConvertorFunc[] findConvWay(Type from)
	{
		class Node
		{
			Node parent;
			Type type;
			ConvertorFunc func;
		}
		
		Node[] stack = new Node[0];
		Type[] blackList = new Type[0];
		
		Node prevNode = new Node;
		prevNode.parent = null;
		prevNode.func = null;
		bool finded = false;
		
		finddo: do
		{
			blackList ~= from;
			foreach(type,conv; from.convs)
			{
				Node node = new Node;
				node.parent = prevNode;
				node.func = conv;
				
				bool isInBL(Type t, Type[] bl)
				{
					foreach( type; bl)
						if (t == type)
							return true;
					return false;
				}
				
				if (!isInBL(type, blackList))
					stack ~= node;
				
				if (type == this)
				{
					finded = true;
					break finddo;
				}
			}
			
			if (!stack.empty)
			{
				prevNode = stack[0];
				from = prevNode.type;
				stack = stack[1..$];
			}
			
		} while(!stack.empty);
		
		auto chain = new ConvertorFunc[0];
		if (!finded)
			return chain;
			
		auto node = stack[$-1];
		while(node.parent !is null)
		{
			chain = node.func ~ chain;
			node = node.parent;
		}
		return chain;
	}
	
	static Type loadBinary(InputStream stream)
	{
	    char[] typename;
	    stream.read(typename);
	    
	    return TypeMng.getSingleton().getType(typename.idup);
	}
	
	static Type loadYaml(Node node)
	{
	    return TypeMng.getSingleton().getType(node.as!string);
	}
	
	/// Loading argument from input stream
	/**
	*  Should be defined by all childs.
	*/
	Argument loadArgument(InputStream stream);
	
	/// Loading argument from input stream
    /**
    *  Should be defined by all childs.
    */
	Argument loadArgument(Node node);
	
	void saveBinary(OutputStream stream)
	{
        stream.write(sName);
	}
	
	Node saveYaml()
	{
	    return Node(sName);
	}
	
	private ConvertorFunc[Type] convs;
	private string sName;
}
