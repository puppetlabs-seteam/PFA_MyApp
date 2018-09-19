plan myapp::prereqs(
) {
  # Prep this node for applying Puppet code
  apply_prep('localhost')

  # Apply MyApp prereqs
  $result = apply('localhost') {

    include yum
    include epel
    include mysql::server
    include mysql::client

    class { 'nginx':
      names_hash_bucket_size => 128
    }

    mysql::db { 'MyApp_database':
      user     => 'MyApp_dbuser',
      password => 'MyApp_dbpass',
      host     => 'localhost',
      grant    => ['ALL'],
    }

    class {'mysql::bindings':
      php_enable => true,
    }

    yum::gpgkey { '/etc/pki/rpm-gpg/RPM-GPG-KEY-remi':
      ensure => present,
      source => 'puppet:///modules/myapp/RPM-GPG-KEY-remi',
    }

    class { 'php':
      composer  => false,
      fpm_user  => 'nginx',
      fpm_group => 'nginx',
      require   => [
        Class['nginx'],
        Class['epel'],
        Class['yum'],
      ]
    }

    file { '/var/www':
      ensure => directory
    }

    file { '/var/www/myapp':
      ensure  => directory
    }

  }

  run_task(
    'mysql::sql',
    'localhost',
    database => 'MyApp_database',
    user => 'MyApp_dbuser',
    password => 'MyApp_dbpass',
    sql => 'CREATE TABLE IF NOT EXISTS upload_images (
      id int(11) NOT NULL AUTO_INCREMENT,
      username varchar(255) DEFAULT "",
      filename varchar(255) DEFAULT "",
      timeline timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (id)
    ) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1'
  )

  run_task(
    'mysql::sql',
    'localhost',
    database => 'MyApp_database',
    user => 'MyApp_dbuser',
    password => 'MyApp_dbpass',
    sql => 'INSERT IGNORE INTO upload_images VALUES (1,"Qingye Jiang","clouds1.jpg","2015-01-31 04:21:11"),
        (2,"Qingye Jiang","clouds2.jpg","2015-01-31 04:21:15"),
        (3,"Qingye Jiang","clouds3.jpg","2015-01-31 04:21:20"),
        (4,"Qingye Jiang","clouds4.jpg","2015-01-31 04:21:25"),
        (5,"Qingye Jiang","clouds5.jpg","2015-01-31 04:24:26"),
        (6,"Qingye Jiang","clouds6.jpg","2015-01-31 04:24:30"),
        (7,"Qingye Jiang","clouds7.jpg","2015-01-31 04:24:34"),
        (8,"Qingye Jiang","clouds8.jpg","2015-01-31 04:24:38"),
        (9,"Qingye Jiang","clouds9.jpg","2015-01-31 04:25:49"),
        (10,"Qingye Jiang","clouds10.jpg","2015-01-31 04:25:53")'
  )

}
