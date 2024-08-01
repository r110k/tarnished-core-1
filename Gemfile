source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }
ruby "3.0.0"
gem "rails", "~> 7.0.8", ">= 7.0.8.4"
gem "pg", "~> 1.1"
gem "puma", "~> 5.0"
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]
gem "bootsnap", require: false
gem 'rack-cors'
gem 'kaminari'
gem 'rspec_api_documentation', path: './vendor/rspec_api_documentation'
gem 'jwt'
group :development, :test do
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem 'rspec-rails', '~> 6.1.0'
end
group :test do
  gem 'factory_bot_rails'
  gem 'faker'
end
