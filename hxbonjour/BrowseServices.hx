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

class BrowseServicesInfo
{
    public var sdRef(default, null):BrowseServices;
    public var moreComing(default, null):Bool;
    public var action(default, null):ActionFlags;
    public var errorCode(default, null):ErrorCode;
    public var serviceName(default, null):String;
    public var regtype(default, null):String;
    public var replyDomain(default, null):String;

    public function new(sdRef:BrowseServices, moreComing:Bool, action:ActionFlags, errorCode:ErrorCode, serviceName:String, regtype:String, replyDomain:String)
    {
        this.sdRef = sdRef;
        this.moreComing = moreComing;
        this.action = action;
        this.errorCode = errorCode;
        this.serviceName = serviceName;
        this.regtype = regtype;
        this.replyDomain = replyDomain;
    }
}

typedef BrowseServicesCallBack = BrowseServicesInfo->Void;
typedef DNSServiceBrowseServicesCallBack = Int->Int->String->String->String->Void;

class BrowseServices implements IDnsService
{
    private var _dnsHandle:Dynamic = null;
    private var _callBack:BrowseServicesCallBack = null;
    private var _dnsServiceCallBack:DNSServiceBrowseServicesCallBack = null;

    private function _myCallBack(flags:Int, errorCode:Int, serviceName:String, regtype:String, replyDomain:String)
    {
        var moreComing:Bool = (flags & 0x01) != 0;
        var action:ActionFlags = switch(flags & 0x06)
        {
            case 0x2: Add;
            case 0x4: Remove;
            default: throw "Invalid action flags value: " + (flags & 0x06);
        };

        var _errorCode:ErrorCode = switch(errorCode)
        {
            case 0x0: NoError;
            default: throw "Invalid errorCode value: " + errorCode;
        };

        _callBack(new BrowseServicesInfo(this, moreComing, action, _errorCode, serviceName, regtype, replyDomain));
    }

    public function new(regtype:String, domain:String, callBack:BrowseServicesCallBack):Void
    {
        HXBonjour.init();

        _callBack = callBack;
        _dnsServiceCallBack = _myCallBack;
        _dnsHandle = _DNSServiceBrowse(regtype, domain, _dnsServiceCallBack);
    }

    public function dispose():Void
    {
        _DNSServiceRefDeallocate(_dnsHandle);
    }

    public function iterate(timeout:Float):Void
    {
        _DNSServiceProcessResult(_dnsHandle, timeout);
    }

    private static var _DNSServiceBrowse:String->String->DNSServiceBrowseServicesCallBack->Dynamic = Lib.loadLazy("hxbonjour", "hxbonjour_DNSServiceBrowse", 3);
    private static var _DNSServiceProcessResult:Dynamic->Float->Void = Lib.loadLazy("hxbonjour", "hxbonjour_DNSServiceProcessResult", 2);
    private static var _DNSServiceRefDeallocate:Dynamic->Void = Lib.loadLazy("hxbonjour", "hxbonjour_DNSServiceRefDeallocate", 1);
}
