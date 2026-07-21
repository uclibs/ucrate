# frozen_string_literal: true

# fcrepo_wrapper 0.9.0 and solr_wrapper 2.2.0 still use Ruby 3.3-incompatible
# behavior (`File.exists?` and bare `open(url)`). Preload this file when
# starting Fedora or Solr so the wrappers can run on Ruby 3.3.

require 'open-uri'

class << File
  alias exists? exist? unless respond_to?(:exists?)
end

module HykuLocalWrapperCompat
  module_function

  def apply_solr_wrapper_patch
    return if defined?(@solr_wrapper_patch_applied) && @solr_wrapper_patch_applied
    return unless defined?(SolrWrapper::Instance)

    SolrWrapper::Instance.class_eval do
      def extract
        return config.instance_dir if extracted?

        zip_path = download

        begin
          Zip::File.open(zip_path) do |zip_file|
            zip_file.each do |entry|
              dest_file = File.join(config.tmp_save_dir, entry.name)
              FileUtils.remove_entry(dest_file, true)
              FileUtils.mkdir_p(File.dirname(dest_file)) unless entry.directory?
              entry.extract(dest_file)
            end
          end
        rescue Exception => e
          abort "Unable to unzip #{zip_path} into #{config.tmp_save_dir}: #{e.message}"
        end

        begin
          FileUtils.remove_dir(config.instance_dir, true)

          FileUtils.mkdir_p(config.instance_dir)
          temp_entries = Dir.children(config.tmp_save_dir)
          source_root = if temp_entries.length == 1 && File.directory?(File.join(config.tmp_save_dir, temp_entries.first))
            File.join(config.tmp_save_dir, temp_entries.first)
          else
            config.tmp_save_dir
          end

          Dir.children(source_root).each do |entry|
            FileUtils.cp_r File.join(source_root, entry), config.instance_dir
          end

          self.extracted_version = config.version
          FileUtils.chmod 0755, config.solr_binary
        rescue Exception => e
          abort "Unable to copy #{config.tmp_save_dir} to #{config.instance_dir}: #{e.message}"
        end

        config.instance_dir
      ensure
        FileUtils.remove_entry config.tmp_save_dir if File.exist? config.tmp_save_dir
      end
    end

    @solr_wrapper_patch_applied = true
  end
end

module Kernel
  alias hyku_original_require require unless method_defined?(:hyku_original_require)

  def require(path)
    result = hyku_original_require(path)
    HykuLocalWrapperCompat.apply_solr_wrapper_patch
    result
  end

  alias hyku_original_open open unless method_defined?(:hyku_original_open)

  def open(name, *args, **kwargs, &block)
    if name.is_a?(String) && name.match?(%r{\Ahttps?://})
      OpenURI.open_uri(name, *args, **kwargs, &block)
    else
      hyku_original_open(name, *args, **kwargs, &block)
    end
  end
end