package test;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.PosInfos;
import haxe.CallStack;
import haxe.unit.TestCase;
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
