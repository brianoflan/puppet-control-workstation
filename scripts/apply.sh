#!/bin/bash

pdir=/etc/puppetlabs/code/environments/production ;

main() {
  source functions.sh ;
  execute cd .. ;
  initRubyGemBundler ;
  
  echo "universal_puppet_installer"
  execute bash scripts/universal_puppet_installer.sh ;
  echo ;
  
  echo "bundle install" ;
  execute bundle install ;
  echo ;
  
  echo "librarian-puppet"
  which librarian-puppet &>/dev/null || idemGemInstall librarian-puppet ;
  execute librarian-puppet install ;
  echo ;
  
  echo "puppet apply($@)"
  puppet_apply "$@" ;
  echo ;
}
puppet_apply() {
  [[ -e $pdir/README.md ]] || { sudo mv $pdir $pdir.orig && sudo mkdir $pdir ; } ;
  local x=`ls -lrt $pdir/ | egrep $'[0-9][ \t][ \t]*root[ \t]'` ;
  [[ -z $x ]] || { echo "NOTE: Found root ownership in pdir, $pdir; chown-ing." ; execute sudo chown -R $USER $pdir ; } ;

  # # # .git folder preferable for config_version.sh script:
  # execute sudo rsync -av . $pdir/ --exclude=.tmp --exclude=.git ;
  execute sudo rsync -av . $pdir/ --exclude=.tmp ;
  # # #
  
  # execute sudo puppet apply -t "$@" --modulepath='site:modules' manifests/site.pp ;
  execute sudo puppet apply -t "$@" manifests/site.pp ;
}

cd $(dirname $0) || { echo "ERROR with cd(dirname(\$0 = $0) = $(dirname $0)): '$?'." ; exit 1 ; } ;
main "$@" || { echo "ERROR with main(): '$?'." ; exit 1 ; } ;

#
