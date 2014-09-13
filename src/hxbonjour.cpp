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
#include <hx/CFFI.h>
#include <cstring>
#include <dns_sd.h>

DEFINE_KIND(k_sdRef);
DEFINE_KIND(k_RecordRef);

static void throw_error(DNSServiceErrorType error)
{
    switch (error)
    {
#define DECLARE_ERROR(name) case name: val_throw(alloc_string(#name));
        DECLARE_ERROR(kDNSServiceErr_NoError);
        DECLARE_ERROR(kDNSServiceErr_Unknown);
        DECLARE_ERROR(kDNSServiceErr_NoSuchName);
        DECLARE_ERROR(kDNSServiceErr_NoMemory);
        DECLARE_ERROR(kDNSServiceErr_BadParam);
        DECLARE_ERROR(kDNSServiceErr_BadReference);
        DECLARE_ERROR(kDNSServiceErr_BadState);
        DECLARE_ERROR(kDNSServiceErr_BadFlags);
        DECLARE_ERROR(kDNSServiceErr_Unsupported);
        DECLARE_ERROR(kDNSServiceErr_NotInitialized);
        DECLARE_ERROR(kDNSServiceErr_AlreadyRegistered);
        DECLARE_ERROR(kDNSServiceErr_NameConflict);
        DECLARE_ERROR(kDNSServiceErr_Invalid);
        DECLARE_ERROR(kDNSServiceErr_Firewall);
        DECLARE_ERROR(kDNSServiceErr_Incompatible);
        DECLARE_ERROR(kDNSServiceErr_BadInterfaceIndex);
        DECLARE_ERROR(kDNSServiceErr_Refused);
        DECLARE_ERROR(kDNSServiceErr_NoSuchRecord);
        DECLARE_ERROR(kDNSServiceErr_NoAuth);
        DECLARE_ERROR(kDNSServiceErr_NoSuchKey);
        DECLARE_ERROR(kDNSServiceErr_NATTraversal);
        DECLARE_ERROR(kDNSServiceErr_DoubleNAT);
        DECLARE_ERROR(kDNSServiceErr_BadTime);
        DECLARE_ERROR(kDNSServiceErr_BadSig);
        DECLARE_ERROR(kDNSServiceErr_BadKey);
        DECLARE_ERROR(kDNSServiceErr_Transient);
        DECLARE_ERROR(kDNSServiceErr_ServiceNotRunning);
        DECLARE_ERROR(kDNSServiceErr_NATPortMappingUnsupported);
        DECLARE_ERROR(kDNSServiceErr_NATPortMappingDisabled);
        DECLARE_ERROR(kDNSServiceErr_NoRouter);
        DECLARE_ERROR(kDNSServiceErr_PollingMode);
        DECLARE_ERROR(kDNSServiceErr_Timeout);

        default: val_throw(alloc_string("Unknown error"));
    }
}

value hxbonjour_init()
{
    k_sdRef = alloc_kind();
    k_RecordRef = alloc_kind();

    return alloc_null();
}

DEFINE_PRIM(hxbonjour_init, 0);

bool check_regtype_format(const char *regtype)
{
    bool regtype_format_ok = regtype[0] == '_';
    if (regtype_format_ok)
    {
        const char *dot_pos = strchr(regtype, '.');
        if (dot_pos != NULL)
        {
            regtype_format_ok = !strncmp(dot_pos, "._tcp", 6)
                || !strncmp(dot_pos, "._tcp.", 7)
                || !strncmp(dot_pos, "._udp", 6)
                || !strncmp(dot_pos, "._udp.", 7);
        }
    }

    return regtype_format_ok;
}

