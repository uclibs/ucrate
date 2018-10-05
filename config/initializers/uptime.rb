# frozen_string_literal: true
@deploy_timestamp = File.open('config/deploy_timestamp', &:readline)
if @deploy_timestamp == "\n"
  Time.zone = "Eastern Time (US & Canada)"
  Hyrax::BUILD_IDENTIFIER = Time.zone.now
else
  Hyrax::BUILD_IDENTIFIER = File.open('config/deploy_timestamp', &:readline)
end
