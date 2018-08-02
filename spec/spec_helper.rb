require "bundler/setup"
require "pg_trgm"

require 'faker'
require 'active_record'
require 'pg_array'

system 'dropdb pg_trgm_test'
system 'createdb pg_trgm_test'
system 'psql', 'pg_trgm_test', '--command', 'CREATE EXTENSION IF NOT EXISTS pg_trgm'

ActiveRecord::Base.establish_connection 'postgres://localhost:5432/pg_trgm_test'
ActiveRecord::Base.logger = Logger.new('log/test.log')

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