/**
 * DNSServiceConstructFullName()
 *
 * Concatenate a three-part domain name (as returned by the above callbacks) into a
 * properly-escaped full domain name. Note that callbacks in the above functions ALREADY ESCAPE
 * strings where necessary.
 *
 * Parameters:
 *
 * fullName:        A pointer to a buffer that where the resulting full domain name is to be written.
 *                  The buffer must be kDNSServiceMaxDomainName (1009) bytes in length to
 *                  accommodate the longest legal domain name without buffer overrun.
 *
 * service:         The service name - any dots or backslashes must NOT be escaped.
 *                  May be NULL (to construct a PTR record name, e.g.
 *                  "_ftp._tcp.apple.com.").
 *
 * regtype:         The service type followed by the protocol, separated by a dot
 *                  (e.g. "_ftp._tcp").
 *
 * domain:          The domain name, e.g. "apple.com.". Literal dots or backslashes,
 *                  if any, must be escaped, e.g. "1st\. Floor.apple.com."
 *
 * return value:    Returns kDNSServiceErr_NoError (0) on success, kDNSServiceErr_BadParam on error.
 *
 */
value hxbonjour_DNSServiceConstructFullName(value service, value regtype, value domain)
{
    char fullName[kDNSServiceMaxDomainName];
    const char *_service, *_regtype, *_domain;
    DNSServiceErrorType error;

    if (val_is_null(regtype)) val_throw(alloc_string("regtype cannot be null"));
    else if (val_is_string(regtype)) _regtype = val_get_string(regtype);
    else val_throw(alloc_string("regtype must be a String"));

    if (val_is_null(domain)) val_throw(alloc_string("domain cannot be null"));
    else if (val_is_string(domain)) _domain = val_get_string(domain);
    else val_throw(alloc_string("domain must be a String"));

    if (val_is_null(service)) _service = NULL;
    else if (val_is_string(service)) _service = val_get_string(service);
    else val_throw(alloc_string("service must be a String"));

    if (!check_regtype_format(_regtype))
        val_throw(alloc_string("regtype should be in the form _proto._(tcp|udp)"));

    error = DNSServiceConstructFullName(fullName, _service, _regtype, _domain);

    if (error != kDNSServiceErr_NoError) throw_error(error);

    return alloc_string(fullName);
}

DEFINE_PRIM(hxbonjour_DNSServiceConstructFullName, 3);

/* DNSServiceEnumerateDomains()
 *
 * Asynchronously enumerate domains available for browsing and registration.
 *
 * The enumeration MUST be cancelled via DNSServiceRefDeallocate() when no more domains
 * are to be found.
 *
 * Note that the names returned are (like all of DNS-SD) UTF-8 strings,
 * and are escaped using standard DNS escaping rules.
 * (See "Notes on DNS Name Escaping" earlier in this file for more details.)
 * A graphical browser displaying a hierarchical tree-structured view should cut
 * the names at the bare dots to yield individual labels, then de-escape each
 * label according to the escaping rules, and then display the resulting UTF-8 text.
 *
 * DNSServiceDomainEnumReply Callback Parameters:
 *
 * sdRef:           The DNSServiceRef initialized by DNSServiceEnumerateDomains().
 *
 * flags:           Possible values are:
 *                  kDNSServiceFlagsMoreComing
 *                  kDNSServiceFlagsAdd
 *                  kDNSServiceFlagsDefault
 *
 * interfaceIndex:  Specifies the interface on which the domain exists. (The index for a given
 *                  interface is determined via the if_nametoindex() family of calls.)
 *
 * errorCode:       Will be kDNSServiceErr_NoError (0) on success, otherwise indicates
 *                  the failure that occurred (other parameters are undefined if errorCode is nonzero).
 *
 * replyDomain:     The name of the domain.
 *
 * context:         The context pointer passed to DNSServiceEnumerateDomains.
 *
 */
void DNSSD_API hxbonjour_DNSServiceEnumerateDomains_callback(
    DNSServiceRef sdRef,
    DNSServiceFlags flags,
    uint32_t interfaceIndex,
    DNSServiceErrorType errorCode,
    const char *replyDomain,
    void *context
)
{
    value callBack = (value)context;
    value args[] =
    {
        alloc_int(flags),
        alloc_int(interfaceIndex),
        alloc_int(errorCode),
        alloc_string(replyDomain),
    };
    val_callN(callBack, args, sizeof(args) / sizeof(*args));
}

