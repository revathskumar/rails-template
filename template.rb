file '.rvmrc', "rvm use 1.9.3-p194"
gems = <<-GEMS

group :development do
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

group :linux do
    gem "rb-inotify"
    gem "libnotify"
end

gem 'jquery-rails'
GEMS

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
run "echo '#{gems}' >> Gemfile"
run "echo '#{gitignore}' >> .gitignore"
guardfile = <<-GUARDFILE
guard 'rspec', :version => 2 do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/\#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end
GUARDFILE

file 'Guardfile', guardfile if yes?("Guardfile? (yes/no)")

run "echo 'gem \"twitter-bootstrap-rails\", :group => :assets' >> Gemfile" if yes?("Twitter Bootstrap? (yes/no)")
run "echo 'gem \"rails-backbone\"' >> Gemfile" if yes?("Backbone? (yes/no)")


jasmine = <<-JASMINE
gem 'jasmine'
gem 'jasminerice'
gem 'guard'
gem 'guard-jasmine'
JASMINE

run "echo '#{jasmine}' >> Gemfile" if yes?("Jasmine? (yes/no)")