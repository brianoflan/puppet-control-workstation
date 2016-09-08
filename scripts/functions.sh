#

execute() {
  local cmd="$@" ;
  "$@" || { echo "ERROR with execute($cmd): '$?'." ; exit 1 ; } ;
}
idemAptInstall() {
  local pkg=$1 ;
  local x=`apt list --installed 2>/dev/null | egrep -v '^Listing[.][.][.]' | egrep -oh '^[a-zA-Z][a-zA-Z0-9_\-]*[^a-zA-Z0-9_\-]' | sed -e 's/[^a-zA-Z0-9_\-]$//' | perl -ne "/^\\Q$pkg\\E/ && print \$_" ` ;
  local x=`dpkg --get-selections | egrep -v $'\tdeinstall$' | egrep -oh $'^[^ \t]*' | perl -ne "/^\\Q$pkg\\E/ && print \$_" ` ;
  [[ $x ]] || execute sudo apt-get -y install "$pkg" ;
}
idemGemInstall() {
  local pkg=$1 ; shift ;
  local pkgBase=`basename "$pkg"` ;
  local x=`gem list | perl -ne "m{^\\Q$pkgBase\\E(\\s|\$)} && print \$_" ` ;
  if [[ -z $x ]] ; then
    execute gem install --user-install "$pkg" "$@" ;
  fi ;
}
initRubyGemBundler() {
  which ruby &>/dev/null || { echo "ERROR: Failed to find 'ruby'." ; exit 1 ; }
  which gem  &>/dev/null || { echo "ERROR: Failed to find 'gem'." ;  exit 1 ; }
  idemGemInstall bundler ;
  echo $PATH | egrep '[\/][.]gem[\/]ruby[\/][0-9.]*[\/]bin' || export PATH=~/.gem/ruby/2.3.0/bin:$PATH ;
}

#
