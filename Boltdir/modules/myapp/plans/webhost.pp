plan myapp::webhost(
) {
  # Prep this node for applying Puppet code (doesn't work yet)
  apply_prep('localhost')
  #run_task('puppet_agent::install', 'localhost')

  # Retrieve facts
  #run_plan('facts', nodes => 'localhost')

  # Apply SampleApp prereqs
  $report = apply('localhost') {

    class { 'nginx':
      names_hash_bucket_size => 128
    }

    nginx::resource::server { 'myapp':
      server_name         => [ $facts['ec2_metadata']['public-hostname'] ],
      listen_port         => 80,
      www_root            => '/var/www/myapp/web',
      index_files         => ['index.php'],
      location_cfg_append => {
        try_files => '$uri $uri/ =404'
      },
    }

    nginx::resource::location { 'myapp_root':
      ensure              => present,
      server              => 'myapp' ,
      www_root            => '/var/www/myapp/web',
      location            => '~ \.php$',
      fastcgi             => 'unix:/var/run/php-fpm.sock',
      fastcgi_index       => 'index.php',
      fastcgi_split_path  => '^(.+\.php)(/.+)$',
    }

  }

  # return $report

}
