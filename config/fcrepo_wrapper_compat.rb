# frozen_string_literal: true

# fcrepo_wrapper 0.9.0 and solr_wrapper 2.2.0 still use Ruby 3.3-incompatible
# behavior (`File.exists?` and bare `open(url)`). solr_wrapper also calls
# rubyzip with the pre-3.0 extract API. Preload when starting Fedora or Solr:
#   RUBYOPT="-r./config/fcrepo_wrapper_compat" bundle exec solr_wrapper
#
# Removable when wrappers (or their rubyzip usage) are updated.

require 'open-uri'
require 'fileutils'

class << File
  alias exists? exist? unless respond_to?(:exists?)
end

module HykuLocalSolrWrapperExtractCompat
  # rubyzip 3.x: entry.extract(name, destination_directory: parent)
  # solr_wrapper 2.2 still does entry.extract(full_path), which unpacks under
  # the app cwd (./var/folders/...) and then fails copying into instance_dir.
  def extract
    FileUtils.mkdir_p(File.dirname(config.instance_dir)) if config.instance_dir
    return config.instance_dir if extracted?

    zip_path = download

    begin
      FileUtils.mkdir_p(config.tmp_save_dir)
      Zip::File.open(zip_path) do |zip_file|
        zip_file.each do |entry|
          entry.extract(entry.name, destination_directory: config.tmp_save_dir)
        end
      end
    rescue Exception => e
      abort "Unable to unzip #{zip_path} into #{config.tmp_save_dir}: #{e.message}"
    end

    begin
      FileUtils.remove_dir(config.instance_dir, true)
      solr_root = File.join(config.tmp_save_dir, File.basename(config.download_url, '.zip'))
      FileUtils.cp_r(solr_root, config.instance_dir)
      self.extracted_version = config.version
      FileUtils.chmod(0o755, config.solr_binary)
    rescue Exception => e
      abort "Unable to copy #{config.tmp_save_dir} to #{config.instance_dir}: #{e.message}"
    end

    config.instance_dir
  ensure
    FileUtils.remove_entry(config.tmp_save_dir) if config.tmp_save_dir && File.exist?(config.tmp_save_dir)
  end
end

module HykuLocalWrapperCompat
  module_function

  def apply_solr_wrapper_extract_patch
    return if defined?(@solr_extract_patch_applied) && @solr_extract_patch_applied
    return unless defined?(SolrWrapper::Instance)
    return if SolrWrapper::Instance.ancestors.include?(HykuLocalSolrWrapperExtractCompat)

    SolrWrapper::Instance.prepend(HykuLocalSolrWrapperExtractCompat)
    @solr_extract_patch_applied = true
  end

  def apply!
    apply_solr_wrapper_extract_patch
  end
end

module Kernel
  alias hyku_original_require require unless method_defined?(:hyku_original_require)

  def require(path)
    result = hyku_original_require(path)
    HykuLocalWrapperCompat.apply!
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

HykuLocalWrapperCompat.apply!

# bundle exec solr_wrapper does not always hit our require hook for the
# Instance class; catch the class definition as a backup.
TracePoint.new(:class) do |tp|
  next unless defined?(SolrWrapper::Instance)

  HykuLocalWrapperCompat.apply! if tp.self == SolrWrapper::Instance
end.enable
