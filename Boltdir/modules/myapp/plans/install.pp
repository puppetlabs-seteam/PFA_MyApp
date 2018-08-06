plan myapp::install(
) {
  # Prep this node for applying Puppet code (doesn't work yet)
  # apply_prep('localhost')
  run_task('puppet_agent::install', 'localhost')

  # Retrieve facts
  run_plan('facts', nodes => 'localhost')

  # Apply SampleApp prereqs
  $report = apply('localhost') {

    include mysql::server
    include mysql::client
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

    class {'mysql::bindings':
      php_enable => true,
      require => Class['php']
    }

    file { '/var/www':
      ensure => directory
    }

    file { '/var/www/myapp':
      ensure => directory
    }

    file { "var/www/myapp/index.html":
      ensure  => file,
      content => epp('myapp/sample_website-index.html.epp'),
    }

    nginx::resource::server { 'www.myapp.com':
      listen_port => 80,
      www_root    => '/var/www/myapp',
      index_files => ['index.html'],
    }

  }

  # return $report

}
