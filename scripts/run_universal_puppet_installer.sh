#!/bin/bash

# Constants
github_url='https://raw.githubusercontent.com/brianoflan/puppet-control-workstation/master/scripts' ;

main() {
  local pwd=$(pwd) ;
  local f=universal_puppet_installer.sh
  local tmpd=`mktemp -d "${TMPDIR:-/tmp}/tmp.d.XXXXXXXXXX"` ;
  cd $tmpd && wget "$github_url/$f" && bash $f ;
  cd $pwd ;
  rm -rf $tmpd ;
}

cd $(dirname $0) || { echo "ERROR with cd(dirname(\$0 = $0) = $(dirname $0)): '$?'." ; exit 1 ; } ;
main "$@" || { echo "ERROR with main(): '$?'." ; exit 1 ; } ;

#
