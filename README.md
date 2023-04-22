# libifaddr
Get network interface addresses with easy and simple interface in Python/Pyrex

## Function reference

    ifaddr( iface:str, family:int, mask:bool ):list
        """
        Retrieve interface addresses.

        :param iface: Interface name. Retrieve all interfaces by default.
        :param family: Address family. Compatible with socket.AF_* constants. All families by default.
        :param mask: Append mask. False by default
        :return: List of strings or None if system call fails.
        """


    ether_aton( asc:str ):int
        """
        Get 64-bit integer representation of "XX:XX:XX:XX:XX:XX" formatted string of ethernet address.

        :param asc: Ethernet address string.
        :return: 64-bit integer representation.
        """


    ether_ntoa( addr:int ):str
        """
        Get "XX:XX:XX:XX:XX:XX" formatted string representation from 64-bit integer ethernet address.

        :param addr: 64-bit integer representation.
        :return: Ethernet address string.
        """


## Example code

    from libifaddr import ifaddr, ether_ntoa, ether_aton
    import socket

    print( ifaddr() )                                # All addresses, all AF, all interfaces
    print( ifaddr("enp4s0") )                        # All addresses for enp4s0 interface
    print( ifaddr("enp4s0", socket.AF_INET, True) )  # All IPv4 addresses with masks

    MAC = ifaddr("enp4s0", socket.AF_PACKET)[0]
    print( MAC )                                     # MAC address of enp4s0

    intMAC = ether_aton(MAC)
    print( intMAC )                                  # Integer representation of the above MAC address

    print( ether_ntoa(intMAC) )                      # Restore string representation from integer

## Example code output

    ['0:0:0:0:0:0', '40:62:31:8:3a:d4', '127.0.0.1', '192.168.1.16', '::1', 'fe80::4262:31ff:fe08:3ad4']
    ['40:62:31:8:3a:d4', '192.168.1.16', 'fe80::4262:31ff:fe08:3ad4']
    ['192.168.1.16/255.255.255.0']
    40:62:31:8:3a:d4
    233345710645824
    40:62:31:8:3a:d4

## About "netifaces"
I am aware of its existence.
"libifaddr" was created mostly for internal use. I found "netifaces" too bloated for my project.
It can be also used for educational purposes due to its extreme simplicity and advanced usage of Cython language features.
