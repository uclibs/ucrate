# frozen_string_literal: true

# JS feature specs serve the app on a second thread. SQLite allows one writer;
# without a shared AR connection, uploads (uploaded_files INSERT) can raise
# SQLite3::BusyException under CI load.
return unless Rails.env.test?
return unless ActiveRecord::Base.connection.adapter_name == 'SQLite'

ActiveRecord::ConnectionAdapters::SQLite3Adapter.class_eval do
  def configure_connection
    super
    @raw_connection.busy_timeout = 30_000
    @raw_connection.execute('PRAGMA journal_mode=WAL')
  end
end

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
    SqliteSharedConnection.connection = ActiveRecord::Base.connection
  end

  config.after(:each, type: :feature) do
    SqliteSharedConnection.connection = nil
  end
end
