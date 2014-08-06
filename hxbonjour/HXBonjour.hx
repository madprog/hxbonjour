// vim: ts=2 sw=2 et
package hxbonjour;

import #if cpp cpp #else neko #end.Lib;

class HXBonjour
{
  static function load(n:String, p:Int):Dynamic
  {
    return Lib.load("hxbonjour", "hxbonjour_" + n, p > 5 ? -1 : p);
  }
}
