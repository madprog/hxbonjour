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
import hxbonjour.ErrorCode;
import hxbonjour.HXBonjour;
import hxbonjour.QueryRecord;
import hxbonjour.RecordClass;
import hxbonjour.RecordRef;
import hxbonjour.RecordType;
import hxbonjour.RegisterRecord;
import hxbonjour.TXTRecord;

using test.HelperMacros;

class TestAddUpdateRemove extends TestCase
{
    var _sdRefRegister:RegisterRecord = null;
    var _sdRefQuery:QueryRecord = null;
    var _serviceName:String = null;
    var _regType:String = null;
    var _port:UInt = null;
    var _domain:String = null;
    var _fullname:String = null;

    public override function setup()
    {
        _serviceName = "TestService";
        _regType = "_test._tcp.";
        _port = 1111;
        _domain = "local.";
        _fullname = HXBonjour.DNSServiceConstructFullName(_serviceName, _regType, _domain);

        var semaphore:Semaphore = { finished: false };
        function callBack(callBackInfo:RegisterRecordInfo):Void
        {
            semaphore.finished = true;
        }

        var txt:TXTRecord = new TXTRecord();
        txt.set("foo", "foobar");

        _sdRefRegister = new RegisterRecord(_serviceName, _regType, null, null, _port, txt, callBack);

        iterate(semaphore, _sdRefRegister);
    }

    public override function tearDown()
    {
        if (_sdRefRegister != null) _sdRefRegister.dispose();
        if (_sdRefQuery != null) _sdRefQuery.dispose();
    }

    private function queryRecord(recordType:RecordType, recordData:String)
    {
        Sys.sleep(5);

        var semaphore:Semaphore = { finished: false };
        function callBack(queryInfo:QueryRecordInfo):Void
        {
            assertEquals(NoError, queryInfo.errorCode);
            assertEquals(_sdRefQuery, queryInfo.sdRef);
            assertEquals(_fullname, queryInfo.fullname);
            assertEquals(recordType, queryInfo.recordType);
            assertEquals(recordData, queryInfo.recordData);
            semaphore.finished = true;
        }

        _sdRefQuery = new QueryRecord(false, _fullname, recordType, callBack);

        iterate(semaphore, _sdRefQuery);

        assertTrue(semaphore.finished);
    }

    public function testAddUpdateRemove()
    {
        var recordRef:RecordRef = _sdRefRegister.addRecord(Sink, "foo");
        assertTrue(recordRef != null);
        assertTrue(recordRef.isValid);
        queryRecord(Sink, "foo");

        recordRef.updateRecord("bar");
        queryRecord(Sink, "bar");
        assertTrue(recordRef.isValid);

        recordRef.removeRecord();
        assertFalse(recordRef.isValid);

        _sdRefRegister.dispose();
        _sdRefRegister = null;
    }
}
