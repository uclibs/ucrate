# frozen_string_literal: true

GIT_SHA =
  if Rails.env.development? || Rails.env.test? || Rails.env.production?
    `git rev-parse HEAD`.chomp
  else
    "Unknown SHA"
  end

BRANCH =
  if Rails.env.development? || Rails.env.test? || Rails.env.production?
    `git rev-parse --abbrev-ref HEAD`.chomp
  else
    "Unknown branch"
  end

LAST_DEPLOYED =
  "Not in deployed environment"
