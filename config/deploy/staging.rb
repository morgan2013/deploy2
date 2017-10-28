# server-based syntax
# ======================
# Defines a single server with a list of roles and multiple properties.
# You can define all roles on a single server, or split them:

# server "example.com", user: "deploy", roles: %w{app db web}, my_property: :my_value
# server "example.com", user: "deploy", roles: %w{app web}, other_property: :other_value
# server "db.example.com", user: "deploy", roles: %w{db}

set :rails_env, 'staging'
server '192.168.0.104', user: 'deployer', roles: %w{web app db}












namespace :deploy do
  task :kill_puma do
    on roles(:web) do
      within "#{fetch(:deploy_to)}/current/" do
        execute "kill -9 $(lsof -i tcp:3000 -t)" rescue nil
      end
    end
  end

  task :start_puma => [:set_rails_env] do
    on roles(:web) do
      within "#{fetch(:deploy_to)}/current/" do
        with rails_env: fetch(:rails_env) do
          execute :bundle, :exec, "puma -p 3000 -e staging"
        end
      end
    end
  end

  #cap staging deploy:invoke task=db:seed
  task :invoke => [:set_rails_env] do
    on roles(:web) do
      within "#{fetch(:deploy_to)}/current/" do
        execute :rake, "#{ENV['task']}"
      end
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:restart'
    end
  end

  after 'deploy:finishing', 'deploy:kill_puma'
  after 'deploy:kill_puma', 'deploy:start_puma'
  #after  :finishing,    :restart
end

# role-based syntax
# ==================

# Defines a role with one or multiple servers. The primary server in each
# group is considered to be the first unless any hosts have the primary
# property set. Specify the username and a domain or IP for the server.
# Don't use `:all`, it's a meta role.

# role :app, %w{deploy@example.com}, my_property: :my_value
# role :web, %w{user1@primary.com user2@additional.com}, other_property: :other_value
# role :db,  %w{deploy@example.com}



# Configuration
# =============
# You can set any configuration variable like in config/deploy.rb
# These variables are then only loaded and set in this stage.
# For available Capistrano configuration variables see the documentation page.
# http://capistranorb.com/documentation/getting-started/configuration/
# Feel free to add new variables to customise your setup.



# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult the Net::SSH documentation.
# http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start
#
# Global options
# --------------
#  set :ssh_options, {
#    keys: %w(/home/rlisowski/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
#
# The server-based syntax can be used to override options:
# ------------------------------------
# server "example.com",
#   user: "user_name",
#   roles: %w{web app},
#   ssh_options: {
#     user: "user_name", # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: "please use keys"
#   }
