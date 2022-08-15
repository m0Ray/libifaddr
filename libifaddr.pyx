# cython: language_level=3

from libc.string cimport memset
from cpython.mem cimport PyMem_Malloc, PyMem_Free
import socket


"""
    Get 64-bit integer representation of "XX:XX:XX:XX:XX:XX" formatted string of ethernet address.

    :param asc: Ethernet address string.
    :return: 64-bit integer representation.
"""
cpdef uint64_t ether_aton(str asc):

    cdef uint64_t result
    memset(&result, 0, 8)

    cdef bytes bstr = asc.encode("UTF-8")

    cdef char *cstr = bstr

    ether_aton_r(cstr, <ether_addr *>&result)

    return result

"""
    Get "XX:XX:XX:XX:XX:XX" formatted string representation from 64-bit integer ethernet address.

    :param addr: 64-bit integer representation.
    :return: Ethernet address string.
"""
cpdef str ether_ntoa(uint64_t addr):

    cdef bytes result

    cdef char *cstr = <char *>PyMem_Malloc(24)

    ether_ntoa_r(<ether_addr *>&addr, cstr)

    result = <bytes>cstr

    PyMem_Free(<void *>cstr)

    return result.decode("UTF-8")

"""
    Retrieve interface addresses.

    :param iface: Interface name. Retrieve all interfaces by default.
    :param family: Address family. Compatible with socket.AF_* constants. All families by default.
    :param mask: Append mask. False by default
    :return: Address string list
"""
cpdef list ifaddr(str iface="", int16_t family=-1, bint mask=False):

    cdef list result = []
    cdef bint filter_iface = len(iface)>0
    cdef bint filter_family = family>=0
    cdef ifaddrs *chain
    cdef ifaddrs *ptr
    cdef bytes bifname
    cdef str ifname
    cdef bytes baddr
    cdef char *caddr
    cdef char *ret
    cdef sockaddr_ll *sll
    cdef sockaddr_in *sa
    cdef sockaddr_in6 *sa6

    if getifaddrs(&chain) == 0:

        ptr = chain

        while ptr != NULL:

            if filter_iface:
                bifname = <bytes>ptr.ifa_name
                ifname = bifname.decode("UTF-8")

            if (not filter_iface or ifname==iface) and (not filter_family or ptr.ifa_addr.sa_family==family):

                if   ptr.ifa_addr.sa_family == socket.AF_PACKET:
                    caddr = <char *>PyMem_Malloc(ETH_ALEN*3)
                    sll = <sockaddr_ll *>(ptr.ifa_addr)
                    ret = ether_ntoa_r(<ether_addr *>(&sll.sll_addr), caddr)
                    if ret != NULL:
                        baddr = <bytes> caddr
                        result.append( baddr.decode("UTF-8") )
                    PyMem_Free(caddr)

                elif ptr.ifa_addr.sa_family == socket.AF_INET6:

                    caddr = <char *>PyMem_Malloc(INET6_ADDRSTRLEN)
                    sa6 =  <sockaddr_in6 *>(ptr.ifa_addr)
                    ret = inet_ntop(ptr.ifa_addr.sa_family, <void *>(&sa6.sin6_addr), caddr, INET6_ADDRSTRLEN)
                    if ret != NULL:
                        baddr = <bytes> caddr
                        if mask:
                            sa6 =  <sockaddr_in6 *>(ptr.ifa_netmask)
                            ret = inet_ntop(ptr.ifa_addr.sa_family, <void *>(&sa6.sin6_addr), caddr, INET6_ADDRSTRLEN)
                            if ret != NULL:
                                baddr += b"/" + <bytes> caddr
                        result.append( baddr.decode("UTF-8") )
                    PyMem_Free(caddr)

                elif ptr.ifa_addr.sa_family == socket.AF_INET:

                    caddr = <char *>PyMem_Malloc(INET_ADDRSTRLEN)
                    sa =  <sockaddr_in *>(ptr.ifa_addr)
                    ret = inet_ntop(ptr.ifa_addr.sa_family, <void *>(&sa.sin_addr), caddr, INET_ADDRSTRLEN)
                    if ret != NULL:
                        baddr = <bytes> caddr
                        if mask:
                            sa =  <sockaddr_in *>(ptr.ifa_netmask)
                            ret = inet_ntop(ptr.ifa_addr.sa_family, <void *>(&sa.sin_addr), caddr, INET_ADDRSTRLEN)
                            if ret != NULL:
                                baddr += b"/" + <bytes> caddr
                        result.append( baddr.decode("UTF-8") )
                    PyMem_Free(caddr)

            ptr = ptr.ifa_next

        freeifaddrs(chain)

        return result
