#f34: fx64 linux f34

#base dir, needs 50gb free space for larger spins: /fx64

#build config: dnf install xterm kernel-devel kernel-headers gcc binutils make mc filezilla fedora-packager fedora-review hardlink kde-filesystem optipng ImageMagick libicns-utils netpbm-progs syslinux-perl createrepo fedora-kickstarts livecd-tools firewall-config genisoimage fedora-kickstarts spin-kickstarts mock p7zip tar bzip2 zfstream zopfli httpd

#symlinking local apache in /var/../html to /fx64/live_repo: ln -s /fx64/live_repo_x64 html

#rpm build stuff: usermod -a -G mock someuser

#in rpm+specs to create rpms: fedpkg --release f34 local

#distro spin scripts: 00.live_spin_x64 00.live_spin_x64-base

#dir structure inside /fx64: live_cache_x64 live_repo_x64 live_tmp_x64

