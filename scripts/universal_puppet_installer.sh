#!/bin/bash

# Constants
general_packages="lsb-core" ;
ubuntu_packages='' ;
centos_packages='' ;

# Derived from system
is_centos=`uname -a | egrep -i '(centos|redhat|rhel)' | egrep -i linux` ;
is_ubuntu=`uname -a | egrep -i ubuntu | egrep -i linux` ;

#

main() {
  if [[ $is_ubuntu ]] ; then
    idemAptInstalls $general_packages $ubuntu_packages ;
    local osnickname=`lsb_release -a` ;
    echo "osnickname = $osnickname" ;
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
idemYumInstalls() {
  local pkg='' ;
  for pkg in "$@" ; do
    execute idemAptInstall "$pkg" ;
  done ;
}
idemYumInstall() {
  false ; # todo
}
idemAptInstalls() {
  local pkg='' ;
  for pkg in "$@" ; do
    execute idemAptInstall "$pkg" ;
  done ;
}
idemAptInstall() {
  local pkg=$1 ;
  local x=`apt list --installed 2>/dev/null | egrep -v '^Listing[.][.][.]' | egrep -oh '^[a-zA-Z][a-zA-Z0-9_\-]*[^a-zA-Z0-9_\-]' | sed -e 's/[^a-zA-Z0-9_\-]$//' | perl -ne "/^\\Q$pkg\\E/ && print \$_" ` ;
  local x=`dpkg --get-selections | egrep -v $'\tdeinstall$' | egrep -oh $'^[^ \t]*' | perl -ne "/^\\Q$pkg\\E/ && print \$_" ` ;
  [[ $x ]] || execute sudo apt-get -y install "$pkg" ;
}

cd $(dirname $0) || { echo "ERROR with cd(dirname(\$0 = $0) = $(dirname $0)): '$?'." ; exit 1 ; } ;
main "$@" || { echo "ERROR with main(): '$?'." ; exit 1 ; } ;

#
