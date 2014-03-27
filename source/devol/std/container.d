/**
*   Copyright: © 2012-2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>,
*             LeMarwin <lemarwin42@gmail.com>,
*             Nazgull09 <nazgull90@gmail.com>
*/
module devol.std.container;

public import devol.type;

abstract class Container : Argument
{
	this(Type pType)
	{
		super(pType);
	}
	
	Argument getRandomElement();
	Argument getRandomElement(double[] chances);
	Argument getRandomLeaf();
	Argument getRandomLeaf(double[] chances);
	uint getLeafCount();
	
	void replaceRandomElement(Argument narg);
	void replaceRandomElement(double[] chances, Argument narg);
	void replaceRandomElement(Argument delegate(Type t) del);
	void replaceRandomElement(Argument delegate(Type t) del, double[] chances);
	
	void addElement(Argument arg);
	void removeElement(int i);
	void removeAll();
	
	int opApply(int delegate(Argument) del);
	Argument opIndex( uint i );
	void opIndexAssign( Argument val, uint i );
	Argument[] opSlice( uint a, uint b );
	
	uint opDollar();
	@property uint length();
}
