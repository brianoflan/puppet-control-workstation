#!/bin/bash

# Constants
# general_packages="git lsb-core" ; # not necessary
general_packages="git" ;
ubuntu_packages='' ;
centos_packages='' ;

puppet_apt_url='https://apt.puppetlabs.com'

# Derived from system
is_centos=`uname -a | egrep -i '(centos|redhat|rhel)' | egrep -i linux` ;
is_ubuntu=`uname -a | egrep -i ubuntu | egrep -i linux` ;

#

main() {
  if [[ $is_ubuntu ]] ; then
    idemAptInstalls $general_packages $ubuntu_packages ;
    local hasAptPkg=$(hasAptPkg puppet-agent) ;
    if [[ -z $hasAptPkg ]] ; then
      local osnickname=$(getOsNickname) ;
      local puppet_deb=https://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb
      local tmpd=`mktemp -d "${TMPDIR:-/tmp}/tmp.d.XXXXXXXXXX"` ;
      ( cd $tmpd && wget "$puppet_apt_url/$puppet_deb" && sudo dpkg -i $puppet_deb && sudo apt-get -y install puppet-agent ; ) ;
    fi ;
    idemGemInstall puppet ;
  else
    if [[ $is_centos ]] ; then
      idemYumInstalls $general_packages $centos_packages ;
    else
      echo "ERROR: I have no pre-configured package manager for this uname ($(uname -a))." ;
      exit 1 ;
    fi ;
  fi ;
}
execute() {
  local cmd="$@" ;
  "$@" || { echo "ERROR with execute($cmd): '$?'." ; exit 1 ; } ;
}
getOsNickname() {
  lsb_release -c | awk '{print $NF}'
}
hasAptPkg() {
  local pkg=$1 ;
  local x=`apt list --installed 2>/dev/null | egrep -v '^Listing[.][.][.]' | egrep -oh '^[a-zA-Z][a-zA-Z0-9_\-]*[^a-zA-Z0-9_\-]' | sed -e 's/[^a-zA-Z0-9_\-]$//' | perl -ne "/^\\Q$pkg\\E/ && print \$_" ` ;
  local x=`dpkg --get-selections | egrep -v $'\tdeinstall$' | egrep -oh $'^[^ \t]*' | perl -ne "/^\\Q$pkg\\E/ && print \$_" ` ;
  echo "$x" ;
}
idemGemInstall() {
  local pkg=$1 ; shift ;
  local pkgBase=`basename "$pkg"` ;
  local x=`gem list | perl -ne "m{^\\Q$pkgBase\\E(\\s|\$)} && print \$_" ` ;
  if [[ -z $x ]] ; then
    execute gem install --user-install "$pkg" "$@" ;
  fi ;
}
idemAptInstall() {
  local pkg=$1 ;
  local x=$(hasAptPkg $pkg) ;
  [[ $x ]] || execute sudo apt-get -y install "$pkg" ;
}
idemAptInstalls() {
  local pkg='' ;
  for pkg in "$@" ; do
    execute idemAptInstall "$pkg" ;
  done ;
}
idemYumInstall() {
  false ; # todo
}
idemYumInstalls() {
  local pkg='' ;
  for pkg in "$@" ; do
    execute idemAptInstall "$pkg" ;
  done ;
}

cd $(dirname $0) || { echo "ERROR with cd(dirname(\$0 = $0) = $(dirname $0)): '$?'." ; exit 1 ; } ;
main "$@" || { echo "ERROR with main(): '$?'." ; exit 1 ; } ;

#
