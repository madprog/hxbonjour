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

import hxbonjour.HXBonjour;
import haxe.unit.TestCase;

using test.HelperMacros;

class TestConstructFullName extends TestCase
{
    private var _serviceName:String = "TestService";
    private var _regtype:String = "_test._tcp";
    private var _fullname:String = "TestService._test._tcp.local.";

    public function testConstructFullname()
    {
        var exceptionRaised:Bool = false;

        assertRaises(HXBonjour.DNSServiceConstructFullName(null, null, null), assertEquals("regtype cannot be null", exception));
        assertRaises(HXBonjour.DNSServiceConstructFullName(null, null, "local."), assertEquals("regtype cannot be null", exception));
        assertRaises(HXBonjour.DNSServiceConstructFullName(null, "foo", null), assertEquals("domain cannot be null", exception));
        assertRaises(HXBonjour.DNSServiceConstructFullName(null, "foo", "local."), assertEquals("regtype should be in the form _proto._(tcp|udp)", exception));
        assertRaises(HXBonjour.DNSServiceConstructFullName(null, "foo._tcp", "local."), assertEquals("regtype should be in the form _proto._(tcp|udp)", exception));
        assertRaises(HXBonjour.DNSServiceConstructFullName(null, "_foo._tcp_", "local."), assertEquals("regtype should be in the form _proto._(tcp|udp)", exception));

        var fullname:String = HXBonjour.DNSServiceConstructFullName(_serviceName, _regtype, 'local.');

        if (fullname.substr(-1) != ".") fullname += '.';
        assertEquals(fullname, _fullname);
    }
}
