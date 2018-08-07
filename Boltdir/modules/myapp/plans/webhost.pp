plan myapp::webhost(
) {
  # Prep this node for applying Puppet code (doesn't work yet)
  apply_prep('localhost')
  #run_task('puppet_agent::install', 'localhost')

  # Retrieve facts
  #run_plan('facts', nodes => 'localhost')

  # Apply SampleApp prereqs
  $report = apply('localhost') {

    include nginx

    nginx::resource::server { 'www.myapp.com':
      listen_port => 80,
      www_root    => '/var/www/myapp',
      index_files => ['index.html'],
    }

  }

  # return $report

}
