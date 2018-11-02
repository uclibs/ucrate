# frozen_string_literal: true
module RemoveProxyEditors
  module RemoveUser
    def remove_proxy_from_work(work, proxy)
      work.file_sets.each do |file|
        file.edit_users -= [proxy.email]
        file.save!
        file.to_solr
      end
      work.edit_users -= [proxy.email]
      work.save!
      work.to_solr
    end
  end
end