/* DNSServiceEnumerateDomains() Parameters:
 *
 * sdRef:           A pointer to an uninitialized DNSServiceRef. If the call succeeds
 *                  then it initializes the DNSServiceRef, returns kDNSServiceErr_NoError,
 *                  and the enumeration operation will run indefinitely until the client
 *                  terminates it by passing this DNSServiceRef to DNSServiceRefDeallocate().
 *
 * flags:           Possible values are:
 *                  kDNSServiceFlagsBrowseDomains to enumerate domains recommended for browsing.
 *                  kDNSServiceFlagsRegistrationDomains to enumerate domains recommended
 *                  for registration.
 *
 * interfaceIndex:  If non-zero, specifies the interface on which to look for domains.
 *                  (the index for a given interface is determined via the if_nametoindex()
 *                  family of calls.) Most applications will pass 0 to enumerate domains on
 *                  all interfaces. See "Constants for specifying an interface index" for more details.
 *
 * callBack:        The function to be called when a domain is found or the call asynchronously
 *                  fails.
 *
 * context:         An application context pointer which is passed to the callback function
 *                  (may be NULL).
 *
 * return value:    Returns kDNSServiceErr_NoError on success (any subsequent, asynchronous
 *                  errors are delivered to the callback), otherwise returns an error code indicating
 *                  the error that occurred (the callback is not invoked and the DNSServiceRef
 *                  is not initialized).
 */
value hxbonjour_DNSServiceEnumerateDomains(value flags, value callBack)
{
    DNSServiceRef sdRef = NULL;
    DNSServiceFlags _flags = val_int(flags);

    DNSServiceErrorType error = DNSServiceEnumerateDomains(
        &sdRef,
        _flags,
        kDNSServiceInterfaceIndexAny,
        hxbonjour_DNSServiceEnumerateDomains_callback,
        callBack
    );

    if (error != kDNSServiceErr_NoError)
    {
        throw_error(error);
    }

    value handle = alloc_abstract(k_sdRef, sdRef);
    return handle;
}

DEFINE_PRIM(hxbonjour_DNSServiceEnumerateDomains, 2);

value hxbonjour_DNSServiceRefDeallocate(value handle)
{
    DNSServiceRef sdRef;

    if (val_is_null(handle)) val_throw(alloc_string("handle cannot be null"));
    else if (val_is_kind(handle, k_sdRef)) sdRef = (DNSServiceRef)val_to_kind(handle, k_sdRef);
    else val_throw(alloc_string("handle must be a sdRef"));

    DNSServiceRefDeallocate(sdRef);

    return alloc_null();
}

DEFINE_PRIM(hxbonjour_DNSServiceRefDeallocate, 1);

value hxbonjour_DNSServiceProcessResult(value handle, value timeout)
{
    DNSServiceRef sdRef;

    if (val_is_null(handle)) val_throw(alloc_string("handle cannot be null"));
    else if (val_is_kind(handle, k_sdRef)) sdRef = (DNSServiceRef)val_to_kind(handle, k_sdRef);
    else val_throw(alloc_string("handle must be a sdRef"));

    double _timeout;
    if (val_is_float(timeout)) _timeout = val_float(timeout);
    else if (val_is_int(timeout)) _timeout = val_int(timeout);
    else val_throw(alloc_string("timeout must be a float"));

    int sock = DNSServiceRefSockFD(sdRef);
    struct timeval tv_timeout;
    tv_timeout.tv_sec = (int)_timeout;
    tv_timeout.tv_usec = (int)(1000 * (_timeout - (int)_timeout));

    fd_set readfds, writefds, exceptfds;
    FD_ZERO(&readfds); FD_ZERO(&writefds); FD_ZERO(&exceptfds);
    FD_SET(sock, &readfds); FD_SET(sock, &exceptfds);

    if (select(0, &readfds, &writefds, &exceptfds, &tv_timeout) != 0)
    {
        DNSServiceProcessResult(sdRef);
    }

    return alloc_null();
}

