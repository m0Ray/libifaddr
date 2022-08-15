# cython: language_level=3

from libc.stdint cimport *

# ==== Externals

# == Ethernet related

cdef extern from "<linux/if_ether.h>":

    enum:
        ETH_ALEN

cdef extern from "<net/ethernet.h>":

    cdef struct ether_addr:
        uint8_t ether_addr_octet[ETH_ALEN]

cdef extern from "<linux/if_packet.h>":

    cdef struct sockaddr_ll:
        uint8_t sll_addr[8]

cdef extern from "<netinet/ether.h>":

    char *ether_ntoa_r(const ether_addr *addr, char *buf)
    ether_addr *ether_aton_r(const char *asc, ether_addr *addr)

# == INET/INET6 related

cdef extern from "<netinet/in.h>":

    enum:
        INET_ADDRSTRLEN
        INET6_ADDRSTRLEN

cdef extern from "<sys/socket.h>":

    cdef struct sockaddr:
        uint8_t sa_family

cdef extern from "<arpa/inet.h>":

    cdef struct in_addr:
        pass

    cdef struct in6_addr:
        pass

    cdef struct sockaddr_in:
        in_addr sin_addr

    cdef struct sockaddr_in6:
        in6_addr sin6_addr

    const char *inet_ntop(int af, const void *src, char *dst, uint32_t size)

# == ifaddrs related

cdef extern from "<ifaddrs.h>":

    cdef struct ifaddrs:
        ifaddrs      *ifa_next         # Next item in list
        char         *ifa_name         # Name of interface
        unsigned int  ifa_flags        # Flags from SIOCGIFFLAGS
        sockaddr     *ifa_addr         # Address of interface
        sockaddr     *ifa_netmask      # Netmask of interface
        sockaddr     *ifa_broadaddr    # Broadcast address of interface (alias of below)
        sockaddr     *ifa_dstaddr      # Point-to-point destination address (alias of above)
        void         *ifa_data         # Address-specific data

    int getifaddrs(ifaddrs **ifap)
    void freeifaddrs(ifaddrs *ifa)

# ==== Module functions

cpdef uint64_t ether_aton(str asc)
cpdef str ether_ntoa(uint64_t addr)
cpdef ifaddr(str iface=*, int16_t family=*, bint mask=*)
