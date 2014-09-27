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

class ResolveServicesInfo
{
    public var sdRef(default, null):ResolveServices;
    public var moreComing(default, null):Bool;
    public var errorCode(default, null):ErrorCode;
    public var fullname(default, null):String;
    public var hosttarget(default, null):String;
    public var port(default, null):UInt;
    public var txtRecord(default, null):TXTRecord;

    public function new(sdRef:ResolveServices, moreComing:Bool, errorCode:ErrorCode, fullname:String, hosttarget:String, port:UInt, txtRecord:String)
    {
        this.sdRef = sdRef;
        this.moreComing = moreComing;
        this.errorCode = errorCode;
        this.fullname = fullname;
        this.hosttarget = hosttarget;
        this.port = port;
        this.txtRecord = TXTRecord.parse(Bytes.ofString(txtRecord));
    }
}

typedef ResolveServicesCallBack = ResolveServicesInfo->Void;
typedef DNSServiceResolveServicesCallBack = Array<Dynamic>->Void;

class ResolveServices implements IDnsService
{
    private var _dnsHandle:Dynamic = null;
    private var _callBack:ResolveServicesCallBack = null;
    private var _dnsServiceCallBack:DNSServiceResolveServicesCallBack = null;

    private function _myCallBack(args:Array<Dynamic>)
    {
        var flags:Int = args[0];
        var errorCode:Int = args[1];
        var fullname:String = args[2];
        var hosttarget:String = args[3];
        var port:Int = args[4];
        var txtRecord:String = args[5];

        var moreComing:Bool = (flags & 0x01) != 0;

        var _errorCode:ErrorCode = switch(errorCode)
        {
            case 0x0: NoError;
            default: throw "Invalid errorCode value: " + errorCode;
        };

        _callBack(new ResolveServicesInfo(this, moreComing, _errorCode, fullname, hosttarget, port, txtRecord));
    }

    public function new(forceMulticast:Bool, name:String, regtype:String, domain:String, callBack:ResolveServicesCallBack):Void
    {
        HXBonjour.init();

        _callBack = callBack;
        _dnsServiceCallBack = _myCallBack;
        _dnsHandle = _DNSServiceResolve(forceMulticast, name, regtype, domain, _dnsServiceCallBack);
    }

    public function dispose():Void
    {
        _DNSServiceRefDeallocate(_dnsHandle);
    }

    public function iterate(timeout:Float):Void
    {
        _DNSServiceProcessResult(_dnsHandle, timeout);
    }

    private static var _DNSServiceResolve:Bool->String->String->String->DNSServiceResolveServicesCallBack->Dynamic = Lib.loadLazy("hxbonjour", "hxbonjour_DNSServiceResolve", 5);
    private static var _DNSServiceProcessResult:Dynamic->Float->Void = Lib.loadLazy("hxbonjour", "hxbonjour_DNSServiceProcessResult", 2);
    private static var _DNSServiceRefDeallocate:Dynamic->Void = Lib.loadLazy("hxbonjour", "hxbonjour_DNSServiceRefDeallocate", 1);
}
