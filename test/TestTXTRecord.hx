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
package test;

import haxe.io.Bytes;
import haxe.unit.TestCase;
import hxbonjour.TXTRecord;

using test.HelperMacros;

class TestTXTRecord extends TestCase
{
    public function testEmpty()
    {
        var txtRecord:TXTRecord = new TXTRecord();
        assertEquals(0, txtRecord.length);
        assertTrue(txtRecord.isEmpty);
        assertEquals(Bytes.ofString("\x00").toHex(), txtRecord.getBytes().toHex());
    }

    public function testCreationAndAccess()
    {
        var values:Map<String, String> = new Map<String, String>();
        values["foo"] = "bar";
        values["baz"] = "buzz";
        values["none"] = null;
        values["empty"] = "";
        var txtRecord:TXTRecord = new TXTRecord(values);

        assertEquals("bar", txtRecord.get("foo"));
        assertEquals("buzz", txtRecord.get("BaZ"));
        assertEquals(null, txtRecord.get("none"));
        assertEquals("", txtRecord.get("empty"));

        assertEquals(4, txtRecord.length);
        assertFalse(txtRecord.isEmpty);
        assertEquals(txtRecord.getBytes().toHex(), TXTRecord.parse(txtRecord.getBytes()).getBytes().toHex());

        txtRecord.set("baZ", "fuzz");
        assertEquals("fuzz", txtRecord.get("baz"));
        assertEquals(4, txtRecord.length);

        assertTrue(txtRecord.contains("foo"));
        txtRecord.remove("foo");
        assertFalse(txtRecord.contains("foo"));

        assertRaises(txtRecord.get("not_a_key"), assertEquals("'not_a_key' could not be found", exception));
        assertRaises(txtRecord.remove("not_a_key"), assertEquals("'not_a_key' could not be found", exception));
        assertRaises(txtRecord.set("foo\x00", "bar"), assertEquals("'foo\x00' is not a valid key", exception));
        assertRaises(txtRecord.set("", "bar"), assertEquals("'' is not a valid key", exception));
        var b252:StringBuf = new StringBuf();
        for (i in 0...252) b252.add('b');
        assertRaises(txtRecord.set("foo", b252.toString()), assertEquals("'key=value' should not exceed 255 characters", exception));

        // Example from
        // http://files.dns-sd.org/draft-cheshire-dnsext-dns-sd.txt
        var data:Bytes;
        var txt:TXTRecord;

        data = Bytes.ofString("\x0Aname=value\x08paper=A4\x0EDNS-SD Is Cool");
        txt = TXTRecord.parse(data);
        assertEquals(data.toHex(), txt.getBytes().toHex());
        assertEquals(null, txt.get("DNS-SD Is Cool"));

        data = Bytes.ofString("\x04bar=\nfoo=foobar\nfoo=barfoo\n=foofoobar");
        txt = TXTRecord.parse(data);
        assertEquals(2, txt.length);
        assertEquals('', txt.get("bar"));
        assertEquals("\x04bar=\nfoo=foobar", txt.getBytes().toString());

        var value:String = [ for (i in 0...254) "y" ].join("");
        assertEquals(254, value.length);
        assertRaises(new TXTRecord().set("x", value), "");
        txt = new TXTRecord(null, false);
        txt.set("x", value);
        assertEquals(256, txt.getBytes().length);
    }
}
