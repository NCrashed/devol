/**
*   Copyright: © 2012-2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>,
*             LeMarwin <lemarwin42@gmail.com>,
*             Nazgull09 <nazgull90@gmail.com>
*/
module devol.std.line;

import std.stdio;
import std.array;
import std.conv;
import std.random;
import std.algorithm;

import devol.typemng;
import devol.serializable;

import dyaml.all;    

public
{
	import devol.operator;
	import devol.individ;
	import devol.world;
	
	import devol.std.container;
	import devol.std.random;
}

class Line : Container, ISerializable
{
	this()
	{
		super(TypeMng.getSingleton().getType("TypeLine"));
	}
	
	@property Operator operator()
	{
		return pOp;
	}
	
	override void randomChange()
	{
		
	}
	
	override void randomChange(string maxChange)
	{
		
	}

	override Argument getRandomElement()
	{
		return args[ uniform(0, args.length) ];
	}
	
	override Argument getRandomElement(double[] chances)
	{
		Argument ret;
		randomRange!((int k){ret = args[k];})(chances[0..args.length]);
		return ret;
	}
	
	override void replaceRandomElement(Argument narg)
	{
		args[ uniform(0, args.length) ] = narg;
	}
	
	override void replaceRandomElement(double[] chances, Argument narg)
	{
		randomRange!((int k){args[k] = narg;})(chances[0..args.length]);
	}
	
	override void replaceRandomElement(Argument delegate(Type t) del)
	{
		auto i = uniform(0, args.length);
		args[ i ] = del( args[i].type );
	}
	
	override void replaceRandomElement(Argument delegate(Type t) del, double[] chances)
	{
		randomRange!((int k){args[k] = del(args[k].type);})(chances[0..args.length]);
	}
	
	override Argument getRandomLeaf()
	{
		auto temp =  new Argument[0];
		foreach(arg; args)
			if (cast(Container)arg is null)
				temp ~= arg;
		
		return temp[ uniform(0, temp.length) ];
	}
	
	override Argument getRandomLeaf(double[] chances)
	{
		auto temp =  new Argument[0];
		foreach(arg; args)
			if (cast(Container)arg is null)
				temp ~= arg;
		
		Argument ret;
		randomRange!((int k){ret = temp[k];})(chances[0..temp.length]);	
		return ret;
	}
	
	override uint getLeafCount()
	{
		auto temp =  new Argument[0];
		foreach(arg; args)
			if (cast(Container)arg is null)
				temp ~= arg;		
		return cast(uint)temp.length;
	}
	
	override void addElement(Argument arg)
	{
		if (args.length < pOp.argsNumber)
		{
			assert(arg.type == pOp[cast(int)args.length].type, "Argument type isn't coresponed operator argument type!");
			args ~= arg;
		}
	}
	
	override void removeElement(size_t i)
	{
		if ( i > 0 && i < args.length )
			args.remove(i);
	}
	
	override void removeAll()
	{
		args.clear();
	}
	
	@property void operator(Operator op)
	{
		if (op is null)
		{
			clear();
			return;
		}
		
		args = new Argument[op.argsNumber];
		
		foreach(uint i,ref arg; args)
		{
			arg = op.generateArg(i);
		}
		
		pOp = op;
	}
	
	override @property string tostring(uint depth=0)
	{
		final switch(pOp.style)
		{
			case ArgsStyle.CLASSIC_STYLE:
				return formClassic(depth);
			case ArgsStyle.MASS_STYLE:
				return formMass(depth);
			case ArgsStyle.UNAR_STYLE:
				return formUnar(depth);
			case ArgsStyle.BINAR_STYLE:
				return formBinar(depth);
			case ArgsStyle.NULAR_STYLE:
				return formNular(depth);
			case ArgsStyle.CONTROL_STYLE:
				return formControl(depth);
		}
	}
	
	void clear()
	{
		pOp = null;
		args = null;
	}
	
	bool isSubline( size_t i )
	{
		if ( i >= args.length ) return false;
		
		return cast(Line)(args[i]) !is null;
	}
	
	Line getSubline( size_t i )
	{
		if ( i >= args.length ) return null;
		
		return cast(Line)(args[i]);
	}
	
	bool isScope( size_t i)
	{
		if ( i >= args.length ) return false;
		
		return cast(ArgScope)(args[i]) !is null;
	}
	
