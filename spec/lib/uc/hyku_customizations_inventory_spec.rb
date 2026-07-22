# frozen_string_literal: true

require 'fileutils'
require 'pathname'
require 'tmpdir'
require 'yaml'
require_relative '../../../lib/uc/hyku_customizations_inventory'

RSpec.describe Uc::HykuCustomizationsInventory do
  describe '#covered_by_entry?' do
    subject(:inventory) { described_class.new(root: Dir.pwd) }

    it 'matches directory prefix entries' do
      entries = [{ 'path' => 'app/services/uc/' }]
      expect(inventory.covered_by_entry?('app/services/uc/sample_seed_service.rb', entries)).to be(true)
    end

    it 'does not match a sibling path outside the prefix' do
      entries = [{ 'path' => 'app/services/uc/' }]
      expect(inventory.covered_by_entry?('app/services/other.rb', entries)).to be(false)
    end

    it 'does not treat a directory prefix as matching a similarly named sibling' do
      entries = [{ 'path' => 'app/foo/' }]
      expect(inventory.covered_by_entry?('app/foo-bar/x.rb', entries)).to be(false)
    end
  end

  describe '#call' do
    it 'passes for the committed inventory in this repo' do
      result = described_class.new(root: Pathname.pwd, env: {}).call
      expect(result.ok).to be(true), -> { result.errors.join("\n") }
    end

    it 'fails PR enforcement when SHAs are missing' do
      result = described_class.new(
        root: Pathname.pwd,
        env: { 'UC_CUSTOMIZATIONS_ENFORCE_PR' => '1' }
      ).call

      expect(result.ok).to be(false)
      expect(result.errors.join).to match(/BASE_SHA|HEAD_SHA/)
    end

    it 'fails PR enforcement when git diff fails' do
      result = described_class.new(
        root: Pathname.pwd,
        env: {
          'UC_CUSTOMIZATIONS_ENFORCE_PR' => '1',
          'UC_CUSTOMIZATIONS_BASE_SHA' => 'not-a-real-sha',
          'UC_CUSTOMIZATIONS_HEAD_SHA' => 'also-not-a-real-sha'
        }
      ).call

      expect(result.ok).to be(false)
      expect(result.errors.join).to match(/git diff failed/)
    end

    it 'fails when a hyku_patched path has the wrong kind' do
      Dir.mktmpdir do |dir|
        root = Pathname.new(dir)
        write_minimal_repo(root, entries: [
                             { 'path' => 'docs/local/', 'kind' => 'uc_only', 'id' => 'local-docs' },
                             { 'path' => 'README.md', 'kind' => 'uc_only', 'id' => 'wrong' }
                           ], hyku_patched: ['README.md'])

        result = described_class.new(root: root, env: {}).call
        expect(result.ok).to be(false)
        expect(result.errors.join).to match(/must have kind: hyku_patched/)
      end
    end

    it 'fails when a watched file is not covered by any entry' do
      Dir.mktmpdir do |dir|
        root = Pathname.new(dir)
        write_minimal_repo(
          root,
          entries: [{ 'path' => 'docs/local/', 'kind' => 'uc_only', 'id' => 'local-docs' }],
          hyku_patched: [],
          watch_globs: ['orphan.rb'],
          extra_files: ['orphan.rb']
        )

        result = described_class.new(root: root, env: {}).call
        expect(result.ok).to be(false)
        expect(result.errors.join).to match(/watched file not listed/)
      end
    end

    it 'fails when a required manifest entry is missing on disk' do
      Dir.mktmpdir do |dir|
        root = Pathname.new(dir)
        write_minimal_repo(
          root,
          entries: [
            { 'path' => 'docs/local/', 'kind' => 'uc_only', 'id' => 'local-docs' },
            { 'path' => 'missing/path.rb', 'kind' => 'uc_only', 'id' => 'gone' }
          ],
          hyku_patched: []
        )

        result = described_class.new(root: root, env: {}).call
        expect(result.ok).to be(false)
        expect(result.errors.join).to match(/manifest entry missing on disk: missing\/path\.rb/)
      end
    end
  end

  def write_minimal_repo(root, entries:, hyku_patched:, watch_globs: [], extra_files: [])
    docs = root.join('docs/local')
    FileUtils.mkdir_p(docs)
    docs.join('uc-hyku-customizations.md').write("# inventory\n")
    root.join('README.md').write("readme\n")
    extra_files.each do |rel|
      path = root.join(rel)
      FileUtils.mkdir_p(path.dirname)
      path.write("x\n")
    end

    manifest = {
      'inventory_doc' => 'docs/local/uc-hyku-customizations.md',
      'watch_globs' => watch_globs,
      'hyku_patched' => hyku_patched,
      'entries' => entries
    }
    docs.join('uc-hyku-customizations.manifest.yml').write(YAML.dump(manifest))
  end
end
