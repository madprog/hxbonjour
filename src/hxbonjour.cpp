// vim: ts=2 sw=2 et
#include <hx/CFFI.h>
#include <cstring>
#include <dns_sd.h>

DEFINE_KIND(k_sdRef);

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

    return alloc_null();
}

DEFINE_PRIM(hxbonjour_init, 0);

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

    if (!val_is_string(regtype))
        val_throw(alloc_string("regtype cannot be null"));

    if (!val_is_string(domain))
        val_throw(alloc_string("domain cannot be null"));

    if (val_is_null(service)) _service = NULL;
    else if (!val_is_string(service))
        val_throw(alloc_string("service must be a string"));
    else _service = val_get_string(service);

    _regtype = val_get_string(regtype);
    _domain = val_get_string(domain);

    bool regtype_format_ok = _regtype[0] == '_';
    if (regtype_format_ok)
    {
        const char *dot_pos = strchr(_regtype, '.');
        if (dot_pos != NULL)
        {
            regtype_format_ok = !strncmp(dot_pos, "._tcp", 6) || !strncmp(dot_pos, "._udp", 6);
        }
    }

    if (!regtype_format_ok)
        val_throw(alloc_string("regtype should be in the form _proto._(tcp|udp)"));

    error = DNSServiceConstructFullName(fullName, _service, _regtype, _domain);

    if (error != kDNSServiceErr_NoError) throw_error(error);

    return alloc_string(fullName);
}

DEFINE_PRIM(hxbonjour_DNSServiceConstructFullName, 3);

void DNSSD_API hxbonjour_DNSServiceEnumerateDomains_callback(DNSServiceRef sdRef, DNSServiceFlags flags, uint32_t interfaceIndex, DNSServiceErrorType errorCode, const char *replyDomain, void *context)
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

value hxbonjour_DNSServiceEnumerateDomains(value flags, value callBack)
{
    DNSServiceRef sdRef = NULL;
    DNSServiceFlags _flags = val_int(flags);

    DNSServiceErrorType error = DNSServiceEnumerateDomains(&sdRef, _flags, kDNSServiceInterfaceIndexAny, hxbonjour_DNSServiceEnumerateDomains_callback, callBack);

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
    DNSServiceRef sdRef = (DNSServiceRef)val_to_kind(handle, k_sdRef);

    DNSServiceRefDeallocate(sdRef);

    return alloc_null();
}

DEFINE_PRIM(hxbonjour_DNSServiceRefDeallocate, 1);

value hxbonjour_DNSServiceProcessResult(value handle, value timeout)
{
    if (!val_is_kind(handle, k_sdRef))
        val_throw(alloc_string("handle must be a sdRef"));

    DNSServiceRef sdRef = (DNSServiceRef)val_to_kind(handle, k_sdRef);

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
