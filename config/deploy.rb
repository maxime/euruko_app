set :application, "rubyconfchina"
set :repository,  "git://github.com/maxime/euruko_app.git"
set :scm, :git

set :deploy_to, "/var/www/projects/#{application}"

role :app, "rubyconf.ekohe.com"
role :web, "rubyconf.ekohe.com"
role :db,  "rubyconf.ekohe.com", :primary => true

task :after_update_code, :roles => :web do
  {'database.yml' => :config, 'config.yml' => :config,
    'app_key.pem' => :certs, 'app_cert.pem' => :certs,
    'paypal_cert.pem' => :certs}.each_pair do |file,dest|
    run "rm -f #{current_release}/#{dest}/#{file} && ln -s #{shared_path}/config/#{file} #{current_release}/#{dest}/#{file}"
  end
end

namespace :deploy do
  [:start, :stop, :restart].each do |action|
    task action do
      run "sudo monit -g #{application}_ruby #{action} all"
    end
  end

  task :after_restart do
    migrate
    cleanup
  end
end
