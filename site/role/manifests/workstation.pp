class role::workstation {
  case $::kernel {
    'Linux': { include profile::linux_workstation }
    default: { warning("Unexpected kernel: '${::kernel}'") }
  }
}