	ArgScope getScope( size_t i )
	{
		if ( i >= args.length ) return null;
		
		return cast(ArgScope)(args[i]);
	}
	
	Argument compile(IndAbstract ind, WorldAbstract world)
	{
		//writeln("Compling line");
		Line dline = this.dup;
		for( int i=0; i < dline.length; i++)
		{
			//writeln("Compiling arg ", i);
			if ( pOp.style != ArgsStyle.CONTROL_STYLE || i==0 )
			{
				auto ascope = dline.getScope(i);
				if (ascope !is null)
				{
					foreach(Line l; ascope )
					{
						(cast(Line)(l)).compile(ind,world);
					}
					dline[i] = pOp[i].type.getNewArg();
				}
				else
				{
					Line aline = dline.getSubline(i);
					if (aline !is null)
						dline[i] = aline.compile(ind, world);
					else
					{
						//writeln("Search convertors for ", dline[i].type.name, " and ", dline.operator[i].type.name);
						if (dline[i].type.name != dline.operator[i].type.name)
						{
							Argument convarg = dline.operator[i].type.convert( dline[1] );
							if (convarg is null)
								throw new Exception("Compilation error! Types not convertable:"
									~dline[i].type.name ~" and "~ dline.operator[i].type.name~"!");
							dline[i] = convarg;
						}
					}
				}
			}
		}
		assert(pOp);
		//writeln("Applying op ", pOp.name);
		return pOp.apply(ind, dline, world);		
	}
	
	override @property Line dup()
	{
		Line nline = new Line();
		nline.pOp = pOp;
		nline.args = new Argument[args.length];
		foreach( i,arg; args)
		{
			nline.args[i] = arg.dup;
		}

		return nline;
	}
	
	override Argument opIndex( size_t i )
	{
		return args[i];
	}
	
	override void opIndexAssign( Argument val, size_t i )
	{
		if (i >= args.length) return;
		args[i] = val;
	}
	
	override Argument[] opSlice( size_t a, size_t b )
	{
		return args[a..b];
	}
	
	override size_t opDollar()
	{
		return args.length;
	}
	
	override @property size_t length()
	{
		return args.length;
	}
	
	override @property ulong children()
	{
		ulong length = 1;
		foreach(arg; args)
			length += arg.children;
		return length;
	}
	
	override @property ulong leafs()
	{
	    if(args.length == 0) return 1;
	    
		ulong length = 0;
		foreach(arg; args)
			length += arg.leafs;
		return length;
	}
	
	@property bool empty()
	{
		return args.empty;
	}
	
	override int opApply(int delegate(Argument) dg)
	{
		int result = 0;
		
		foreach( i,arg; args)
		{
			result = dg(arg);
			if (result) break;
		}
		return result;
	}
	
	int opApply(int delegate(int, ref Argument) dg)
	{
		int result = 0;
		
		foreach( int i, ref arg; args)
		{
			result = dg(i,arg);
			if (result) break;
		}
		return result;
	}
	
	@property Argument front()
	{
		return args.front;
	}
	
	@property Argument back()
	{
		return args.back;
	}
	
	private static string getTabs(uint c)
	{
		if (c==0) return "";
		
		auto buff = new char[c];
		foreach( ref cc; buff)
			cc = to!char(0x09);
		return buff.idup;
	}
	
	string formClassic(uint depth=0)
	{
		string s = getTabs(depth) ~ pOp.name ~ "(";
		
		foreach(i,arg; args)
		{
			s ~= arg.tostring;
			if (i != args.length-1)
				s~= " , ";
		}
		return s ~ ")";
	}
	
	string formMass(uint depth=0)
	{
		string s = getTabs(depth) ~ pOp.name ~ "[";
		
		foreach(i,arg; args)
		{
			s ~= arg.tostring;
			if (i != args.length-1)
				s~= " , ";
		}
		return s ~ "]";		
	}
	
	string formBinar(uint depth=0)
	{
		if (args.length != 2) 
			return "(Invalid args count "~to!string(args.length)~" )";
		
		return getTabs(depth) ~ "("~args[0].tostring ~ " " ~ pOp.name ~ " "
			~ args[1].tostring ~ ")";
	}
	
	string formUnar(uint depth=0)
	{
		if (args.length != 1) 
			return "(Invalid args count)";
		
		return getTabs(depth) ~ pOp.name ~ args[0].tostring;
	}
	
