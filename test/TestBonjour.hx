package test;

import hxbonjour.EnumerateDomains;
import hxbonjour.HXBonjour;
import haxe.unit.TestCase;
import haxe.unit.TestRunner;

using test.HelperMacros;

class TestBonjour extends TestCase
{
    private var _serviceName:String = "TestService";
    private var _regtype:String = "_test._tcp";
    private var _fullname:String = "TestService._test._tcp.local.";

    public function testConstructFullname()
    {
        var exceptionRaised:Bool = false;

        assertRaises(HXBonjour.DNSServiceConstructFullName(null, null, null), assertEquals("regtype cannot be null", exception));
        assertRaises(HXBonjour.DNSServiceConstructFullName(null, null, "local."), assertEquals("regtype cannot be null", exception));
        assertRaises(HXBonjour.DNSServiceConstructFullName(null, "foo", null), assertEquals("domain cannot be null", exception));
        assertRaises(HXBonjour.DNSServiceConstructFullName(null, "foo", "local."), assertEquals("regtype should be in the form _proto._(tcp|udp)", exception));
        assertRaises(HXBonjour.DNSServiceConstructFullName(null, "foo._tcp", "local."), assertEquals("regtype should be in the form _proto._(tcp|udp)", exception));
        assertRaises(HXBonjour.DNSServiceConstructFullName(null, "_foo._tcp_", "local."), assertEquals("regtype should be in the form _proto._(tcp|udp)", exception));

        var fullname:String = HXBonjour.DNSServiceConstructFullName(_serviceName, _regtype, 'local.');

        if (fullname.substr(-1) != ".") fullname += '.';
        assertEquals(fullname, _fullname);
    }

    public static function main():Void
    {
        var runner:TestRunner = new TestRunner();
        runner.add(new TestBonjour());
        runner.add(new TestEnumerateDomains());
        runner.run();
    }
}
