VMware ESX 6.7 VIB Installation Instructions

VMware uses a file package called a VIB (VMware Installation Bundle) as the 
mechanism for installing or upgrading software packages on an ESX server.

The file may be installed directly on an ESX server from the command line, or
through the VMware Update Manager (VUM).  


COMMAND LINE INSTALLATION

New Installation
----------------

For new installs, you should perform the following steps:

	1. Copy the VIB or offline bundle to the ESX server.  Technically, you can
           place the file anywhere that is accessible to the ESX console shell, 
           but for these instructions, we'll assume the location is in '/tmp'.

           Here's an example of using the Linux 'scp' utility to copy the file
           from a local system to an ESX server located at 10.10.10.10:
             scp VMware_bootbank_net-driver.1.1.0-1vmw.0.0.372183.vib root@10.10.10.10:/tmp

	2. Issue the following command (full path to the file must be specified):
              esxcli software vib install -v {VIBFILE}
           or
              esxcli software vib install -d {OFFLINE_BUNDLE}
       
           In the example above, this would be:
              esxcli software vib install -v /tmp/VMware_bootbank_net-driver.1.1.0-1vmw.0.0.372183.vib

Note: Depending on the certificate used to sign the VIB, you may need to
      change the host acceptance level.  To do this, use the following command:
		esxcli software acceptance set --level=<level>
      Also, depending on the type of VIB being installed, you may have to put
      ESX into maintenance mode.  This can be done through the VI Client, or by
      adding the '--maintenance-mode' option to the above esxcli command.


Upgrade Installation
--------------------

The upgrade process is similar to a new install, except the command that should
be issued is the following:

	esxcli software vib update -v {VIBFILE}
or
	esxcli software vib update -d {OFFLINE_BUNDLE}


VUM INSTALLATION

The VMware Update Manager (VUM) is a plugin for the Virtual Center Server
(vCenter Server).  You can use the VUM UI to install a VIB by importing
the associated offline bundle package (a ZIP file that contains the VIB and 
metadata).  You can then create an add-on baseline and remediate the
host(s) with this baseline.  Please see the vCenter Server documentation for
more details on VUM.