DEFINE_PRIM(hxbonjour_DNSServiceProcessResult, 2);

void DNSSD_API hxbonjour_DNSServiceRegister_callback(
    DNSServiceRef sdRef,
    DNSServiceFlags flags,
    DNSServiceErrorType errorCode,
    const char *name,
    const char *regtype,
    const char *domain,
    void *context
)
{
    value callBack = (value)context;
    value args[] =
    {
        alloc_int(flags),
        alloc_int(errorCode),
        alloc_string(name),
        alloc_string(regtype),
        alloc_string(domain),
    };
    val_callN(callBack, args, sizeof(args) / sizeof(*args));
}

value hxbonjour_DNSServiceRegister(value *args, int nbArgs)
{
    if (nbArgs != 7)
        val_throw(alloc_string("Function 'hxbonjour_DNSServiceRegister' requires arguments: name, regtype, domain, host, port, txtRecord, callBack"));

    value name = args[0];
    value regtype = args[1];
    value domain = args[2];
    value host = args[3];
    value port = args[4];
    value txtRecord = args[5];
    value callBack = args[6];

    DNSServiceRef sdRef = NULL;
    const char *_name;
    const char *_regtype;
    const char *_domain;
    const char *_host;
    uint16_t _port;
    uint16_t txtRecordLength;
    const void *_txtRecord;

    if (val_is_null(name)) _name = NULL;
    else if (val_is_string(name)) _name = val_get_string(name);
    else val_throw(alloc_string("name must be a String"));

    if (val_is_null(regtype)) val_throw(alloc_string("regtype cannot be null"));
    else if (val_is_string(regtype)) _regtype = val_get_string(regtype);
    else val_throw(alloc_string("regtype must be a String"));

    if (val_is_null(domain)) _domain = NULL;
    else if (val_is_string(domain)) _domain = val_get_string(domain);
    else val_throw(alloc_string("domain must be a String"));

    if (val_is_null(host)) _host = NULL;
    else if (val_is_string(host)) _host = val_get_string(host);
    else val_throw(alloc_string("host must be a String"));

    if (val_is_null(port)) val_throw(alloc_string("port cannot be null"));
    else if (val_is_int(port)) _port = htons(val_get_int(port));
    else val_throw(alloc_string("port must be an UInt"));

    if (val_is_null(txtRecord)) { _txtRecord = NULL; txtRecordLength = 0; }
    else if (val_is_string(txtRecord)) { _txtRecord = val_get_string(txtRecord); txtRecordLength = val_strlen(txtRecord); }
    else val_throw(alloc_string("txtRecord must be a String"));

    if (!check_regtype_format(_regtype))
        val_throw(alloc_string("regtype should be in the form _proto._(tcp|udp)"));

    DNSServiceErrorType error = DNSServiceRegister(
        &sdRef,
        0,
        kDNSServiceInterfaceIndexAny,
        _name,
        _regtype,
        _domain,
        _host,
        _port,
        txtRecordLength,
        _txtRecord,
        hxbonjour_DNSServiceRegister_callback,
        callBack
    );

    if (error != kDNSServiceErr_NoError)
    {
        throw_error(error);
    }

    value handle = alloc_abstract(k_sdRef, sdRef);
    return handle;
}

DEFINE_PRIM_MULT(hxbonjour_DNSServiceRegister);

void DNSSD_API hxbonjour_DNSServiceBrowse_callback(
    DNSServiceRef sdRef,
    DNSServiceFlags flags,
    uint32_t interfaceIndex,
    DNSServiceErrorType errorCode,
    const char *serviceName,
    const char *regtype,
    const char *replyDomain,
    void *context
)
{
    value callBack = (value)context;
    value args[] =
    {
        alloc_int(flags),
        alloc_int(errorCode),
        alloc_string(serviceName),
        alloc_string(regtype),
        alloc_string(replyDomain),
    };
    val_callN(callBack, args, sizeof(args) / sizeof(*args));
}

