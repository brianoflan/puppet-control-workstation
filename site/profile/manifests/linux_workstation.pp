class profile::linux_workstation (
  $package_list = ['nodejs', 'nodejs-legacy', 'npm',],
  $os_specific_packages = true,
) {
  notify { 'profile::linux_workstation': }
  package { $package_list:
    ensure => installed,
  }
  if $os_specific_packages {
    case $::osfamily {
      'Debian': {
        package { ['g++', 'ruby-dev', 'lsb-core', ]:
          ensure => installed,
        }
        case $::operatingsystem {
          'Ubuntu': {
            package { ['ecryptfs-utils', ]:
              ensure => installed,
            }
          }
          default: { warning("Unexpected operatingsystem '${::operatingsystem}'.") }
        }
      }
      'RedHat': {
        package { ['gcc-c++', 'ruby-devel', ]:
          ensure => installed,
        }
      }
      default: { warning("Unexpected osfamily '${::osfamily}'.") }
    }
  }
  include ::vagrant
}
