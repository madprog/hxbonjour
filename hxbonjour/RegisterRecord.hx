// vim: ts=2 sw=2 et
package hxbonjour;

import #if cpp cpp #else neko #end.Lib;
import haxe.io.Bytes;
import haxe.io.BytesOutput;
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

class RegisterRecord
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
        }

        _callBack(new RegisterRecordInfo(this, action, _errorCode, name, regType, domain));
    }

    public function new(name:String, regType:String, domain:String, host:String, port:UInt, callBack:RegisterRecordCallBack):Void
    {
        HXBonjour.init();

        var buffer:BytesOutput = new BytesOutput();
        buffer.bigEndian = true;
        buffer.writeUInt16(port);

        var _portBytes:Bytes = buffer.getBytes();
        var _port:UInt = (_portBytes.get(0) << 8) | (_portBytes.get(1) << 0);

        _callBack = callBack;
        _dnsHandle = _DNSServiceRegister(name, regType, domain, host, _port, _myCallBack);
    }

    public function dispose():Void
    {
        _DNSServiceRefDeallocate(_dnsHandle);
    }

    public function iterate(timeout:Float):Void
    {
        _DNSServiceProcessResult(_dnsHandle, timeout);
    }

    private static var _DNSServiceRegister:String->String->String->String->UInt->(UInt->UInt->String->String->String->Void)->Dynamic = Lib.loadLazy("hxbonjour", "hxbonjour_DNSServiceRegister", -1);
    private static var _DNSServiceProcessResult:Dynamic->Float->Void = Lib.loadLazy("hxbonjour", "hxbonjour_DNSServiceProcessResult", 2);
    private static var _DNSServiceRefDeallocate:Dynamic->Void = Lib.loadLazy("hxbonjour", "hxbonjour_DNSServiceRefDeallocate", 1);
}
