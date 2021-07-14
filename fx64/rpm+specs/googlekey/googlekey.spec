Name:       googlekey
Version:    1
Release:    1
Summary:    googlekey
Group:      pubkey
AutoReqProv:	no
#Requires:       %{name} = %{epoch}:%{version}-%{release}
URL:        https://www.google.com/linuxrepositories/
Source0:    googlekey-1.1.zip
License:    google
BuildRoot:	%{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:	noarch


%description
#googlekey

%prep
%setup -q

%build
#nothing to build

%install
rm -rf $RPM_BUILD_ROOT
export DONT_STRIP=1
mkdir -p $RPM_BUILD_ROOT/etc/pki/rpm-gpg/
cp linux_signing_key.pub $RPM_BUILD_ROOT/etc/pki/rpm-gpg/
#rpm --import $RPM_BUILD_ROOT/etc/pki/rpm-gpg/linux_signing_key.pub
%postun

%posttrans

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/etc/pki/rpm-gpg/linux_signing_key.pub

%changelog
