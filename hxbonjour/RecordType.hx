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
package hxbonjour;

enum RecordType
{
    A;          // Host address.
    Ns;         // Authoritative server.
    Md;         // Mail destination.
    Mf;         // Mail forwarder.
    Cname;      // Canonical name.
    Soa;        // Start of authority zone.
    Mb;         // Mailbox domain name.
    Mg;         // Mail group member.
    Mr;         // Mail rename name.
    Null;       // Null resource record.
    Wks;        // Well known service.
    Ptr;        // Domain name pointer.
    Hinfo;      // Host information.
    Minfo;      // Mailbox information.
    Mx;         // Mail routing information.
    Txt;        // One or more text strings (NOT "zero or more...").
    Rp;         // Responsible person.
    Afsdb;      // AFS cell database.
    X25;        // X_25 calling address.
    Isdn;       // ISDN calling address.
    Rt;         // Router.
    Nsap;       // NSAP address.
    Nsap_ptr;   // Reverse NSAP lookup (deprecated).
    Sig;        // Security signature.
    Key;        // Security key.
    Px;         // X.400 mail mapping.
    Gpos;       // Geographical position (withdrawn).
    Aaaa;       // IPv6 Address.
    Loc;        // Location Information.
    Nxt;        // Next domain (security).
    Eid;        // Endpoint identifier.
    Nimloc;     // Nimrod Locator.
    Srv;        // Server Selection.
    Atma;       // ATM Address
    Naptr;      // Naming Authority PoinTeR
    Kx;         // Key Exchange
    Cert;       // Certification record
    A6;         // IPv6 Address (deprecated)
    Dname;      // Non-terminal DNAME (for IPv6)
    Sink;       // Kitchen sink (experimental)
    Opt;        // EDNS0 option (meta-RR)
    Apl;        // Address Prefix List
    Ds;         // Delegation Signer
    Sshfp;      // SSH Key Fingerprint
    Ipseckey;   // IPSECKEY
    Rrsig;      // RRSIG
    Nsec;       // Denial of Existence
    Dnskey;     // DNSKEY
    Dhcid;      // DHCP Client Identifier
    Nsec3;      // Hashed Authenticated Denial of Existence
    Nsec3param; // Hashed Authenticated Denial of Existence

    Hip;        // Host Identity Protocol

    Spf;        // Sender Policy Framework for E-Mail
    Uinfo;      // IANA-Reserved
    Uid;        // IANA-Reserved
    Gid;        // IANA-Reserved
    Unspec;     // IANA-Reserved

    Tkey;       // Transaction key
    Tsig;       // Transaction signature.
    Ixfr;       // Incremental zone transfer.
    Axfr;       // Transfer zone of authority.
    Mailb;      // Transfer mailbox records.
    Maila;      // Transfer mail agent records.
    Any;        // Wildcard match.
}

class RecordTypeUtil
{
    public static function toInt(recordType:RecordType):Int
    {
        return switch (recordType)
        {
            case A:            1; // Host address.
            case Ns:           2; // Authoritative server.
            case Md:           3; // Mail destination.
            case Mf:           4; // Mail forwarder.
            case Cname:        5; // Canonical name.
            case Soa:          6; // Start of authority zone.
            case Mb:           7; // Mailbox domain name.
            case Mg:           8; // Mail group member.
            case Mr:           9; // Mail rename name.
            case Null:        10; // Null resource record.
            case Wks:         11; // Well known service.
            case Ptr:         12; // Domain name pointer.
            case Hinfo:       13; // Host information.
            case Minfo:       14; // Mailbox information.
            case Mx:          15; // Mail routing information.
            case Txt:         16; // One or more text strings (NOT "zero or more...").
            case Rp:          17; // Responsible person.
            case Afsdb:       18; // AFS cell database.
            case X25:         19; // X_25 calling address.
            case Isdn:        20; // ISDN calling address.
            case Rt:          21; // Router.
            case Nsap:        22; // NSAP address.
            case Nsap_ptr:    23; // Reverse NSAP lookup (deprecated).
            case Sig:         24; // Security signature.
            case Key:         25; // Security key.
            case Px:          26; // X.400 mail mapping.
            case Gpos:        27; // Geographical position (withdrawn).
            case Aaaa:        28; // IPv6 Address.
            case Loc:         29; // Location Information.
            case Nxt:         30; // Next domain (security).
            case Eid:         31; // Endpoint identifier.
            case Nimloc:      32; // Nimrod Locator.
            case Srv:         33; // Server Selection.
            case Atma:        34; // ATM Address
            case Naptr:       35; // Naming Authority PoinTeR
            case Kx:          36; // Key Exchange
            case Cert:        37; // Certification record
            case A6:          38; // IPv6 Address (deprecated)
            case Dname:       39; // Non-terminal DNAME (for IPv6)
            case Sink:        40; // Kitchen sink (experimental)
            case Opt:         41; // EDNS0 option (meta-RR)
            case Apl:         42; // Address Prefix List
            case Ds:          43; // Delegation Signer
            case Sshfp:       44; // SSH Key Fingerprint
            case Ipseckey:    45; // IPSECKEY
            case Rrsig:       46; // RRSIG
            case Nsec:        47; // Denial of Existence
            case Dnskey:      48; // DNSKEY
            case Dhcid:       49; // DHCP Client Identifier
            case Nsec3:       50; // Hashed Authenticated Denial of Existence
            case Nsec3param:  51; // Hashed Authenticated Denial of Existence

            case Hip:         55; // Host Identity Protocol

            case Spf:         99; // Sender Policy Framework for E-Mail
            case Uinfo:      100; // IANA-Reserved
            case Uid:        101; // IANA-Reserved
            case Gid:        102; // IANA-Reserved
            case Unspec:     103; // IANA-Reserved

            case Tkey:       249; // Transaction key
            case Tsig:       250; // Transaction signature.
            case Ixfr:       251; // Incremental zone transfer.
            case Axfr:       252; // Transfer zone of authority.
            case Mailb:      253; // Transfer mailbox records.
            case Maila:      254; // Transfer mail agent records.
            case Any:        255; // Wildcard match.
        };
    }

