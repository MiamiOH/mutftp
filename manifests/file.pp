# Define: mutftp::file
#
# Parameters:
#
#   [*ensure*]: file type, default file.
#   [*owner*]: file owner, default tftp.
#   [*group*]: file group. default tftp.
#   [*mode*]: file mode, default 0644 (puppet will change to 0755 for directories).
#   [*content*]: file content.
#   [*source*]: file source, defaults to puppet*]:///module/${caller_module_name}/${name} for files without content.
#   [*recurse*]: directory recurse, default false.
#   [*purge*]: directory recurse and purge.
#   [*replace*]: replace directory with file or symlink, default undef,
#   [*recurselimit*]: directory recurse limit, default undef,
#
# Actions:
#
#   Deploy files into the tftp directory.
#
# Usage:
#
#   mutftp::file { 'pxelinux.0':
#     source => 'puppet:///modules/acme/pxelinux.0',
#   }
#
#   mutftp::file { 'pxelinux.cfg':
#     ensure => directory,
#   }
#
define mutftp::file (
  $ensure       = file,
  $owner        = undef,
  $group        = undef,
  $mode         = '0644',
  $recurse      = false,
  $purge        = undef,
  $replace      = undef,
  $recurselimit = undef,
  $content      = undef,
  $source       = undef
) {
  include 'mutftp'
  include 'mutftp::params'

  if $owner {
    $tftp_owner = $owner
  } else {
    $tftp_owner = $mutftp::params::username
  }

  if $group {
    $tftp_group = $group
  } else {
    $tftp_group = $mutftp::params::username
  }

  if $source {
    $source_real = $source
  } elsif $ensure != 'directory' and ! $content {
    if $caller_module_name and $caller_module_name != '' {
      $mod = $caller_module_name
    } else {
      $mod = $module_name
    }
    $source_real = "puppet:///modules/${mod}/${name}"
  } else {
    $source_real = undef
  }

  file { "${mutftp::directory}/${name}":
    ensure       => $ensure,
    owner        => $tftp_owner,
    group        => $tftp_group,
    mode         => $mode,
    recurse      => $recurse,
    purge        => $purge,
    replace      => $replace,
    recurselimit => $recurselimit,
    content      => $content,
    source       => $source_real,
    require      => Class['mutftp'],
  }
}
