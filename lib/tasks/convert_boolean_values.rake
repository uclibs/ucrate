# frozen_string_literal: true
#
# Note: this is only needing to be run for our local environments which use sqlite.  The QA and production environments
# use mysql instead of sqlite, so do not need to use this rake task for updating to Rails 6.0.
#
# This Rake task is designed to migrate boolean values from the 't'/'f' format to 1/0 across all models in the application.
# It's particularly useful when preparing to upgrade a Rails application from an older version to Rails 6.0 or higher,
# where ActiveRecord starts expecting boolean values in SQLite databases to be stored as integers (1 for true, 0 for false)
# instead of the traditional 't'/'f' strings.
#
# The task iterates over all ActiveRecord models, identifying boolean columns within each. For each boolean column,
# it updates records in batches, converting 't' to 1 and 'f' to 0. The task includes robust error handling to log
# detailed information about any failures during the update process. This approach ensures data integrity by running
# validations for each record and provides clear feedback in case of issues.
#
# Usage:
# Run this task via the command line using `rails db:convert_boolean_values`. It's recommended to first run this task
# in a development or staging environment before executing it in a production setting.
#
# To run it for your testing environment:
# RAILS_ENV=test bundle exec rake convert_boolean_values
#
# To run it for your development environment:
# bundle exec rake convert_boolean_values
#
# Important Notes:
# - Ensure a database backup is taken before running this task in production.
# - Be aware of the potential performance impact on large datasets.
# - Monitor the database load and consider running during off-peak hours if necessary.
#
task convert_boolean_values: :environment do
  # Iterate over all models derived from ActiveRecord::Base
  ActiveRecord::Base.descendants.each do |model|
    # Wrap updates for each model in a transaction
    model.transaction do
      # Skip models without a database table
      next unless model.table_exists?

      puts "Updating boolean columns for #{model.name}"

      # Iterate over each column in the model
      model.columns_hash.each do |name, info|
        # Proceed only if the column is of boolean type
        next unless info.type == :boolean

        # Define old and new values for conversion
        conversion_values = { 't' => 1, 'f' => 0 }

        # Iterate over each conversion value pair
        conversion_values.each do |old_value, new_value|
          # Update records in batches for efficiency
          model.where(name => old_value).find_each do |record|
            # Attempt to update the record
            record.update(name => new_value)
          rescue StandardError => e
            # Log detailed error information if update fails
            puts "Failed to update #{model.name} ID: #{record.id}, Column: #{name}, Error: #{e.message}"
            puts "Record details: #{record.attributes.except('updated_at', 'created_at')}"
          end
        end

        puts "Finished updating boolean column #{name} in #{model.name}"
      end
    end
  end
end