	string formNular(uint depth=0)
	{
		if(args.length != 0)
			return "(Invalid args count)";
		
		return getTabs(depth) ~ pOp.name;
	}
	
	string formControl(uint depth=0)
	{
		if (args.length < 1) 
			return "(Invalid args count)";
		
		string ret = getTabs(depth) ~ pOp.name ~ "(" ~ args[0].tostring ~ ")\n";
		foreach(arg; args[1..$])
		{
			ret ~= getTabs(depth) ~ "{\n";
			ret ~= arg.tostring(depth+1)~ "\n";
			ret ~= getTabs(depth) ~ "}\n";
		}
		return ret;
	}
	
	static Line loadBinary(InputStream stream)
	{
	    auto line = new Line();
	    
	    line.pOp = Operator.loadBinary(stream);
	    
	    ulong argsLength;
	    auto builder = appender!(Argument[]);
	    
	    foreach(i; 0..cast(size_t)argsLength)
	    {
	        char[] mark;
	        stream.read(mark);
	        
	        if(mark == "line")
	        {
	            builder.put(Line.loadBinary(stream));
	        } else if(mark == "scope")
	        {
	            builder.put(ArgScope.loadBinary(stream));
	        } else if(mark == "plain")
	        {
	            auto type = line.pOp[i].type; 
	            builder.put(type.loadArgument(stream));
	        } else
	        {
	            assert(false, "Failed to load! Unknown label!");
	        }
	    }
	    line.args = builder.data;
	    
	    return line;
	}
	
	static Line loadYaml(Node node)
	{
	    auto ret = new Line;
	    ret.pOp = Operator.loadYaml(node["operator"]);
	    
	    auto builder = appender!(Argument[]); 
	    if(node.containsKey("arguments"))
	    {
	        size_t i = 0;
    	    foreach(Node subnode; node["arguments"])
    	    {
    	        builder.put(Argument.loadYaml(ret.pOp[i++].type, subnode));
    	    }
	    }
	    ret.args = builder.data;
	    
	    return ret;
	}
	
	void saveBinary(OutputStream stream)
	{
	    stream.write("line");
	    
	    pOp.saveBinary(stream);
	    stream.write(cast(ulong)args.length);
	    foreach(arg; args)
	    {
	        if(cast(Line)arg is null && cast(ArgScope)arg is null)
	        {
	            stream.write("plain");
            }
	        arg.saveBinary(stream);
	    }
	}
	
	override Node saveYaml()
	{
	    auto builder = appender!(Node[]);
	    
	    foreach(arg; args)
	    {
	        builder.put(arg.saveYaml);
	    }
	    
	    auto map = [
            "class": Node("line"),
            "operator": pOp.saveYaml,
            ];
            
        if(builder.data.length > 0)
        {
            map["arguments"] = Node(builder.data);
        }
        
        return Node(map);
	}
	
	override string genDot(ref size_t nameIndex, out string nodeName)
	{
		auto builder = appender!string;
		
		builder.put(pOp.genDot(nameIndex, nodeName));
		
		foreach(arg; args)
		{
			string argNode;
			builder.put(arg.genDot(nameIndex, argNode));
			
			builder.put(nodeName);
			builder.put(" -> ");
			builder.put(argNode);
			builder.put(";\n");
		}
		
		return builder.data;
	}
	
	private Argument[] args;
	private Operator pOp;
}

unittest
{
	class VoidOp : Operator
	{
		this()
		{
			mRetType = new TypeVoid;
			super("v","",ArgsStyle.BINAR_STYLE);
			
			ArgInfo a1;
			a1.type = mRetType;
			a1.min = "-1000";
			a1.max = "+1000";
			
			args ~= a1;
			args ~= a1;
		}
	
		override Argument apply(IndAbstract ind, Line line, WorldAbstract world)
		{
			return mRetType.getNewArg();
		}	
	
	}
		auto tm = new TypeMng;
		
	    auto aline = new Line;
	    auto op = new VoidOp;
	    auto nline = new Line;
	    auto mline = new Line;
	    
	    mline.operator = op;
	    nline.operator = op;
		aline.operator = op;
		
		aline[0] = nline;
		aline[1] = mline;
		
		auto  i = aline.children;
		assert( i== 7, text("Children doesn't work! ",i));
}
