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


# Guard
guardfile = <<-GUARDFILE
guard 'rspec', :version => 2 do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/\#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end
GUARDFILE
file 'Guardfile', guardfile if answers[:guard]

gem "twitter-bootstrap-rails" if answers[:twitter_bootsrap]
gem "rails-backbone" if answers[:backbone]

gem_group :development, :test do
    gem 'jasmine'
    gem 'jasminerice'
    gem 'guard-jasmine'
end if answers[:jasmine]

inside("config") do
    run "cp database.yml.example database.yml"
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
