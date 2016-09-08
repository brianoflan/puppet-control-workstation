#!/bin/bash

main() {
  source functions.sh ;
  execute cd .. ;
  initRubyGemBundler ;
  bash universal_puppet_installer.sh ;
  
  which librarian-puppet || idemGemInstall librarian-puppet ;
  execute librarian-puppet install ;
  execute puppet apply -t "$@" --modulepath='site:modules' manifests/site.pp ;
}

cd $(dirname $0) || { echo "ERROR with cd(dirname(\$0 = $0) = $(dirname $0)): '$?'." ; exit 1 ; } ;
main "$@" || { echo "ERROR with main(): '$?'." ; exit 1 ; } ;

#
