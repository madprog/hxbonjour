// vim: ts=2 sw=2 et
package hxbonjour;

import #if cpp cpp #else neko #end.Lib;
import haxe.macro.Expr;
import haxe.macro.Expr.ExprOf;

class HXBonjour
{
    public static function init()
    {
#if neko
        var initNeko = Lib.load("hxbonjour", "neko_init", 5);
        if (initNeko != null)
        {
            initNeko(function(s) return new String(s),
                    function(len:Int) { var r = []; if (len > 0) r[len - 1] = null; return r; },
                    null, true, false);
        }
#end
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
        return _DNSServiceConstructFullName(service, regtype, domain);
    }
    private static var _DNSServiceConstructFullName:String->String->String->String = Lib.load("hxbonjour", "hxbonjour_DNSServiceConstructFullName", 3);
}
