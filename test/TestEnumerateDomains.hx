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

import hxbonjour.EnumerateDomains;
import hxbonjour.ErrorCode;
import hxbonjour.Flags;
import hxbonjour.HXBonjour;
import haxe.unit.TestCase;
import haxe.unit.TestRunner;

using test.HelperMacros;

class TestEnumerateDomains extends TestCase
{
    var _sdRef:EnumerateDomains = null;

    public override function setup()
    {
    }

    public override function tearDown()
    {
        if (_sdRef != null) _sdRef.dispose();
    }

    public function testEnumerateDomains()
    {
        var semaphore:Semaphore = { finished: false };
        function callBack(callBackInfo:EnumerateDomainsInfo):Void
        {
            assertEquals(false, callBackInfo.moreComing);
            assertEquals(Add, callBackInfo.action);
            assertEquals(0, callBackInfo.interfaceIndex);
            assertEquals(NoError, callBackInfo.errorCode);
            assertEquals("local.", callBackInfo.replyDomain);
            assertEquals(_sdRef, callBackInfo.sdRef);

            if (!callBackInfo.moreComing)
            {
                semaphore.finished = true;
            }
        }

        _sdRef = new EnumerateDomains(kDNSServiceFlagsRegistrationDomains, callBack);

        iterate(semaphore, _sdRef);

        assertTrue(semaphore.finished);

        _sdRef.dispose();
        _sdRef = null;
    }

}
