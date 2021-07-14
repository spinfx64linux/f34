lang en_US.UTF-8
keyboard us

timezone Europe/Budapest --isUtc

auth --useshadow --passalgo=sha512
selinux --enforcing
firewall --enabled --service=mdns,sshd

xconfig --startxonboot
zerombr
clearpart --all
part / --size 20000 --fstype ext3

services --enabled=NetworkManager,ModemManager,sshd,chronyd
network --bootproto=dhcp --device=link --activate
shutdown

firstboot --disable
#rootpw --lock --plaintext locked

%addon com_redhat_kdump --disable --reserve-mb='128'

%end

#url --mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=fedora-$releasever&arch=$basearch
#url --baseurl=http://localhost/ --cost=5

repo --name="flive0" --baseurl=http://localhost/ --cost=10

repo --name="fedora" --mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=fedora-34&arch=$basearch --cost=20
repo --name="updates" --mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=updates-released-f34&arch=$basearch --cost=30

repo --name="rf" --mirrorlist=http://mirrors.rpmfusion.org/mirrorlist?repo=free-fedora-34&arch=$basearch --cost=40
repo --name="rfu" --mirrorlist=http://mirrors.rpmfusion.org/mirrorlist?repo=free-fedora-updates-released-34&arch=$basearch --cost=50

repo --name="rn" --mirrorlist=http://mirrors.rpmfusion.org/mirrorlist?repo=nonfree-fedora-34&arch=$basearch --cost=60
repo --name="rnu" --mirrorlist=http://mirrors.rpmfusion.org/mirrorlist?repo=nonfree-fedora-updates-released-34&arch=$basearch --cost=70

repo --name="chrome" --baseurl=http://dl.google.com/linux/chrome/rpm/stable/x86_64 --cost=90

repo --name="skype" --baseurl=https://repo.skype.com/rpm/stable/ --cost=170

#repo --name="rpmspherebase" --baseurl=https://raw.githubusercontent.com/rpmsphere/x86_64/master --cost=180
#repo --name="rpmspherenoarch" --baseurl=https://raw.githubusercontent.com/rpmsphere/noarch/master --cost=190

%packages
@anaconda-tools
@base-x
@core
#@dial-up
@firefox
@fonts
##@gnome-desktop
@guest-desktop-agents
#@hardware-support
@input-methods
@libreoffice
@multimedia
@printing
@standard
@cinnamon-desktop
@networkmanager-submodules

parole
initscripts
chkconfig
usermode
basesystem

kernel
kernel-devel
kernel-headers
kernel-modules
kernel-modules-extra

anaconda
anaconda-install-env-deps
anaconda-live
##checkisomd5

#fedora-release-common
fedora-release-cinnamon

aajohan-comfortaa-fonts
elfutils-libelf-devel
lightdm
dnf-plugins-core
fuse-exfat
fuse-dislocker
glibc-all-langpacks
-glibc-2.29.9000-4*
-glibc-all-langpacks-2.29.9000-4*

firewall-config

memtest86+
xterm

dracut
dracut-live
syslinux
grub2-efi
#fluxbox

lm_sensors
tuned
lvm2

make
gcc
binutils

smartmontools

mc

tar
gzip
bzip2
zip
p7zip
p7zip-plugins
unzip
unrar

chntpw

dd_rescue
ddrescue
dosfstools
ntfs-3g
ntfsprogs
fsarchiver
parted
#partimage
testdisk
gparted

nemo
-nemo-extension-xreader
xreader
mencoder
mplayer

thunderbird
filezilla
putty
-deluge
pidgin
hexchat

mozilla-noscript
#mozilla-adblockplus

keepassx

#k3b
nrg2iso
#dvdrip
#AcetoneISO
devedeng
dvd95
grip

pavucontrol
pavumeter

#streamtuner
#streamripper

