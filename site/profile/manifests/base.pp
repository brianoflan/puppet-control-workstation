class profile::base (
    $minimal_package_list = ['git', 'ruby', ],
) {
  package { $minimal_package_list:
    ensure => installed,
  }
}
