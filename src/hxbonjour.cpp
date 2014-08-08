// vim: ts=2 sw=2 et
#include <hx/CFFI.h>
#include <cstring>
#include <dns_sd.h>

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

    if (error != kDNSServiceErr_NoError)
    {
        if (error == kDNSServiceErr_BadParam) val_throw(alloc_string("kDNSServiceErr_BadParam"));
        else val_throw(alloc_string("kDNSServiceErr_Unknown"));
    }

    return alloc_string(fullName);
}

DEFINE_PRIM(hxbonjour_DNSServiceConstructFullName, 3);
