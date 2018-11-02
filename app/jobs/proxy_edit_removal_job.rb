# frozen_string_literal: true
class ProxyEditRemovalJob < ActiveJob::Base
  queue_as :proxy_removal

  def perform(grantor, proxy)
    type = Hyrax.config.curation_concerns
    #    type = Hyrax.config.registered_curation_concern_types
    type.each do |klass|
      klass.find_each('edit_access_person_ssim' => [proxy.email]) do |work|
        next unless (work.on_behalf_of == grantor.email) && (work.proxy_depositor == proxy.email)
        work.remove_proxy_from_work(work, proxy)
      end
    end
  end
end
