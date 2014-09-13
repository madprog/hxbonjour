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
*
* However, some comments are copy-pasted FROM Apple's dns_sd.h, which says:
********************************************************************************
*
* Copyright (c) 2003-2004, Apple Computer, Inc. All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*
* 1.  Redistributions of source code must retain the above copyright notice,
*     this list of conditions and the following disclaimer.
* 2.  Redistributions in binary form must reproduce the above copyright notice,
*     this list of conditions and the following disclaimer in the documentation
*     and/or other materials provided with the distribution.
* 3.  Neither the name of Apple Computer, Inc. ("Apple") nor the names of its
*     contributors may be used to endorse or promote products derived from this
*     software without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY APPLE AND ITS CONTRIBUTORS "AS IS" AND ANY
* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL APPLE OR ITS CONTRIBUTORS BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*******************************************************************************/
package hxbonjour;

import #if cpp cpp #else neko #end.Lib;

using hxbonjour.RecordType.RecordTypeUtil;

class RecordRef
{
    private var _dnsHandle:Dynamic = null;
    private var _recordHandle:Dynamic = null;

    public var isValid(get, never):Bool;
    public function get_isValid():Bool { return _dnsHandle != null && _recordHandle != null; }

    public function new(dnsHandle:Dynamic, recordType:RecordType, recordData:String, ttl:Int):Void
    {
        var _recordType:Int = recordType.toInt();

        _dnsHandle = dnsHandle;
        _recordHandle = _DNSServiceAddRecord(_dnsHandle, _recordType, recordData, ttl);
    }

    public function updateRecord(recordData:String, ttl:Int = 0):Void
    {
        _DNSServiceUpdateRecord(_dnsHandle, _recordHandle, recordData, ttl);
    }

    public function removeRecord():Void
    {
        _DNSServiceRemoveRecord(_dnsHandle, _recordHandle);
        _dnsHandle = null;
        _recordHandle = null;
    }

    private static var _DNSServiceAddRecord:Dynamic->Int->String->Int->Dynamic = Lib.loadLazy("hxbonjour", "hxbonjour_DNSServiceAddRecord", 4);
    private static var _DNSServiceUpdateRecord:Dynamic->Dynamic->String->Int->Void = Lib.loadLazy("hxbonjour", "hxbonjour_DNSServiceUpdateRecord", 4);
    private static var _DNSServiceRemoveRecord:Dynamic->Dynamic->Void = Lib.loadLazy("hxbonjour", "hxbonjour_DNSServiceRemoveRecord", 2);
}