    public static function ToRecordType(recordType:Int):RecordType
    {
        return switch (recordType)
        {
            case   1: A;          // Host address.
            case   2: Ns;         // Authoritative server.
            case   3: Md;         // Mail destination.
            case   4: Mf;         // Mail forwarder.
            case   5: Cname;      // Canonical name.
            case   6: Soa;        // Start of authority zone.
            case   7: Mb;         // Mailbox domain name.
            case   8: Mg;         // Mail group member.
            case   9: Mr;         // Mail rename name.
            case  10: Null;       // Null resource record.
            case  11: Wks;        // Well known service.
            case  12: Ptr;        // Domain name pointer.
            case  13: Hinfo;      // Host information.
            case  14: Minfo;      // Mailbox information.
            case  15: Mx;         // Mail routing information.
            case  16: Txt;        // One or more text strings (NOT "zero or more...").
            case  17: Rp;         // Responsible person.
            case  18: Afsdb;      // AFS cell database.
            case  19: X25;        // X_25 calling address.
            case  20: Isdn;       // ISDN calling address.
            case  21: Rt;         // Router.
            case  22: Nsap;       // NSAP address.
            case  23: Nsap_ptr;   // Reverse NSAP lookup (deprecated).
            case  24: Sig;        // Security signature.
            case  25: Key;        // Security key.
            case  26: Px;         // X.400 mail mapping.
            case  27: Gpos;       // Geographical position (withdrawn).
            case  28: Aaaa;       // IPv6 Address.
            case  29: Loc;        // Location Information.
            case  30: Nxt;        // Next domain (security).
            case  31: Eid;        // Endpoint identifier.
            case  32: Nimloc;     // Nimrod Locator.
            case  33: Srv;        // Server Selection.
            case  34: Atma;       // ATM Address
            case  35: Naptr;      // Naming Authority PoinTeR
            case  36: Kx;         // Key Exchange
            case  37: Cert;       // Certification record
            case  38: A6;         // IPv6 Address (deprecated)
            case  39: Dname;      // Non-terminal DNAME (for IPv6)
            case  40: Sink;       // Kitchen sink (experimental)
            case  41: Opt;        // EDNS0 option (meta-RR)
            case  42: Apl;        // Address Prefix List
            case  43: Ds;         // Delegation Signer
            case  44: Sshfp;      // SSH Key Fingerprint
            case  45: Ipseckey;   // IPSECKEY
            case  46: Rrsig;      // RRSIG
            case  47: Nsec;       // Denial of Existence
            case  48: Dnskey;     // DNSKEY
            case  49: Dhcid;      // DHCP Client Identifier
            case  50: Nsec3;      // Hashed Authenticated Denial of Existence
            case  51: Nsec3param; // Hashed Authenticated Denial of Existence

            case  55: Hip;        // Host Identity Protocol

            case  99: Spf;        // Sender Policy Framework for E-Mail
            case 100: Uinfo;      // IANA-Reserved
            case 101: Uid;        // IANA-Reserved
            case 102: Gid;        // IANA-Reserved
            case 103: Unspec;     // IANA-Reserved

            case 249: Tkey;       // Transaction key
            case 250: Tsig;       // Transaction signature.
            case 251: Ixfr;       // Incremental zone transfer.
            case 252: Axfr;       // Transfer zone of authority.
            case 253: Mailb;      // Transfer mailbox records.
            case 254: Maila;      // Transfer mail agent records.
            case 255: Any;        // Wildcard match.
            default: throw "Invalid recordType value: " + recordType;
        };
    }
}
