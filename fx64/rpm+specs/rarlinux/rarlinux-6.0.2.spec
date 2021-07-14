Name:       rar
Version:    6
Release:    0
Summary:    rar linux 6.0.2
Group:      Archivers
AutoReqProv:	no
#Requires:       %{name} = %{epoch}:%{version}-%{release}
URL:        https://rarlab.com 
Source0:    rarlinux-6.0.2.7z
License:    rarlabs
BuildRoot:	%{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:	x86_64

%global debug_package %{nil}

%description
#rarlinux

%prep
%setup -q

%build
#nothing to build

%install
rm -rf $RPM_BUILD_ROOT
export DONT_STRIP=1
mkdir -p $RPM_BUILD_ROOT/usr/local/bin
mkdir -p $RPM_BUILD_ROOT/usr/local/lib
cp rar unrar $RPM_BUILD_ROOT/usr/local/bin
mkdir -p $RPM_BUILD_ROOT/etc
cp rarfiles.lst $RPM_BUILD_ROOT/etc
cp default.sfx $RPM_BUILD_ROOT/usr/local/lib

%postun

%posttrans

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/etc/rarfiles.lst
/usr/local/bin/rar
/usr/local/bin/unrar
/usr/local/lib/default.sfx
%changelog
