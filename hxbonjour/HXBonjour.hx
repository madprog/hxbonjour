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
import haxe.macro.Expr;
import haxe.macro.Expr.ExprOf;

class HXBonjour
{
    private static var _initDone = false;

    public static function init()
    {
        if (_initDone) return;
        _initDone = true;

#if neko
        var initNeko = Lib.load("hxbonjour", "neko_init", 5);
        if (initNeko != null)
        {
            initNeko(function(s) return new String(s),
                    function(len:Int) { var r = []; if (len > 0) r[len - 1] = null; return r; },
                    null, true, false);
        }
#end

        var init = Lib.load("hxbonjour", "hxbonjour_init", 0);
        if (init != null)
        {
            init();
        }
    }

    /**
      Concatenate a three-part domain name (as returned by a callback
      function) into a properly-escaped full domain name. Note that
      callback functions already escape strings where necessary.

      service:
          The service name; any dots or backslashes must NOT be escaped.
          May be null (to construct a PTR record name, e.g.
          "_ftp._tcp.apple.com.").

      regtype:
          The service type followed by the protocol, separated by a dot
          (e.g. "_ftp._tcp").

      domain:
          The domain name, e.g. "apple.com.". Literal dots or
          backslashes, if any, must be escaped,
          e.g. "1st\. Floor.apple.com."

      return value:
          The resulting full domain name.
    */
    public static function DNSServiceConstructFullName(?service:String, regtype:String, domain:String):String
    {
        init();
        return _DNSServiceConstructFullName(service, regtype, domain);
    }
    private static var _DNSServiceConstructFullName:String->String->String->String = Lib.loadLazy("hxbonjour", "hxbonjour_DNSServiceConstructFullName", 3);
}
