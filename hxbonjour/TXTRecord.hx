/*******************************************************************************
*
* Copyright (c) 2014 Paul Morelle
*
* Permission is hereby granted, free of charge, to any person
* obtaining a copy of this software and associated documentation files
* (the "Software"), to deal in the Software without restriction,
* including without limitation the rights to use, copy, modify, merge,
* publish, distribute, sublicense, and/or sell copies of the Software,
* and to permit persons to whom the Software is furnished to do so,
* subject to the following conditions:
*
* The above copyright notice and this permission notice shall be
* included in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
* NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
* BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
* ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
* CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
*******************************************************************************/
package hxbonjour;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;

class TXTRecord
{
    public var strict:Bool;
    private var _items:Map<String, String>;
    private var _names:Map<String, String>;
    private var _keys:Array<String>;

    public function new(?items:Map<String, String>, strict:Bool = true)
    {
        this.strict = strict;
        _items = new Map<String, String>();
        _names = new Map<String, String>();
        _keys = new Array<String>();

        if (items != null)
        {
            for (key in items.keys())
            {
                set(key, items[key]);
            }
        }
    }

    public var length(get, never):UInt;
    private function get_length():UInt { return _keys.length; }

    public var isEmpty(get, never):Bool;
    private function get_isEmpty():Bool { return length == 0; }

    private inline function checkKey(key:String, throwIfNotExists:Bool=true):String
    {
        if (!~/^[ -<>-~]+$/.match(key)) throw "'" + key + "' is not a valid key";

        var lkey = key.toLowerCase();
        if (throwIfNotExists && !contains(lkey)) throw "'" + key + "' could not be found";
        return lkey;
    }

    public function get(key:String):String
    {
        var lkey:String = checkKey(key);
        return _items[lkey];
    }

    public function set(key:String, value:String):String
    {
        var lkey = checkKey(key, false);

        if (strict)
        {
            var buffer:BytesOutput = new BytesOutput();
            buffer.writeString(key);
            if (value != null)
            {
                buffer.writeString("=");
                buffer.writeString(value);
            }
            if (buffer.length > 255) throw "'key=value' should not exceed 255 characters";
        }

        if (!_items.exists(lkey))
        {
            _names[lkey] = key;
            _keys.push(lkey);
        }
        _items[lkey] = value;

        return value;
    }

    public function remove(key:String):Void
    {
        var lkey = checkKey(key);

        _names.remove(lkey);
        _items.remove(lkey);
        _keys.remove(lkey);
    }

    public function contains(key:String):Bool
    {
        var lkey = checkKey(key, false);
        return _names.exists(lkey);
    }

    public function getBytes():Bytes
    {
        if (isEmpty) return Bytes.ofString("\x00");

        var buffer:BytesOutput = new BytesOutput();

        for (key in _keys) {
            var name:String = _names[key];
            var value:String = _items[key];
            var item:Bytes = Bytes.ofString(if (value == null) name else name + "=" + value);
            var length:UInt = if (!strict && item.length > 255) 255 else item.length;

            buffer.writeByte(length);
            buffer.writeBytes(item, 0, length);
        }

        return buffer.getBytes();
    }

    public static function parse(data:Bytes, strict:Bool = false):TXTRecord
    {
        var ret:TXTRecord = new TXTRecord(null, strict);
        var buffer:BytesInput = new BytesInput(data);

        while (buffer.length > buffer.position)
        {
            var length:UInt = buffer.readByte();
            var item:Array<String> = buffer.read(length).toString().split("=");

            // Add the item only if the name is non-empty and there are
            // no existing items with the same name
            if (item[0].length > 0 && !ret.contains(item[0]))
            {
                if (item.length == 1) ret.set(item[0], null);
                else ret.set(item[0], item[1]);
            }
        }

        return ret;
    }
}
