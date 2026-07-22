# frozen_string_literal: true

require 'pathname'
require 'yaml'
require 'English'
require 'shellwords'

module Uc
  # Inventory check for Scholar@UC customizations vs Hyku (CI + local).
  class HykuCustomizationsInventory
    MANIFEST_REL = 'docs/local/uc-hyku-customizations.manifest.yml'

    Result = Struct.new(:ok, :errors, :inventory_doc, :entries_count, :watched_count, keyword_init: true)

    def initialize(root: Pathname.pwd, env: ENV)
      @root = Pathname.new(root).expand_path
      @env = env
    end

    def call
      manifest = load_manifest
      entries = Array(manifest['entries'])
      inventory_doc = manifest['inventory_doc'].to_s
      hyku_patched = Array(manifest['hyku_patched'])
      watched_files = expand_watch_globs(Array(manifest['watch_globs']))

      errors = []
      errors.concat(missing_inventory_doc_errors(inventory_doc))
      errors.concat(missing_entry_errors(entries))
      errors.concat(unlisted_watched_file_errors(watched_files, entries))
      errors.concat(hyku_patched_kind_errors(hyku_patched, entries))
      errors.concat(PrEnforcer.new(@root, @env).errors(entries, hyku_patched, inventory_doc))

      Result.new(
        ok: errors.empty?,
        errors: errors,
        inventory_doc: inventory_doc,
        entries_count: entries.size,
        watched_count: watched_files.size
      )
    end

    def covered_by_entry?(rel_path, entries)
      entries.any? { |entry| self.class.path_covers?(entry['path'].to_s, rel_path) }
    end

    def self.path_covers?(entry_path, rel_path)
      if entry_path.end_with?('/')
        rel_path == entry_path.delete_suffix('/') || rel_path.start_with?(entry_path)
      else
        rel_path == entry_path
      end
    end

    # PR diff gate: require inventory/manifest updates when customizations change.
    class PrEnforcer
      def initialize(root, env)
        @root = root
        @env = env
      end

      def errors(entries, hyku_patched, inventory_doc)
        return [] unless enforce?

        missing = missing_sha_errors
        return missing if missing.any?

        base = @env['UC_CUSTOMIZATIONS_BASE_SHA'].to_s
        head = @env['UC_CUSTOMIZATIONS_HEAD_SHA'].to_s
        changed = git_changed_files(base, head)
        return ["PR enforcement: git diff failed for #{base}...#{head}"] unless changed
        return [] if changed.empty?

        triggers = trigger_files(changed, entries, hyku_patched, inventory_doc)
        return [] if triggers.empty?
        return [] if inventory_updated?(changed, inventory_doc)

        [
          'PR changes UC customizations but does not update ' \
          "#{inventory_doc} (or the manifest). Changed: #{triggers.sort.join(', ')}"
        ]
      end

      private

      def enforce?
        @env['GITHUB_EVENT_NAME'] == 'pull_request' || @env['UC_CUSTOMIZATIONS_ENFORCE_PR'] == '1'
      end

      def missing_sha_errors
        base = @env['UC_CUSTOMIZATIONS_BASE_SHA'].to_s
        head = @env['UC_CUSTOMIZATIONS_HEAD_SHA'].to_s
        return [] unless base.empty? || head.empty?

        [
          'PR enforcement enabled but UC_CUSTOMIZATIONS_BASE_SHA / ' \
          'UC_CUSTOMIZATIONS_HEAD_SHA are not both set'
        ]
      end

      def trigger_files(changed, entries, hyku_patched, inventory_doc)
        changed.filter_map do |file|
          next if file == inventory_doc || file == MANIFEST_REL
          next if file.start_with?('docs/local/') && file != inventory_doc

          file if hyku_patched.include?(file) || covered_customization?(file, entries)
        end
      end

      def covered_customization?(file, entries)
        !file.start_with?('docs/local/') &&
          entries.any? { |entry| HykuCustomizationsInventory.path_covers?(entry['path'].to_s, file) }
      end

      def inventory_updated?(changed, inventory_doc)
        changed.include?(inventory_doc) || changed.include?(MANIFEST_REL)
      end

      # Returns an Array of paths, or nil when git fails.
      def git_changed_files(base_sha, head_sha)
        cmd = [
          'git', '-C', @root.to_s,
          'diff', '--name-only', '--diff-filter=ACMR',
          "#{base_sha}...#{head_sha}"
        ]
        out = `#{Shellwords.join(cmd)} 2>/dev/null`
        return nil unless $CHILD_STATUS.success?

        out.split("\n").map(&:strip).reject(&:empty?)
      end
    end

    private

    def load_manifest
      path = @root.join(MANIFEST_REL)
      raise "Missing #{MANIFEST_REL}" unless path.file?

      YAML.safe_load(path.read, permitted_classes: [], aliases: false) || {}
    end

    def expand_watch_globs(watch_globs)
      watch_globs.flat_map { |glob| expand_glob(glob) }.uniq.sort
    end

    def expand_glob(pattern)
      Dir.glob(@root.join(pattern).to_s, File::FNM_EXTGLOB).filter_map do |abs|
        rel = Pathname.new(abs).relative_path_from(@root).to_s
        rel unless rel.end_with?('/')
      end
    end

    def missing_inventory_doc_errors(inventory_doc)
      return [] if @root.join(inventory_doc).file?

      ["inventory_doc missing: #{inventory_doc}"]
    end

    def missing_entry_errors(entries)
      entries.filter_map do |entry|
        path = entry['path'].to_s
        next if entry['allow_missing'] || path.empty?
        next if @root.join(path.delete_suffix('/')).exist?

        "manifest entry missing on disk: #{path} (id=#{entry['id']})"
      end
    end

    def unlisted_watched_file_errors(watched_files, entries)
      watched_files.filter_map do |file|
        next if covered_by_entry?(file, entries)

        "watched file not listed in manifest entries: #{file}"
      end
    end

    def hyku_patched_kind_errors(hyku_patched, entries)
      hyku_patched.filter_map do |path|
        entry = entries.find { |candidate| candidate['path'].to_s == path }
        if entry.nil?
          "hyku_patched path not registered in entries: #{path}"
        elsif entry['kind'].to_s != 'hyku_patched'
          "hyku_patched path #{path} must have kind: hyku_patched (got #{entry['kind'].inspect})"
        end
      end
    end
  end
end
