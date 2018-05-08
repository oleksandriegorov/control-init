class puppet5::params {
    $platform_name       = 'puppet5'
    $os_version          = $operatingsystemmajrelease
    case $::osfamily {
        'RedHat': {
            case $::operatingsystem {
                'Fedora': {
                    $os_abbreviation = 'fedora'
                }
                default: {
                    $os_abbreviation = 'el'
                }
            }
            $repo_urlbase = 'https://yum.puppet.com/puppet5'
            $version_codename = "${os_abbreviation}-${os_version}"
            $package_provider = 'rpm'
        }
        'Suse': {
            $repo_urlbase = 'https://yum.puppet.com/puppet5'
            $os_abbreviation  = 'sles'
            $version_codename = "${os_abbreviation}-${os_version}"
            $package_provider = 'rpm'
        }
        'Debian': {
            $repo_urlbase = 'https://apt.puppetlabs.com'
            $version_codename = $::lsbdistcodename
            $package_provider = 'dpkg'
        }
    }
    $package_name        = "${platform_name}-release"
    $package_filename    = "${package_name}-${version_codename}.noarch.rpm"
    $platform_repository = "${repo_urlbase}/${package_filename}"
    $agent_package_name  = 'puppet-agent'
    $server_package_name = 'puppetserver'
    $r10k_package_name   = 'r10k'
    $gem_path            = '/opt/puppetlabs/puppet/bin/gem'
    $r10k_path           = '/opt/puppetlabs/puppet/bin/r10k'
    $service_name        = 'puppetserver'
}

class puppet5::repo (
    $package_name        = $puppet5::params::package_name,
    $package_filename    = $puppet5::params::package_filename,
    $package_provider    = $puppet5::params::package_provider,
    $platform_repository = $puppet5::params::platform_repository,
) inherits puppet5::params
{
    exec { "curl ${platform_repository} -s -o ${package_filename}":
        cwd     => '/tmp',
        path    => '/bin:/usr/bin',
        creates => "/tmp/${package_filename}",
        alias   => 'download-release-package'
    }

    package { $package_name:
        provider => $package_provider,
        source   => "/tmp/${package_filename}",
        require  => Exec['download-release-package'],
        alias    => 'puppet5-repository',
    }
}

class puppet5::agent::install (
    $agent_package_name = $puppet5::params::agent_package_name,
) inherits puppet5::params
{
    include puppet5::repo

    package { $agent_package_name:
        ensure  => 'latest',
        require => Package['puppet5-repository'],
        alias   => 'puppet-agent',
    }

    host { 'puppet':
        ensure => 'present',
        ip     => '127.0.0.1',
    }
}

class puppet5::server::install (
    $server_package_name = $puppet5::params::server_package_name,
) inherits puppet5::params
{
    require puppet5::agent::install

    package { $server_package_name:
        ensure  => 'latest',
        require => Package['puppet-agent'],
        alias   => 'puppet-server',
    }
}

class puppet5::r10k::install (
    $r10k_package_name = $puppet5::params::r10k_package_name,
    $gem_path          = $puppet5::params::gem_path,
    $r10k_path         = $puppet5::params::r10k_path,
) inherits puppet5::params
{
    require puppet5::agent::install

    exec { "${gem_path} install ${r10k_package_name}":
        creates => $r10k_path,
        require => Package['puppet-agent'],
        alias   => 'r10k-installation',
    }
}

class puppet5::server::setup (
    $r10k_path         = $puppet5::params::r10k_path,
) inherits puppet5::params
{
    require puppet5::r10k::install

    exec { "${r10k_path} deploy environment -p":
        require => Exec['r10k-installation'],
        alias   => 'environment-setup',
    }
}

class puppet5::service (
    $service_name      = $puppet5::params::service_name,
) inherits puppet5::params
{
    include puppet5::server::install

    service { $service_name:
        ensure  => 'running',
        enable  => true,
        require => Package['puppet-server'],
        alias   => 'puppet-server',
    }
}

Package {
    allow_virtual => false,
}

include puppet5::server::setup
include puppet5::service
