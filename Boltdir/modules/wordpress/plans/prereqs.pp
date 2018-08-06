plan myapp::prereqs(
) {
  # Prep this node for applying Puppet code (doesn't work yet)
  # apply_prep('localhost')
  run_task('puppet_agent::install', 'localhost')

  # Retrieve facts
  run_plan('facts', nodes => 'localhost')

  # Apply SampleApp prereqs
  $report = apply('localhost') {

    include mysql::server
    include nginx

    mysql::db { 'MyApp_database':
      user     => 'MyApp_dbuser',
      password => 'MyApp_dbpass',
      host     => 'localhost',
      grant    => ['SELECT', 'UPDATE'],
    }

    class { 'php':
      composer  => false,
      fpm_user  => 'nginx',
      fpm_group => 'nginx',
      require => Class['nginx']
    }

    file { '/var/www':
      ensure => directory
    }

    file { '/var/www/myapp':
      ensure => directory
    }

    nginx::resource::server { 'www.myapp.com':
      listen_port => 80,
      www_root    => '/var/www/myapp',
      index_files => ['index.php'],
    }

  }

  # return $report

}
