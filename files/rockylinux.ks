#version=RHEL8
# Use text install
cmdline

repo --name="Minimal" --baseurl=file:///run/install/sources/mount-0000-cdrom/Minimal

%packages
@^minimal-environment
@standard
kexec-tools
%end

# Keyboard layouts
keyboard --xlayouts='us'
# System language
lang en_US.UTF-8

# Network information
network  --bootproto=dhcp --hostname=rockylinux --ipv6=auto --activate

# Use CDROM installation media
cdrom

# Run the Setup Agent on first boot
firstboot --enable

ignoredisk --only-use=sda
autopart
# Partition clearing information
clearpart --none --initlabel

# System timezone
timezone Europe/Madrid --isUtc --nontp

# Root password
rootpw --iscrypted $6$IatiLloOW4.GQhpn$dibDXTQuFJ9NutiSER2ya2JP9lhRhD1b/E2Lg1rkV5w08Xqi5OX/t4NlLhP61p2NTNCsU5UCm3GBpHKB6ctKX/
user --groups=wheel --name=zubmic --password=$6$i/mc69XM1HpsQPjq$/SfnmPyNHFtsU6gcQYP2yK/fXk1SCtEuNuD5yo9qiYa3ONlzhynSttTIbCjMviJKngByH0c4KUKsOJM.p1SxS0 --iscrypted --gecos="zubmic"

%addon com_redhat_kdump --enable --reserve-mb='auto'
%end

%anaconda
pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
%end

# Shutdown when the install is finished
poweroff