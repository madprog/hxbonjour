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
import hxbonjour.HXBonjour.IDnsService;
import hxbonjour.Flags.ActionFlags;

class RegisterRecordInfo
{
    public var sdRef(default, null):RegisterRecord;
    public var action(default, null):ActionFlags;
    public var errorCode(default, null):ErrorCode;
    public var name(default, null):String;
    public var regType(default, null):String;
    public var domain(default, null):String;

    public function new(sdRef:RegisterRecord, action:ActionFlags, errorCode:ErrorCode, name:String, regType:String, domain:String)
    {
        this.sdRef = sdRef;
        this.action = action;
        this.errorCode = errorCode;
        this.name = name;
        this.regType = regType;
        this.domain = domain;
    }
}

typedef RegisterRecordCallBack = RegisterRecordInfo->Void;

class RegisterRecord implements IDnsService
{
    private var _dnsHandle:Dynamic = null;
    private var _callBack:RegisterRecordCallBack = null;

    private function _myCallBack(flags:UInt, errorCode:UInt, name:String, regType:String, domain:String)
    {
        var action:ActionFlags;

        switch (flags & 0x02) {
            case 0x00: action = Remove;
            case 0x02: action = Add;
            default: throw "Invalid action flags value: " + (flags & 0x02);
        }

        var _errorCode:ErrorCode = switch (errorCode)
        {
            case 0x0: NoError;
            default: throw "Invalid errorCode value: " + errorCode;
        };

        _callBack(new RegisterRecordInfo(this, action, _errorCode, name, regType, domain));
    }

    public function new(name:String, regType:String, domain:String, host:String, port:UInt, txt:TXTRecord, callBack:RegisterRecordCallBack):Void
    {
        HXBonjour.init();

        _callBack = callBack;
        _dnsHandle = _DNSServiceRegister(name, regType, domain, host, port, txt.getBytes().toString(), _myCallBack);
    }

    public function dispose():Void
    {
        _DNSServiceRefDeallocate(_dnsHandle);
    }

    public function iterate(timeout:Float):Void
    {
        _DNSServiceProcessResult(_dnsHandle, timeout);
    }

    public function addRecord(recordType:RecordType, recordData:String, ttl:Int = 0):RecordRef
    {
        return new RecordRef(_dnsHandle, recordType, recordData, ttl);
    }

    private static var _DNSServiceRegister:String->String->String->String->UInt->String->(UInt->UInt->String->String->String->Void)->Dynamic = Lib.loadLazy("hxbonjour", "hxbonjour_DNSServiceRegister", -1);
    private static var _DNSServiceProcessResult:Dynamic->Float->Void = Lib.loadLazy("hxbonjour", "hxbonjour_DNSServiceProcessResult", 2);
    private static var _DNSServiceRefDeallocate:Dynamic->Void = Lib.loadLazy("hxbonjour", "hxbonjour_DNSServiceRefDeallocate", 1);
}
