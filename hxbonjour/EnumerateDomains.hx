// vim: ts=2 sw=2 et
package hxbonjour;

import #if cpp cpp #else neko #end.Lib;
import hxbonjour.Flags.ActionFlags;
import hxbonjour.Flags.EnumerateDomainsFlags;

class CallBackInfo
{
    public var sdRef(default, null):EnumerateDomains;
    public var moreComing(default, null):Bool;
    public var action(default, null):ActionFlags;
    public var interfaceIndex(default, null):Int;
    public var errorCode(default, null):ErrorCode;
    public var replyDomain(default, null):String;

    public function new(sdRef:EnumerateDomains, moreComing:Bool, action:ActionFlags, interfaceIndex:Int, errorCode:ErrorCode, replyDomain:String)
    {
        this.sdRef = sdRef;
        this.moreComing = moreComing;
        this.action = action;
        this.interfaceIndex = interfaceIndex;
        this.errorCode = errorCode;
        this.replyDomain = replyDomain;
    }
}

typedef CallBack = CallBackInfo->Void;

class EnumerateDomains
{
    private var _dnsHandle:Dynamic = null;
    private var _callBack:CallBack = null;

    private function _myCallBack(flags:Int, interfaceIndex:Int, errorCode:Int, replyDomain:String)
    {
        var moreComing:Bool = (flags & 0x1) != 0;
        var action:ActionFlags;

        switch(flags & 0x06)
        {
            case 0x2: action = Add;
            case 0x4: action = Remove;
            default: throw "Invalid action flags value: " + (flags & 0x06);
        }

        var _errorCode:ErrorCode = switch(errorCode)
        {
            case 0x0: NoError;
            default: throw "Invalid errorCode value: " + errorCode;
        };

        _callBack(new CallBackInfo(this, moreComing, action, interfaceIndex, _errorCode, replyDomain));
    }

    public function new(flags:EnumerateDomainsFlags, callBack:CallBack):Void
    {
        HXBonjour.init();

        var _flags:Int = switch (flags)
        {
            case kDNSServiceFlagsBrowseDomains: 0x40;
            case kDNSServiceFlagsRegistrationDomains: 0x80;
        };

        _callBack = callBack;
        _dnsHandle = _DNSServiceEnumerateDomains(_flags, _myCallBack);
    }

    public function dispose():Void
    {
        _DNSServiceRefDeallocate(_dnsHandle);
    }

    public function iterate(timeout:Float):Void
    {
        _DNSServiceProcessResult(_dnsHandle, timeout);
    }

    private static var _DNSServiceEnumerateDomains:Int->(Int->Int->Int->String->Void)->Dynamic = Lib.loadLazy("hxbonjour", "hxbonjour_DNSServiceEnumerateDomains", 2);
    private static var _DNSServiceProcessResult:Dynamic->Float->Void = Lib.loadLazy("hxbonjour", "hxbonjour_DNSServiceProcessResult", 2);
    private static var _DNSServiceRefDeallocate:Dynamic->Void = Lib.loadLazy("hxbonjour", "hxbonjour_DNSServiceRefDeallocate", 1);
}
