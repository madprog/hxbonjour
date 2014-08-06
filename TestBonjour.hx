import haxe.unit.TestCase;
import haxe.unit.TestRunner;

class TestBonjour extends TestCase
{
    public static function main():Void
    {
        var runner:TestRunner = new TestRunner();
        runner.add(new TestBonjour());
        runner.run();
    }
}
