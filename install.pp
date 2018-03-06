class puppet5::params {
    if $::osfamily == 'RedHat' {
        $platform_name = 'puppet5'
        $os_abbreviation = 'el'
        $os_version = $operatingsystemmajrelease
        $package_name = "${platform_name}-release"
        $package_filename = "${package_name}-${os_abbreviation}-${os_version}.noarch.rpm"
        $platform_repository = "https://yum.puppet.com/puppet5/${package_filename}"
        $agent_package_name = 'puppet-agent'
        $server_package_name = 'puppetserver'
    }
    $r10k_package_name = 'r10k'
    $gem_path = '/opt/puppetlabs/puppet/bin/gem'
    $r10k_path = '/opt/puppetlabs/puppet/bin/r10k'
}

class puppet5::repo (
    $package_name        = $puppet5::params::package_name,
    $package_filename    = $puppet5::params::package_filename,
    $platform_repository = $puppet5::params::platform_repository,
) inherits puppet5::params
{
    if $::osfamily == 'RedHat' {
        exec { 'download-package':
            command => "curl ${platform_repository} -s -o ${package_filename}",
            cwd     => '/tmp',
            path    => '/bin:/usr/bin',
            creates => "/tmp/${package_filename}",
        }
        package { 'puppet5-platform-repository':
            name     => $package_name,
            provider => 'rpm',
            source   => "/tmp/${package_filename}",
            require  => Exec['download-package']
        }
    }
}

class puppet5::update (
    $agent_package_name = $puppet5::params::agent_package_name,
) inherits puppet5::params
{
    include puppet5::repo

    if $::osfamily == 'RedHat' {
        package { 'puppet-agent':
            ensure  => 'latest',
            name    => $agent_package_name,
            require => Package['puppet5-platform-repository'],
        }
    }
}

class puppet5::server::install (
    $server_package_name = $puppet5::params::server_package_name,
) inherits puppet5::params
{
    include puppet5::repo
    require puppet5::update

    if $::osfamily == 'RedHat' {
        package { 'puppet-server':
            ensure  => 'latest',
            name    => $server_package_name,
            require => Package['puppet-agent'],
        }
    }
}

class puppet5::r10k::install (
    $r10k_package_name = $puppet5::params::r10k_package_name,
    $gem_path          = $puppet5::params::gem_path,
    $r10k_path         = $puppet5::params::r10k_path,
) inherits puppet5::params
{
    require puppet5::update

    if $::osfamily == 'RedHat' {
         exec { 'r10k-gem-installation':
             command => "${gem_path} install ${r10k_package_name}",
             creates => $r10k_path,
             require  => Package['puppet-agent'],
         }
    }
}


Package {
    allow_virtual => false,
}

include puppet5::update
include puppet5::server::install
include puppet5::r10k::install

# /opt/puppetlabs/puppet/bin/gem install r10k
