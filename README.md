THIS SCRIPT PACKAGE IS FOR SAP HANA VM TO DETECT VSPHERE AND VSAN INFORMATION FROM VM
User can use script: install_vib_script_remotely.sh to install/update/remove the vib on the selected ESXi servers

Pre-requisite:
• Prepare a Linux environment which has SSH client and able to talk to the selected ESXi servers
• Put install_vib_script_remotely.sh and setInfo_vXXX.vib in the same directory
• The ESXi servers should have SSH service enabled
• The ESXi servers should have identical username/password

HOW TO INSTALL:
1. run "sh install_vib_script_remotely.sh -i" in the Linux server
2. input the selected ESXi servers\' hostname or IP addresses
3. input the username
4. input the password
5. wait for installation process

HOW TO UPDATE:
1. run "sh install_vib_script_remotely.sh -u" in the Linux server
2. input the selected ESXi servers' hostname or IP addresses
3. input the username
4. input the password
5. wait for updating process

HOW TO REMOVE:
1. run "sh install_vib_script_remotely.sh -r" in the Linux server
2. input the selected ESXi servers' hostname or IP addresses
3. input the username
4. input the password
5. wait for removal process

User can also directly install/update/remove the vib on the selected ESXi servers

Pre-requisite:
• SSH into the ESXi server
• put the vib file: setInfo_vXXX.vib into /tmp

HOW TO INSTALL:
1. ssh into ESXi server and run "localcli software vib install -v /tmp/setInfo_vXXX.vib"
2. wait for installation process

HOW TO UPDATE:
1. ssh into ESXi server and run "localcli software vib update -v /tmp/setInfo_vXXX.vib"
2. wait for updating process

HOW TO REMOVE:
1. ssh into ESXi server and run "localcli software vib remove --vibname setInfo"
2. wait for the removal process
