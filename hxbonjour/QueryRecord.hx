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

import #if cpp cpp #else neko #end.Lib;
import haxe.io.Bytes;
import hxbonjour.Flags.ActionFlags;
import hxbonjour.HXBonjour.IDnsService;

using hxbonjour.RecordType.RecordTypeUtil;

class QueryRecordInfo
{
    public var sdRef(default, null):QueryRecord;
    public var errorCode(default, null):ErrorCode;
    public var fullname(default, null):String;
    public var recordType(default, null):RecordType;
    public var recordClass(default, null):RecordClass;
    public var recordData(default, null):String;
    public var ttl(default, null):Int;

    public function new(sdRef:QueryRecord, errorCode:ErrorCode, fullname:String, recordType:RecordType, recordClass:RecordClass, recordData:String, ttl:Int)
    {
        this.sdRef = sdRef;
        this.errorCode = errorCode;
        this.fullname = fullname;
        this.recordType = recordType;
        this.recordClass = recordClass;
        this.recordData = recordData;
        this.ttl = ttl;
    }
}

typedef QueryRecordCallBack = QueryRecordInfo->Void;

class QueryRecord implements IDnsService
{
    private var _dnsHandle:Dynamic = null;
    private var _callBack:QueryRecordCallBack = null;

    private function _myCallBack(args:Array<Dynamic>):Void
    {
        var flags:Int = args[0];
        var errorCode:Int = args[1];
        var fullname:String = args[2];
        var recordType:Int = args[3];
        var recordClass:Int = args[4];
        var recordData:String = args[5];
        var ttl:Int = args[6];

        var moreComing:Bool = (flags & 0x01) != 0;
        var action:ActionFlags = switch(flags & 0x06)
        {
            case 0x2: Add;
            case 0x4: Remove;
            default: throw "Invalid action flags value: " + (flags & 0x06);
        };

        var _errorCode:ErrorCode = switch (errorCode)
        {
            case 0x0: NoError;
            default: throw "Invalid errorCode value: " + errorCode;
        };

        var _recordType:RecordType = recordType.ToRecordType();

        var _recordClass:RecordClass = switch (recordClass)
        {
            case 1: IN; // Internet
            default: throw "Invalid recordClass value: " + recordClass;
        };

        _callBack(new QueryRecordInfo(this, _errorCode, fullname, _recordType, _recordClass, recordData, ttl));
    }

    public function new(forceMulticast:Bool, fullname:String, recordType:RecordType, ?recordClass:RecordClass, callBack:QueryRecordCallBack):Void
    {
        HXBonjour.init();

        if (recordClass == null) recordClass = IN;

        var _recordType:Int = recordType.toInt();

        var _recordClass:Int = switch (recordClass)
        {
            case IN: 1; // Internet
        };

        _callBack = callBack;
        _dnsHandle = _DNSServiceQueryRecord(forceMulticast, fullname, _recordType, _recordClass, _myCallBack);
    }

    public function dispose():Void
    {
        _DNSServiceRefDeallocate(_dnsHandle);
    }

    public function iterate(timeout:Float):Void
    {
        _DNSServiceProcessResult(_dnsHandle, timeout);
    }

    private static var _DNSServiceQueryRecord:Bool->String->Int->Int->(Array<Dynamic>->Void)->Dynamic = Lib.loadLazy("hxbonjour", "hxbonjour_DNSServiceQueryRecord", 5);
    private static var _DNSServiceProcessResult:Dynamic->Float->Void = Lib.loadLazy("hxbonjour", "hxbonjour_DNSServiceProcessResult", 2);
    private static var _DNSServiceRefDeallocate:Dynamic->Void = Lib.loadLazy("hxbonjour", "hxbonjour_DNSServiceRefDeallocate", 1);
}
