# frozen_string_literal: true
module Scholar
  class API < Grape::API
    # View all API routes with rails grape:routes
    mount Scholar::V1::Collections
    mount Scholar::V1::Concern
    mount Scholar::V1::Users
  end
end
