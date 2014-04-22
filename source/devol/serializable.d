/**
*   Copyright: © 2012-2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>
*/
module devol.serializable;

public import std.stream;

/**
*   Defines procedures for saving to a binary format.
*/
interface ISerializable
{    
    /// Saving function to binary stream
    void saveBinary(OutputStream stream);
}