value hxbonjour_DNSServiceBrowse(value regtype, value domain, value callBack)
{
    DNSServiceRef sdRef = NULL;
    const char *_regtype;
    const char *_domain;

    if (val_is_null(regtype)) val_throw(alloc_string("regtype cannot be null"));
    else if (val_is_string(regtype)) _regtype = val_get_string(regtype);
    else val_throw(alloc_string("regtype must be a String"));

    if (val_is_null(domain)) _domain = NULL;
    else if (val_is_string(domain)) _domain = val_get_string(domain);
    else val_throw(alloc_string("domain must be a String"));

    if (!check_regtype_format(_regtype))
        val_throw(alloc_string("regtype should be in the form _proto._(tcp|udp)"));

    DNSServiceErrorType error = DNSServiceBrowse(
        &sdRef,
        0,
        kDNSServiceInterfaceIndexAny,
        _regtype,
        _domain,
        hxbonjour_DNSServiceBrowse_callback,
        callBack
    );

    if (error != kDNSServiceErr_NoError)
    {
        throw_error(error);
    }

    value handle = alloc_abstract(k_sdRef, sdRef);
    return handle;
}

DEFINE_PRIM(hxbonjour_DNSServiceBrowse, 3);

void DNSSD_API hxbonjour_DNSServiceResolve_callback(
    DNSServiceRef sdRef,
    DNSServiceFlags flags,
    uint32_t interfaceIndex,
    DNSServiceErrorType errorCode,
    const char *fullname,
    const char *hosttarget,
    uint16_t port,
    uint16_t txtLen,
    const unsigned char *txtRecord,
    void *context
)
{
    value callBack = (value)context;

    value args = alloc_array(6);
    val_array_set_i(args, 0, alloc_int(flags));
    val_array_set_i(args, 1, alloc_int(errorCode));
    val_array_set_i(args, 2, alloc_string(fullname));
    val_array_set_i(args, 3, alloc_string(hosttarget));
    val_array_set_i(args, 4, alloc_int(ntohs(port)));
    val_array_set_i(args, 5, alloc_string_len((const char *)txtRecord, txtLen));
    val_call1(callBack, args);
}

value hxbonjour_DNSServiceResolve(value forceMulticast, value name, value regtype, value domain, value callBack)
{
    DNSServiceRef sdRef = NULL;
    DNSServiceFlags _flags;
    const char *_name;
    const char *_regtype;
    const char *_domain;

    if (val_is_null(forceMulticast)) val_throw(alloc_string("forceMulticast cannot be null"));
    else if (val_is_bool(forceMulticast)) _flags |= val_get_bool(forceMulticast) ? kDNSServiceFlagsForceMulticast : 0;
    else val_throw(alloc_string("forceMulticast must be a Bool"));

    if (val_is_null(name)) val_throw(alloc_string("name cannot be null"));
    else if (val_is_string(name)) _name = val_get_string(name);
    else val_throw(alloc_string("name must be a String"));

    if (val_is_null(regtype)) val_throw(alloc_string("regtype cannot be null"));
    else if (val_is_string(regtype)) _regtype = val_get_string(regtype);
    else val_throw(alloc_string("regtype must be a String"));

    if (val_is_null(domain)) _domain = NULL;
    else if (val_is_string(domain)) _domain = val_get_string(domain);
    else val_throw(alloc_string("domain must be a String"));

    if (!check_regtype_format(_regtype))
        val_throw(alloc_string("regtype should be in the form _proto._(tcp|udp)"));

    DNSServiceErrorType error = DNSServiceResolve(
        &sdRef,
        _flags,
        kDNSServiceInterfaceIndexAny,
        _name,
        _regtype,
        _domain,
        hxbonjour_DNSServiceResolve_callback,
        callBack
    );

    if (error != kDNSServiceErr_NoError)
    {
        throw_error(error);
    }

    value handle = alloc_abstract(k_sdRef, sdRef);
    return handle;
}

