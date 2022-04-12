The install-ldap-server will install OpenLDAP to be used for LDAP authentication. Diradm will also be installed with the script for LDAP user/group management. The install-ldap-server does not require any arguments to be ran. Wget is required to download files from the Internet. The LDAP manager password will be 'cit470' by default.

The install-nfs-server will install NFS to be used to share the /home directory with a defined network. The install-nfs-server script requires a network argument supplied in CIDR form or with a long netmask.
ex. '--network 10.2.6.1/23' or
'--network 10.2.6.1/255.255.254.0'"
The install-nfs-server will by default partition /dev/sda.

Logging of each script will be recorded inside an identical filename plus the .log extension.