answers = {}
file '.rvmrc', "rvm use 1.9.3-p194"

gem_group :development, :test do
    gem "rspec"
    gem "rake"
    gem "guard"
    gem "guard-rspec"
    gem "simplecov"
    gem "flog"
    gem "yard"
    gem "ci_reporter"
    gem "simplecov-rcov"
    gem "rdiscount"
    gem "rspec-rails"
end

# .gitignore
gitignore = <<-GITIGNORE
vendor/bundle/
.bundle/
coverage/
spec/reports
*.log
.yardoc
*.gem
yardoc/
*~
/config/database.yml
GITIGNORE
append_file ".gitignore", gitignore, :force => true


# Questions
answers[:guard] = yes?("Guardfile? (yes/no)")
answers[:twitter_bootsrap] = yes?("Twitter Bootstrap? (yes/no)")
answers[:backbone] = yes?("Backbone? (yes/no)")
answers[:jasmine] = yes?("Jasmine? (yes/no)")

strategies = ["","omniauth-google-oauth2", "omniauth-facebook", "omniauth-instagram", "omniauth-github", "omniauth-twitter"]
answers[:oauth] = ask("Omniauth? [1.Google, 2.Facebook, 3.Instagram, 4.Github, 5.Twitter, 6.None]").to_i

valid_strategy = !["",nil].include?(strategies[answers[:oauth]])

if valid_strategy
    provider = seleted_strategy = strategies[answers[:oauth]]

    gem seleted_strategy
    provider["omniauth-"] = ""
    provider.gsub! "-", "_"

    omniauth = <<-CODE
Rails.application.config.middleware.use OmniAuth::Builder do

  provider :developer unless Rails.env.production?
  provider :#{provider}, CONFIG['omniauth_credentials']['client_id'], CONFIG['omniauth_credentials']['client_secret']
end unless Rails.env.test?
CODE

    initializer 'omniauth.rb', omniauth

    custom_config = <<-CODE
omniauth_credentials:
  client_id: 'CLIENT_ID'
  client_secret: 'CLIENT_SECRET'
CODE

    inside("config") do
        file "config_development.yml", custom_config
        run "cp config_development.yml config_development.yml.example"
    end

    initializer 'config.rb', 'CONFIG = YAML.load_file("#{Rails.root.to_s}/config/config_#{Rails.env}.yml")'
    generate(:controller, "Sessions")
    file "app/controllers/sessions_controller.rb", <<-SESSION
class SessionsController < ApplicationController
  # This controller manages authentication, and therefore, accessing this section does not require authentication.
  skip_before_filter :require_authentication

  # Create an authorized session if the e-mail received from Google Authentication callback is a a MobME email address.
  def create
    if auth_hash['info']['email'].ends_with? "@mobme.in"
      session[:authenticated] = auth_hash
      redirect_url = request.env['omniauth.origin']
      redirect_url = view_context.base_url if redirect_url && ["logout", "failure", 'callback'].any? { |s| redirect_url.include?(s) }
      redirect_to redirect_url || view_context.base_url
    else
      @unauthenticated_email_address = auth_hash['info']['email']
      @reason = :unauthenticated_email_address
      render :action => 'failure', :layout => 'application_unauthenticated'
    end
  end

  # Authentication failure management.
  def failure
    require 'base64'
    session[:authenticated] = false
    case params[:message]
      when "invalid_credentials"
        @reason = :invalid_credentials
      else
        @reason = params.inspect
    end

    render :layout => 'application_unauthenticated'
  end

  # Logout.
  def destroy
    session[:authenticated] = false
    render :layout => 'application_unauthenticated'
  end

  protected

  # Returns omniauth's post-authorization details hash.
  def auth_hash
    request.env['omniauth.auth']
  end
end
    SESSION
end

# Guard
if answers[:guard]
    guardfile = <<-GUARDFILE
    guard 'rspec', :version => 2 do
      watch(%r{^spec/.+_spec\.rb$})
      watch(%r{^lib/(.+)\.rb$})     { |m| "spec/\#{m[1]}_spec.rb" }
      watch('spec/spec_helper.rb')  { "spec" }
    end
    GUARDFILE

    file 'Guardfile', guardfile
end


if answers[:jasmine] && answers[:guard]
    jasmine_guard = <<-JASMINE_GUARD
    group :frontend do
      guard 'jasmine', :phantomjs_bin => './spec/javascripts/support/phantomjs', :specdoc => :always, :console => :always do
        watch(%r{app/assets/javascripts/.+(js\.coffee|js)}) { "spec/javascripts" }
        watch(%r{spec/javascripts/.+(js\.coffee|js)}) { "spec/javascripts" }
      end
    end
    JASMINE_GUARD

    append_file 'Guardfile', jasmine_guard
end

if answers[:twitter_bootsrap]
    gem "therubyracer"
    gem "less-rails"
    gem "twitter-bootstrap-rails"
end

gem "rails-backbone" if answers[:backbone]

gem_group :development, :test do
    gem 'jasmine'
    gem 'jasminerice'
    gem 'guard-jasmine'
end if answers[:jasmine]

inside("config") do
    run "cp database.yml database.yml.example"
end

run "rm public/index.html"

run "bundle install --path vendor/bundle"

generate "rspec:install"
generate "bootstrap:install" if answers[:twitter_bootsrap]
generate "backbone:install" if answers[:backbone]
generate "jasmine:install" if answers[:jasmine]

git :init
git :add => "."
git :commit => "-a -m 'Initial commit'"