DEFINE_PRIM(hxbonjour_DNSServiceResolve, 5);

void DNSSD_API hxbonjour_DNSServiceQueryRecord_callback(
    DNSServiceRef sdRef,
    DNSServiceFlags flags,
    uint32_t interfaceIndex,
    DNSServiceErrorType errorCode,
    const char *fullname,
    uint16_t rrtype,
    uint16_t rrclass,
    uint16_t rdlen,
    const void *rdata,
    uint32_t ttl,
    void *context
)
{
    value callBack = (value)context;

    value args = alloc_array(7);
    val_array_set_i(args, 0, alloc_int(flags));
    val_array_set_i(args, 1, alloc_int(errorCode));
    val_array_set_i(args, 2, alloc_string(fullname));
    val_array_set_i(args, 3, alloc_int(rrtype));
    val_array_set_i(args, 4, alloc_int(rrclass));
    val_array_set_i(args, 5, alloc_string_len((const char *)rdata, rdlen));
    val_array_set_i(args, 6, alloc_int(ttl));
    val_call1(callBack, args);
}

value hxbonjour_DNSServiceQueryRecord(value forceMulticast, value name, value rrtype, value rrclass, value callBack)
{
    DNSServiceRef sdRef = NULL;
    DNSServiceFlags _flags = 0;
    const char *_name;
    uint16_t _rrtype;
    uint16_t _rrclass;

    if (val_is_null(forceMulticast)) val_throw(alloc_string("forceMulticast cannot be null"));
    else if (val_is_bool(forceMulticast)) _flags |= val_get_bool(forceMulticast) ? kDNSServiceFlagsForceMulticast : 0;
    else val_throw(alloc_string("forceMulticast must be a Bool"));

    if (val_is_null(name)) val_throw(alloc_string("name cannot be null"));
    else if (val_is_string(name)) _name = val_get_string(name);
    else val_throw(alloc_string("name must be a String"));

    if (val_is_null(rrtype)) val_throw(alloc_string("rrtype cannot be null"));
    else if (val_is_int(rrtype)) _rrtype = val_get_int(rrtype);
    else val_throw(alloc_string("rrtype must be an Int"));

    if (val_is_null(rrclass)) val_throw(alloc_string("rrclass cannot be null"));
    else if (val_is_int(rrclass)) _rrclass = val_get_int(rrclass);
    else val_throw(alloc_string("rrclass must be an Int"));

    DNSServiceErrorType error = DNSServiceQueryRecord(
        &sdRef,
        _flags,
        kDNSServiceInterfaceIndexAny,
        _name,
        _rrtype,
        _rrclass,
        hxbonjour_DNSServiceQueryRecord_callback,
        callBack
    );

    if (error != kDNSServiceErr_NoError)
    {
        throw_error(error);
    }

    value handle = alloc_abstract(k_sdRef, sdRef);
    return handle;
}

DEFINE_PRIM(hxbonjour_DNSServiceQueryRecord, 5);

