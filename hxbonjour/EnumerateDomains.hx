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
import hxbonjour.Flags.ActionFlags;
import hxbonjour.Flags.EnumerateDomainsFlags;
import hxbonjour.HXBonjour.IDnsService;

class EnumerateDomainsInfo
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

typedef EnumerateDomainsCallBack = EnumerateDomainsInfo->Void;
typedef DNSServiceEnumerateDomainsCallBack = UInt->Int->UInt->String->Void;

class EnumerateDomains implements IDnsService
{
    private var _dnsHandle:Dynamic = null;
    private var _callBack:EnumerateDomainsCallBack = null;
    private var _dnsServiceCallBack:DNSServiceEnumerateDomainsCallBack = null;

    private function _myCallBack(flags:UInt, interfaceIndex:Int, errorCode:UInt, replyDomain:String)
    {
        var moreComing:Bool = (flags & 0x01) != 0;
        var action:ActionFlags = switch(flags & 0x02)
        {
            case 0x0: Remove;
            case 0x2: Add;
            default: throw "Invalid action flags value: " + (flags & 0x02);
        };

        var _errorCode:ErrorCode = switch(errorCode)
        {
            case 0x0: NoError;
            default: throw "Invalid errorCode value: " + errorCode;
        };

        _callBack(new EnumerateDomainsInfo(this, moreComing, action, interfaceIndex, _errorCode, replyDomain));
    }

    public function new(flags:EnumerateDomainsFlags, callBack:EnumerateDomainsCallBack):Void
    {
        HXBonjour.init();

        var _flags:UInt = switch (flags)
        {
            case kDNSServiceFlagsBrowseDomains: 0x40;
            case kDNSServiceFlagsRegistrationDomains: 0x80;
        };

        _callBack = callBack;
        _dnsServiceCallBack = _myCallBack;
        _dnsHandle = _DNSServiceEnumerateDomains(_flags, _dnsServiceCallBack);
    }

    public function dispose():Void
    {
        _DNSServiceRefDeallocate(_dnsHandle);
    }

    public function iterate(timeout:Float):Void
    {
        _DNSServiceProcessResult(_dnsHandle, timeout);
    }

    private static var _DNSServiceEnumerateDomains:UInt->DNSServiceEnumerateDomainsCallBack->Dynamic = Lib.loadLazy("hxbonjour", "hxbonjour_DNSServiceEnumerateDomains", 2);
    private static var _DNSServiceProcessResult:Dynamic->Float->Void = Lib.loadLazy("hxbonjour", "hxbonjour_DNSServiceProcessResult", 2);
    private static var _DNSServiceRefDeallocate:Dynamic->Void = Lib.loadLazy("hxbonjour", "hxbonjour_DNSServiceRefDeallocate", 1);
}
