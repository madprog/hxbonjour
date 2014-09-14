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
package test;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.PosInfos;
import haxe.CallStack;
import haxe.unit.TestCase;
import hxbonjour.HXBonjour.IDnsService;
import sys.io.File;

class HelperMacros
{
    macro public static function assertRaises(self:ExprOf<TestCase>, expr:Expr, ?checkExpr:Expr):Expr
    {
        var posInfos = toPosInfos(expr.pos);
        var willCheck = switch (checkExpr.expr)
        {
            case EConst(CIdent("null")): false;
            default: true;
        };
        if (willCheck)
            return macro HelperMacros._assertRaises($self, function() { $expr; }, function(exception) { $checkExpr; }, $v{posInfos});
        else
            return macro HelperMacros._assertRaises($self, function() { $expr; }, null, $v{posInfos});
    }

    #if macro
    static function toPosInfos(p:Position):PosInfos
    {
        var posInfos = Context.getPosInfos(p);
        var line:Int = File.getContent(posInfos.file).substr(0, posInfos.min).split("\n").length;
        return {
            lineNumber: line,
            fileName: posInfos.file,
            className: Context.getLocalClass().get().name,
            methodName: Context.getLocalMethod()
        };
    }
    #end

    public static function _assertRaises(self:TestCase, func:Void->Void, ?checkFunc:Dynamic->Void, ?infos:PosInfos):Void
    {
        self.currentTest.done = true;

        try
        {
            func();
        }
        catch (exception:Dynamic)
        {
            if (checkFunc == null) return;
            checkFunc(exception);
            return;
        }

        self.currentTest.success = false;
        self.currentTest.error   = "Exception not thrown";
        self.currentTest.posInfos = infos;
        throw self.currentTest;
    }
}