value hxbonjour_DNSServiceAddRecord(value handle, value rrtype, value rdata, value ttl)
{
    DNSServiceRef sdRef;
    DNSRecordRef  recordRef = NULL;
    uint16_t _rrtype;
    uint16_t rdataLength;
    const void *_rdata;
    uint32_t _ttl;

    if (val_is_null(handle)) val_throw(alloc_string("handle cannot be null"));
    else if (val_is_kind(handle, k_sdRef)) sdRef = (DNSServiceRef)val_to_kind(handle, k_sdRef);
    else val_throw(alloc_string("handle must be a sdRef"));

    if (val_is_null(rrtype)) val_throw(alloc_string("rrtype cannot be null"));
    else if (val_is_int(rrtype)) _rrtype = val_get_int(rrtype);
    else val_throw(alloc_string("rrtype must be an Int"));

    if (val_is_null(rdata)) val_throw(alloc_string("rdata cannot be null"));
    else if (val_is_string(rdata)) { _rdata = val_get_string(rdata); rdataLength = val_strlen(rdata); }
    else val_throw(alloc_string("rdata must be a String"));

    if (val_is_null(ttl)) _ttl = 0;
    else if (val_is_int(ttl)) _ttl = val_get_int(ttl);
    else val_throw(alloc_string("ttl must be an Int"));

    DNSServiceErrorType error = DNSServiceAddRecord(
        sdRef,
        &recordRef,
        0,
        _rrtype,
        rdataLength,
        _rdata,
        _ttl
    );

    if (error != kDNSServiceErr_NoError)
    {
        throw_error(error);
    }

    value recordHandle = alloc_abstract(k_RecordRef, recordRef);
    return recordHandle;
}

DEFINE_PRIM(hxbonjour_DNSServiceAddRecord, 4);

value hxbonjour_DNSServiceUpdateRecord(value handle, value recordHandle, value rdata, value ttl)
{
    DNSServiceRef sdRef;
    DNSRecordRef  recordRef;
    uint16_t rdataLength;
    const void *_rdata;
    uint32_t _ttl;

    if (val_is_null(handle)) val_throw(alloc_string("handle cannot be null"));
    else if (val_is_kind(handle, k_sdRef)) sdRef = (DNSServiceRef)val_to_kind(handle, k_sdRef);
    else val_throw(alloc_string("handle must be a sdRef"));

    if (val_is_null(recordHandle)) val_throw(alloc_string("recordHandle cannot be null"));
    else if (val_is_kind(recordHandle, k_RecordRef)) recordRef = (DNSRecordRef)val_to_kind(recordHandle, k_RecordRef);
    else val_throw(alloc_string("recordHandle must be a RecordRef"));

    if (val_is_null(rdata)) val_throw(alloc_string("rdata cannot be null"));
    else if (val_is_string(rdata)) { _rdata = val_get_string(rdata); rdataLength = val_strlen(rdata); }
    else val_throw(alloc_string("rdata must be a String"));

    if (val_is_null(ttl)) _ttl = 0;
    else if (val_is_int(ttl)) _ttl = val_get_int(ttl);
    else val_throw(alloc_string("ttl must be an Int"));

    DNSServiceErrorType error = DNSServiceUpdateRecord(
        sdRef,
        recordRef,
        0,
        rdataLength,
        _rdata,
        _ttl
    );

    if (error != kDNSServiceErr_NoError)
    {
        throw_error(error);
    }

    return alloc_null();
}

DEFINE_PRIM(hxbonjour_DNSServiceUpdateRecord, 4);

value hxbonjour_DNSServiceRemoveRecord(value handle, value recordHandle)
{
    DNSServiceRef sdRef;
    DNSRecordRef  recordRef;

    if (val_is_null(handle)) val_throw(alloc_string("handle cannot be null"));
    else if (val_is_kind(handle, k_sdRef)) sdRef = (DNSServiceRef)val_to_kind(handle, k_sdRef);
    else val_throw(alloc_string("handle must be a sdRef"));

    if (val_is_null(recordHandle)) val_throw(alloc_string("recordHandle cannot be null"));
    else if (val_is_kind(recordHandle, k_RecordRef)) recordRef = (DNSRecordRef)val_to_kind(recordHandle, k_RecordRef);
    else val_throw(alloc_string("recordHandle must be a RecordRef"));

    DNSServiceErrorType error = DNSServiceRemoveRecord(
        sdRef,
        recordRef,
        0
    );

    if (error != kDNSServiceErr_NoError)
    {
        throw_error(error);
    }

    return alloc_null();
}

DEFINE_PRIM(hxbonjour_DNSServiceRemoveRecord, 2);
