# frozen_string_literal: true

COLLEGE_AND_DEPARTMENT = YAML.safe_load(File.open(Rails.root.join('config', 'college_and_department.yml'))).freeze if File.exist?(Rails.root.join('config', 'college_and_department.yml'))
