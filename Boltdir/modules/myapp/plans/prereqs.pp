plan myapp::prereqs(
) {
  # Prep this node for applying Puppet code (doesn't work yet)
  apply_prep('localhost')
  #run_task('puppet_agent::install', 'localhost')

  # Retrieve facts
  #run_plan('facts', nodes => 'localhost')

  # Apply SampleApp prereqs
  $report = apply('localhost') {

    include epel
    include mysql::server
    include mysql::client
    
    class { 'nginx':
      names_hash_bucket_size => 64
    }

    mysql::db { 'MyApp_database':
      user     => 'MyApp_dbuser',
      password => 'MyApp_dbpass',
      host     => 'localhost',
      grant    => ['SELECT', 'UPDATE'],
    }

    class {'mysql::bindings':
      php_enable => true,
    }

    file { '/etc/pki/rpm-gpg/RPM-GPG-KEY-remi':
      ensure => present,
      source => 'puppet:///modules/myapp/RPM-GPG-KEY-remi',
    }

    yumrepo { 'remi':
      ensure     => 'present',
      descr      => 'Remi\'s RPM repository for Enterprise Linux 7 - $basearch',
      baseurl    => 'http://rpms.remirepo.net/enterprise/7/remi/$basearch/',
      mirrorlist => 'http://cdn.remirepo.net/enterprise/7/remi/mirror',
      gpgkey     => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-remi',
      enabled    => '1',
      gpgcheck   => '1',
      target     => '/etc/yum.repos.d/remi.repo',
      require    => File['/etc/pki/rpm-gpg/RPM-GPG-KEY-remi']
    }

    class { 'php':
      composer  => false,
      fpm_user  => 'nginx',
      fpm_group => 'nginx',
      require   => [
        Class['nginx'],
        Class['epel'],
        Yumrepo['remi']
      ]
    }

    file { '/var/www':
      ensure => directory
    }

    file { '/var/www/myapp':
      ensure => directory
    }

  }

  # return $report

}
