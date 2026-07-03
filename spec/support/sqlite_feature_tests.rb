# frozen_string_literal: true

# JS feature specs serve the app on a second thread. SQLite allows one writer;
# without a shared AR connection, uploads (uploaded_files INSERT) can raise
# SQLite3::BusyException under CI load.
#
# Rails 5.2's SQLite3Adapter has no configure_connection (added in later Rails),
# so PRAGMAs are applied on the live connection instead.
return unless Rails.env.test?

adapter = ActiveRecord::Base.connection_config[:adapter].to_s
return unless adapter.include?('sqlite')

module SqliteFeatureTests
  module_function

  def configure_sqlite!(connection = ActiveRecord::Base.connection)
    connection.execute('PRAGMA busy_timeout = 30000')
    connection.execute('PRAGMA journal_mode = WAL')
  end
end

SqliteFeatureTests.configure_sqlite!

module SqliteSharedConnection
  mattr_accessor :connection, instance_accessor: false
end

ActiveRecord::Base.singleton_class.prepend(Module.new do
  def connection
    SqliteSharedConnection.connection || super
  end
end)

RSpec.configure do |config|
  config.before(:each, type: :feature) do
    connection = ActiveRecord::Base.connection
    SqliteFeatureTests.configure_sqlite!(connection)
    SqliteSharedConnection.connection = connection
  end

  config.after(:each, type: :feature) do
    SqliteSharedConnection.connection = nil
  end
end
