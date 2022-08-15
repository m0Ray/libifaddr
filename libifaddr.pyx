# cython: language_level=3

from libc.string cimport memset
from cpython.mem cimport PyMem_Malloc, PyMem_Free
import socket

cpdef uint64_t ether_aton(str asc):

    cdef uint64_t result
    memset(&result, 0, 8)

    cdef bytes bstr = asc.encode("UTF-8")

    cdef char *cstr = bstr

    ether_aton_r(cstr, <ether_addr *>&result)

    return result

cpdef str ether_ntoa(uint64_t addr):

    cdef bytes result

    cdef char *cstr = <char *>PyMem_Malloc(24)

    ether_ntoa_r(<ether_addr *>&addr, cstr)

    result = <bytes>cstr

    PyMem_Free(<void *>cstr)

    return result.decode("UTF-8")

cpdef list ifaddr(str iface="", int16_t family=-1, bint mask=False):

    cdef bint filter_iface = len(iface)>0
    cdef bint filter_family = family>=0
    cdef ifaddrs *chain
    cdef ifaddrs *ptr
    cdef bytes bname
    cdef str pyname
    cdef list addr = []
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
                bname = <bytes>ptr.ifa_name
                pyname = bname.decode("UTF-8")

            if (not filter_iface or pyname==iface) and (not filter_family or ptr.ifa_addr.sa_family==family):

                if   ptr.ifa_addr.sa_family == socket.AF_PACKET:
                    caddr = <char *>PyMem_Malloc(ETH_ALEN*3)
                    sll = <sockaddr_ll *>(ptr.ifa_addr)
                    ret = ether_ntoa_r(<ether_addr *>(&sll.sll_addr), caddr)
                    if ret != NULL:
                        baddr = <bytes> caddr
                        addr.append( baddr.decode("UTF-8") )
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
                        addr.append( baddr.decode("UTF-8") )
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
                        addr.append( baddr.decode("UTF-8") )
                    PyMem_Free(caddr)

            ptr = ptr.ifa_next

        freeifaddrs(chain)

        return addr
