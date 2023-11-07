source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.2"

gem "rails", "~> 7.0.8"
gem "image_processing",           "1.12.2"
gem "active_storage_validations", "0.9.8"
gem "bcrypt",          "3.1.18"
gem "faker",           "2.21.0"
gem "will_paginate",           "3.3.1"
gem "bootstrap-will_paginate", "1.0.0"
gem "bootstrap-sass",  "3.4.1"
gem "sassc-rails",     "2.1.2"
gem "sprockets-rails"
gem "sqlite3", "~> 1.4"
gem "puma", "~> 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]
gem "bootsnap", require: false


group :development, :test do
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console", "4.2.0"
  gem "solargraph",  "0.48.0"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara",                 "3.38.0"
  gem "selenium-webdriver",       "4.8.3"
  gem "webdrivers",               "5.2.0"
  gem "rails-controller-testing", "1.0.5"
  gem "minitest",                 "5.18.0"
  gem "minitest-reporters",       "1.6.0"
  gem "guard",                    "2.18.0"
  gem "guard-minitest",           "2.4.6"

end
