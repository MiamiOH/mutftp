# Class: mutftp
#
# Parameters:
#
#   [*username*]: tftp service username.
#   [*directory*]: tftp service file directory.
#   [*address*]: tftp service bind address (default 0.0.0.0).
#   [*port*]: tftp service bind port (default 69).
#   [*options*]: tftp service bind port (default 69).
#   [*inetd*]: Run as an xinetd service instead of standalone daemon (false)
#
# Actions:
#
# Requires:
#
#   Class['xinetd']  (if inetd set to true)
#
# Usage:
#
#   class { 'mutftp':
#     directory => '/opt/tftp',
#     address   => $::ipaddress,
#     options   => '--ipv6 --timeout 60',
#   }
#
class mutftp (
  $username   = $mutftp::params::username,
  $directory  = $mutftp::params::directory,
  $address    = $mutftp::params::address,
  $port       = $mutftp::params::port,
  $options    = $mutftp::params::options,
  $inetd      = $mutftp::params::inetd,
  $package    = $mutftp::params::package,
  $binary     = $mutftp::params::binary,
  $defaults   = $mutftp::params::defaults,
) inherits mutftp::params {
  $virtual_package = 'tftpd-hpa'

  package { $virtual_package:
    ensure => present,
    name   => $package,
  }

  if $defaults {
    file { '/etc/default/tftpd-hpa':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('tftp/tftpd-hpa.erb'),
      require => Package[$virtual_package],
      notify  => Service['tftpd-hpa'],
    }
  }

  if $inetd {
    include 'xinetd'

    xinetd::service { 'tftp':
      port        => $port,
      protocol    => 'udp',
      server_args => "${options} -u ${username} ${directory}",
      server      => $binary,
      bind        => $address,
      socket_type => 'dgram',
      cps         => '100 2',
      flags       => 'IPv4',
      per_source  => '11',
      wait        => 'yes',
      require     => Package[$virtual_package],
    }

    $svc_ensure = stopped
    $svc_enable = false
  } else {
    $svc_ensure = running
    $svc_enable = true
  }

  $start = $mutftp::params::provider ? {
    'base'  => "${binary} -l -a ${address}:${port} -u ${username} ${options} ${directory}",
    default => undef
  }

  service { 'tftpd-hpa':
    ensure    => $svc_ensure,
    enable    => $svc_enable,
    provider  => $mutftp::params::provider,
    hasstatus => $mutftp::params::hasstatus,
    pattern   => '/usr/sbin/in.tftpd',
    start     => $start,
  }
}
