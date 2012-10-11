My rails App boilerplate
========================

* Create Rails APP

        rails new blog -Td mysql --skip-bundle

* Create .rvmrc

        echo "rvm use 1.9.3-p194" >> .rvmrc

* Update Gemfile

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
        gem "twitter-bootstrap-rails", :group => :assets
        gem "rails-backbone"

* Bundle

        bundle install --path vendor/bundle


*  Add to .gitignore

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

* Add Guardfile

        guard 'rspec', :version => 2 do
          watch(%r{^spec/.+_spec\.rb$})
          watch(%r{^lib/(.+)\.rb$})     { |m| "spec/#{m[1]}_spec.rb" }
          watch('spec/spec_helper.rb')  { "spec" }
        end

* Install rspec

        rails generate rspec:install

* Set up Twitter bootstrap

        rails g bootstrap:install
        rails g bootstrap:layout application ﬂuid
        rails g bootstrap:themed Posts

* Setup Backbone

         rails g backbone:install
         rails g backbone:model
         rails g backbone:router
         rails g backbone:scaffold
* Copy database.yml

        cp config/database.yml.example config/database.yml

* Remove public/index.html

        rm public/index.html

* Jasmine

        gem 'jasmine'
        gem 'jasminerice'
        gem 'guard'
        gem 'guard-jasmine'


        rails g jasmine:install
        rake jasmine