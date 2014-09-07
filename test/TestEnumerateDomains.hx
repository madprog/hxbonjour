package test;

import hxbonjour.EnumerateDomains;
import hxbonjour.ErrorCode;
import hxbonjour.Flags;
import hxbonjour.HXBonjour;
import haxe.unit.TestCase;
import haxe.unit.TestRunner;

using test.HelperMacros;

class TestEnumerateDomains extends TestCase
{
    var _sdRef:EnumerateDomains = null;

    public override function setup()
    {
    }

    public override function tearDown()
    {
        if (_sdRef != null) _sdRef.dispose();
    }

    public function testEnumerateDomains()
    {
        var semaphore = { finished: false };
        function callBack(callBackInfo:CallBackInfo):Void
        {
            assertEquals(false, callBackInfo.moreComing);
            assertEquals(Add, callBackInfo.action);
            assertEquals(0, callBackInfo.interfaceIndex);
            assertEquals(NoError, callBackInfo.errorCode);
            assertEquals("local.", callBackInfo.replyDomain);
            assertEquals(_sdRef, callBackInfo.sdRef);

            if (!callBackInfo.moreComing)
            {
                semaphore.finished = true;
            }
        }

        _sdRef = new EnumerateDomains(kDNSServiceFlagsRegistrationDomains, callBack);

        while (!semaphore.finished)
        {
            _sdRef.iterate(0);
        }

        _sdRef.dispose();
        _sdRef = null;
    }
}
