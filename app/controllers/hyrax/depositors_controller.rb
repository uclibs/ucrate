# frozen_string_literal: true
require Hyrax::Engine.root.join('app/controllers/hyrax/depositors_controller.rb')
module Hyrax
  class DepositorsController < ApplicationController
    def create
      grantor = authorize_and_return_grantor
      grantee = ::User.from_url_component(params[:grantee_id])
      if grantor.can_receive_deposits_from.include?(grantee)
        head :ok
      else
        grantor.can_receive_deposits_from << grantee
        send_proxy_depositor_added_messages(grantor, grantee)
        render json: { name: grantee.name, delete_path: sanitize_route_string(hyrax.user_depositor_path(grantor.user_key, grantee.user_key)) }
      end
    end

    def destroy
      grantor = authorize_and_return_grantor
      grantee = ::User.from_url_component(params[:id])
      send_removed_proxy_email(grantor, grantee) if grantor.can_receive_deposits_from.delete(grantee)
      grantor.can_receive_deposits_from.delete(::User.from_url_component(params[:id]))
      ProxyEditRemovalJob.perform_now(grantor, ::User.from_url_component(params[:id]))
      head :ok
    end

    def send_granted_proxy_email(grantor, grantee)
      ChangeManager::EmailManager.queue_change(grantor, 'added_as_proxy', '', grantee)
    rescue NotImplementedError # needed for specs and development environments
      ChangeManager::EmailManager.skip_sidekiq_for_emails(grantor, 'added_as_proxy', '', grantee)
    end

    def send_removed_proxy_email(grantor, grantee)
      ChangeManager::EmailManager.queue_change(grantor, 'removed_as_proxy', '', grantee)
    rescue NotImplementedError # needed for specs and development environments
      ChangeManager::EmailManager.skip_sidekiq_for_emails(grantor, 'removed_as_proxy', '', grantee)
    end

    private

      def sanitize_route_string(route)
        route.gsub("\.", "-dot-")
      end

      def send_proxy_depositor_added_messages(grantor, grantee)
        message_to_grantee = "#{grantor.name} has assigned you as a proxy depositor"
        message_to_grantor = "You have assigned #{grantee.name} as a proxy depositor"
        ::User.batch_user.send_message(grantor, message_to_grantor, "Proxy Depositor Added")
        ::User.batch_user.send_message(grantee, message_to_grantee, "Proxy Depositor Added")
        send_granted_proxy_email(grantor, grantee)
      end
  end
end
