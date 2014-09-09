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

import haxe.unit.TestCase;
import hxbonjour.BrowseServices;
import hxbonjour.ErrorCode;
import hxbonjour.Flags.ActionFlags;
import hxbonjour.RegisterRecord;
import hxbonjour.ResolveServices;

using test.HelperMacros;

class TestRegisterBrowseResolve extends TestCase
{
    var _sdRefRegister:RegisterRecord = null;
    var _sdRefBrowse:BrowseServices = null;
    var _sdRefResolve:ResolveServices = null;
    var _serviceName:String = null;
    var _regType:String = null;
    var _port:UInt = null;

    public override function setup()
    {
        _serviceName = "TestService";
        _regType = "_test._tcp.";
        _port = 1111;
    }

    public override function tearDown()
    {
        if (_sdRefRegister != null) _sdRefRegister.dispose();
    }

    public function testRegisterRecord()
    {
        var semaphoreRegister = { finished: false };
        function callBackRegister(callBackInfo:RegisterRecordInfo):Void
        {
            semaphoreRegister.finished = true;
            assertEquals(_sdRefRegister, callBackInfo.sdRef);
            assertEquals(Add, callBackInfo.action);
            assertEquals(NoError, callBackInfo.errorCode);
            assertEquals(_serviceName, callBackInfo.name);
            assertEquals(_regType, callBackInfo.regType);
            assertEquals("local.", callBackInfo.domain);
        }

        _sdRefRegister = new RegisterRecord(_serviceName, _regType, null, null, _port, callBackRegister);

        while (!semaphoreRegister.finished)
        {
            _sdRefRegister.iterate(0);
        }

        var semaphoreBrowse = { finished: false };
        function callBackBrowse(callBackInfo:BrowseServicesInfo):Void
        {
            semaphoreBrowse.finished = true;
            assertEquals(NoError, callBackInfo.errorCode);
            assertEquals(_sdRefBrowse, callBackInfo.sdRef);
            assertEquals(Add, callBackInfo.action);
            assertEquals(_serviceName, callBackInfo.serviceName);
            assertEquals(_regType, callBackInfo.regtype);
            assertEquals("local.", callBackInfo.replyDomain);

            var semaphoreResolve = { finished: false };
            function callBackResolve(callBackInfo2:ResolveServicesInfo):Void
            {
                semaphoreResolve.finished = true;
            }

            _sdRefResolve = new ResolveServices(false, callBackInfo.serviceName, callBackInfo.regtype, callBackInfo.replyDomain, callBackResolve);

            while (!semaphoreResolve.finished)
            {
                _sdRefResolve.iterate(0);
            }
        }

        _sdRefBrowse = new BrowseServices(_regType, null, callBackBrowse);

        while (!semaphoreBrowse.finished)
        {
            _sdRefBrowse.iterate(0);
        }

        _sdRefRegister.dispose();
        _sdRefRegister = null;
    }
}
