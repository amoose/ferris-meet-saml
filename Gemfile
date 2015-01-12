source "https://rubygems.org"

ruby "2.1.5"

gem "airbrake"
gem "bourbon", "~> 3.2.1"
gem "coffee-rails"
gem "delayed_job_active_record"
gem "email_validator"
gem "flutie"
gem "high_voltage"
gem "i18n-tasks"
gem "jquery-rails"
gem "neat", "~> 1.5.1"
gem "newrelic_rpm"
gem "normalize-rails", "~> 3.0.0"
gem "rack-timeout"
gem "rails", "4.1.8"
gem "recipient_interceptor"
gem "sass-rails", "~> 4.0.3"
gem "simple_form"
gem "title"
gem "uglifier"
gem "unicorn"
gem 'slim'
gem 'saml_idp', github: 'amoose/saml_idp', branch: 'feature/ruby-saml-081'
gem 'activerecord-session_store', github: 'rails/activerecord-session_store'

group :development do
  gem 'sqlite3'
  gem "bundler-audit"
  gem "spring"
  gem "spring-commands-rspec"
end

group :development, :test do
  gem 'foreman'
  gem "awesome_print"
  gem "byebug"
  gem "dotenv-rails"
  gem "factory_girl_rails"
  gem "pry-rails"
  gem "rspec-rails", "~> 3.0.0"
end

group :test do
  gem "capybara-webkit", ">= 1.2.0"
  gem "database_cleaner"
  gem "formulaic"
  gem "launchy"
  gem "shoulda-matchers", require: false
  gem "timecop"
  gem "webmock"
end

group :staging, :production do
  gem "pg"
  gem 'rails_12factor'
end