audacity-freeworld
avidemux
audacious-plugins
#audacious-plugins-freeworld-mp3
audacious-plugins-freeworld
audacious-plugins-freeworld-aac
faad2

#xine-ui
#xine-lib
#xine-lib-extras
#xine-lib-extras-freeworld

ffmpeg
ffmpeg-libs
x264
h264enc
x264-libs
x265
x265-libs
libde265
flac
lame
twolame
ImageMagick
libid3tag

audacious-libs
icedtea-web
java-openjdk
qbittorrent
plank

libnsl.x86_64
libnsl2.x86_64

libstdc++

gimp
vlc
vlc-extras

youtube-dl

google-chrome-stable
rpmfusion-free-release
rpmfusion-nonfree-release

#openssl-devel
#openssl-libs

googlekey-1-1
skypeforlinux
#viber-13.3.1.22-2
rar-6-0
###fx64repo

-transmission
%end

#%anaconda
#pwpolicy root --minlen=6 --minquality=1 --notstrict --changesok --emptyok
#pwpolicy user --minlen=6 --minquality=1 --notstrict --changesok --emptyok
#%end

%post
# FIXME: it'd be better to get this installed from a package
cat > /etc/rc.d/init.d/livesys << EOF
#!/bin/bash
#
# live: Init script for live image
#
# chkconfig: 345 00 99
# description: Init script for live image.
### BEGIN INIT INFO
# X-Start-Before: display-manager chronyd
### END INIT INFO

. /etc/init.d/functions

if ! strstr "\`cat /proc/cmdline\`" rd.live.image || [ "\$1" != "start" ]; then
    exit 0
fi

if [ -e /.liveimg-configured ] ; then
    configdone=1
fi

exists() {
    which \$1 >/dev/null 2>&1 || return
    \$*
}

livedir="LiveOS"
for arg in \`cat /proc/cmdline\` ; do
  if [ "\${arg##rd.live.dir=}" != "\${arg}" ]; then
    livedir=\${arg##rd.live.dir=}
    continue
  fi
  if [ "\${arg##live_dir=}" != "\${arg}" ]; then
    livedir=\${arg##live_dir=}
  fi
done

# enable swaps unless requested otherwise
swaps=\`blkid -t TYPE=swap -o device\`
if ! strstr "\`cat /proc/cmdline\`" noswap && [ -n "\$swaps" ] ; then
  for s in \$swaps ; do
    action "Enabling swap partition \$s" swapon \$s
  done
fi
if ! strstr "\`cat /proc/cmdline\`" noswap && [ -f /run/initramfs/live/\${livedir}/swap.img ] ; then
  action "Enabling swap file" swapon /run/initramfs/live/\${livedir}/swap.img
fi

mountPersistentHome() {
  # support label/uuid
  if [ "\${homedev##LABEL=}" != "\${homedev}" -o "\${homedev##UUID=}" != "\${homedev}" ]; then
    homedev=\`/sbin/blkid -o device -t "\$homedev"\`
  fi

  # if we're given a file rather than a blockdev, loopback it
  if [ "\${homedev##mtd}" != "\${homedev}" ]; then
    # mtd devs don't have a block device but get magic-mounted with -t jffs2
    mountopts="-t jffs2"
  elif [ ! -b "\$homedev" ]; then
    loopdev=\`losetup -f\`
    if [ "\${homedev##/run/initramfs/live}" != "\${homedev}" ]; then
      action "Remounting live store r/w" mount -o remount,rw /run/initramfs/live
    fi
    losetup \$loopdev \$homedev
    homedev=\$loopdev
  fi

  # if it's encrypted, we need to unlock it
  if [ "\$(/sbin/blkid -s TYPE -o value \$homedev 2>/dev/null)" = "crypto_LUKS" ]; then
    echo
    echo "Setting up encrypted /home device"
    plymouth ask-for-password --command="cryptsetup luksOpen \$homedev EncHome"
    homedev=/dev/mapper/EncHome
  fi

  # and finally do the mount
  mount \$mountopts \$homedev /home
  # if we have /home under what's passed for persistent home, then
  # we should make that the real /home.  useful for mtd device on olpc
  if [ -d /home/home ]; then mount --bind /home/home /home ; fi
  [ -x /sbin/restorecon ] && /sbin/restorecon /home
  if [ -d /home/liveuser ]; then USERADDARGS="-M" ; fi
}

findPersistentHome() {
  for arg in \`cat /proc/cmdline\` ; do
    if [ "\${arg##persistenthome=}" != "\${arg}" ]; then
      homedev=\${arg##persistenthome=}
    fi
  done
}

if strstr "\`cat /proc/cmdline\`" persistenthome= ; then
  findPersistentHome
elif [ -e /run/initramfs/live/\${livedir}/home.img ]; then
  homedev=/run/initramfs/live/\${livedir}/home.img
fi

# if we have a persistent /home, then we want to go ahead and mount it
if ! strstr "\`cat /proc/cmdline\`" nopersistenthome && [ -n "\$homedev" ] ; then
  action "Mounting persistent /home" mountPersistentHome
fi

if [ -n "\$configdone" ]; then
  exit 0
fi

# add liveuser user with no passwd
action "Adding live user" useradd \$USERADDARGS -c "Live System User" liveuser
passwd -d liveuser > /dev/null
usermod -aG wheel liveuser > /dev/null

# Remove root password lock
passwd -d root > /dev/null

# turn off firstboot for livecd boots
systemctl --no-reload disable firstboot-text.service 2> /dev/null || :
systemctl --no-reload disable firstboot-graphical.service 2> /dev/null || :
systemctl stop firstboot-text.service 2> /dev/null || :
systemctl stop firstboot-graphical.service 2> /dev/null || :

# don't use prelink on a running live image
sed -i 's/PRELINKING=yes/PRELINKING=no/' /etc/sysconfig/prelink &>/dev/null || :

# turn off mdmonitor by default
systemctl --no-reload disable mdmonitor.service 2> /dev/null || :
systemctl --no-reload disable mdmonitor-takeover.service 2> /dev/null || :
systemctl stop mdmonitor.service 2> /dev/null || :
systemctl stop mdmonitor-takeover.service 2> /dev/null || :

# don't enable the gnome-settings-daemon packagekit plugin
gsettings set org.gnome.software download-updates 'false' || :

# don't start cron/at as they tend to spawn things which are
# disk intensive that are painful on a live image
systemctl --no-reload disable crond.service 2> /dev/null || :
systemctl --no-reload disable atd.service 2> /dev/null || :
systemctl stop crond.service 2> /dev/null || :
systemctl stop atd.service 2> /dev/null || :

# turn off abrtd on a live image
systemctl --no-reload disable abrtd.service 2> /dev/null || :
systemctl stop abrtd.service 2> /dev/null || :

# Don't sync the system clock when running live (RHBZ #1018162)
sed -i 's/rtcsync//' /etc/chrony.conf

# Mark things as configured
touch /.liveimg-configured

# add static hostname to work around xauth bug
# https://bugzilla.redhat.com/show_bug.cgi?id=679486
# the hostname must be something else than 'localhost'
# https://bugzilla.redhat.com/show_bug.cgi?id=1370222
echo "localhost-live" > /etc/hostname

EOF

# bah, hal starts way too late
cat > /etc/rc.d/init.d/livesys-late << EOF
#!/bin/bash
#
# live: Late init script for live image
#
# chkconfig: 345 99 01
# description: Late init script for live image.

. /etc/init.d/functions

if ! strstr "\`cat /proc/cmdline\`" rd.live.image || [ "\$1" != "start" ] || [ -e /.liveimg-late-configured ] ; then
    exit 0
fi

exists() {
    which \$1 >/dev/null 2>&1 || return
    \$*
}

touch /.liveimg-late-configured

# read some variables out of /proc/cmdline
for o in \`cat /proc/cmdline\` ; do
    case \$o in
    ks=*)
        ks="--kickstart=\${o#ks=}"
        ;;
    xdriver=*)
        xdriver="\${o#xdriver=}"
        ;;
    esac
done

# if liveinst or textinst is given, start anaconda
if strstr "\`cat /proc/cmdline\`" liveinst ; then
   plymouth --quit
   /usr/sbin/liveinst \$ks
fi
if strstr "\`cat /proc/cmdline\`" textinst ; then
   plymouth --quit
   /usr/sbin/liveinst --text \$ks
fi

# configure X, allowing user to override xdriver
if [ -n "\$xdriver" ]; then
   cat > /etc/X11/xorg.conf.d/00-xdriver.conf <<FOE
Section "Device"
	Identifier	"Videocard0"
	Driver	"\$xdriver"
EndSection
FOE
fi

EOF

chmod 755 /etc/rc.d/init.d/livesys
/sbin/restorecon /etc/rc.d/init.d/livesys
/sbin/chkconfig --add livesys

chmod 755 /etc/rc.d/init.d/livesys-late
/sbin/restorecon /etc/rc.d/init.d/livesys-late
/sbin/chkconfig --add livesys-late

# enable tmpfs for /tmp
systemctl enable tmp.mount

# make it so that we don't do writing to the overlay for things which
# are just tmpdirs/caches
# note https://bugzilla.redhat.com/show_bug.cgi?id=1135475
cat >> /etc/fstab << EOF
vartmp   /var/tmp    tmpfs   defaults   0  0
EOF

# work around for poor key import UI in PackageKit
rm -f /var/lib/rpm/__db*
releasever=$(rpm -q --qf '%{version}\n' --whatprovides system-release)
basearch=$(uname -i)
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-$releasever-$basearch
rpm --import /etc/pki/rpm-gpg/linux_signing_key.pub
echo "Packages within this LiveCD"
rpm -qa
# Note that running rpm recreates the rpm db files which aren't needed or wanted
rm -f /var/lib/rpm/__db*

# go ahead and pre-make the man -k cache (#455968)
/usr/bin/mandb

# make sure there aren't core files lying around
rm -f /core*

# remove random seed, the newly installed instance should make it's own
rm -f /var/lib/systemd/random-seed

# convince readahead not to collect
# FIXME: for systemd

echo 'File created by kickstart. See systemd-update-done.service(8).' \
    | tee /etc/.updated >/var/.updated

# Drop the rescue kernel and initramfs, we don't need them on the live media itself.
# See bug 1317709
rm -f /boot/*-rescue*

# Disable network service here, as doing it in the services line
# fails due to RHBZ #1369794
/sbin/chkconfig network off

# Remove machine-id on pre generated images
rm -f /etc/machine-id
touch /etc/machine-id

%end


%post --nochroot
cp $INSTALL_ROOT/usr/share/licenses/*-release/* $LIVE_ROOT/

# only works on x86, x86_64
if [ "$(uname -i)" = "i386" -o "$(uname -i)" = "x86_64" ]; then
    # For livecd-creator builds
    if [ ! -d $LIVE_ROOT/LiveOS ]; then mkdir -p $LIVE_ROOT/LiveOS ; fi
    cp /usr/bin/livecd-iso-to-disk $LIVE_ROOT/LiveOS

    # For lorax/livemedia-creator builds
    sed -i '
    /## make boot.iso/ i\
    # Add livecd-iso-to-disk script to .iso filesystem at /LiveOS/\
    <% f = "usr/bin/livecd-iso-to-disk" %>\
    %if exists(f):\
        install ${f} ${LIVEDIR}/${f|basename}\
    %endif\
    ' /usr/share/lorax/templates.d/99-generic/live/x86.tmpl
fi

%end



