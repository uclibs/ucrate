# frozen_string_literal: true

require 'rails_helper'

RSpec.describe JobIoWrapper, type: :model do
  let(:user) { build(:user) }
  let(:path) { fixture_path + '/world.png' }
  let(:file_set_id) { 'bn999672v' }
  let(:file_set) { instance_double(FileSet, id: file_set_id, uri: 'http://127.0.0.1/rest/fake/bn/99/96/72/bn999672v') }
  let(:args) { { file_set_id: file_set_id, user: user, path: path } }

  subject(:wrapper) { described_class.new(args) }

  it 'requires attributes' do
    expect { described_class.create! }.to raise_error ActiveRecord::RecordInvalid
    expect { described_class.create!(file_set_id: file_set_id, path: path) }.to raise_error ActiveRecord::RecordInvalid
    expect { described_class.create!(file_set_id: file_set_id, user: user) }.to raise_error ActiveRecord::RecordInvalid
    expect { subject.save! }.not_to raise_error
  end

  describe '.create_with_wrapped_params!' do
    let(:local_file) { File.open(path) }
    let(:relation) { :remastered }

    subject { described_class.create_with_varied_file_handling!(user: user, file_set: file_set, file: file, relation: relation) }

    context 'with Rack::Test::UploadedFile' do
      let(:file) { Rack::Test::UploadedFile.new(path, 'image/png') }

      it 'creates a JobIoWrapper' do
        expected_create_args = { user: user, relation: relation.to_s, file_set_id: file_set.id, path: file.path, original_name: 'world.png' }
        expect(JobIoWrapper).to receive(:create!).with(expected_create_args)
        subject
      end
    end

    context 'with ::File' do
      let(:file) { local_file }

      it 'creates a JobIoWrapper' do
        expected_create_args = { user: user, relation: relation.to_s, file_set_id: file_set.id, path: file.path }
        expect(JobIoWrapper).to receive(:create!).with(expected_create_args)
        subject
      end
    end

    context 'with Hyrax::UploadedFile' do
      let(:file) { Hyrax::UploadedFile.new(user: user, file_set_uri: file_set.uri, file: local_file) }

      it 'creates a JobIoWrapper' do
        expected_create_args = { user: user, relation: relation.to_s, file_set_id: file_set.id, uploaded_file: file, path: file.uploader.path }
        expect(JobIoWrapper).to receive(:create!).with(expected_create_args)
        subject
      end
    end
  end

  describe 'uploaded_file' do
    let(:other_path) { fixture_path + '/image.jpg' }
    let(:uploaded_file) { Hyrax::UploadedFile.new(user: user, file_set_uri: file_set.uri, file: File.new(other_path)) }

    # context 'path only' is the rest of this file

    context 'in leiu of path' do
      let(:args) { { file_set_id: file_set_id, user: user, uploaded_file: uploaded_file } }

      it 'validates and persists' do
        expect { subject.save! }.not_to raise_error
      end
      it '#read routes to the uploaded_file' do
        expect(subject).to receive(:file_from_uploaded_file!).and_call_original
        subject.read
      end
      it '#mime_type and #original_name draw from the uploaded_file' do
        expect(subject.mime_type).to eq('image/jpeg')
        expect(subject.original_name).to eq('image.jpg')
      end
    end

    context 'with remote file' do
      let(:path) { nil }
      before do
        allow_any_instance_of(JobIoWrapper).to receive(:file_set_filename).and_return("changed_name.jpg")
      end
      it 'extracts filename from http get' do
        allow_any_instance_of(JobIoWrapper).to receive(:file_set_filename).and_return("changed_name.jpg")
        expect(subject.original_name).to eq('changed_name.jpg')
      end
    end

    context 'along with path (on shared filesystem)' do
      let(:args) { { file_set_id: file_set_id, user: user, uploaded_file: uploaded_file, path: path } }

      it 'validates and persists' do
        expect { subject.save! }.not_to raise_error
      end
      it '#read routes to the path' do
        expect(subject).not_to receive(:file_from_uploaded_file!)
        subject.read
      end
      it '#mime_type and #original_name draw from the uploaded_file' do
        expect(subject.mime_type).to eq('image/jpeg')
        expect(subject.original_name).to eq('image.jpg')
      end
    end

    context 'along with path (independent worker filesystems)' do
      let(:deadpath) { fixture_path + '/some_file_that_does_not_exist.wav' }
      let(:args) { { file_set_id: file_set_id, user: user, uploaded_file: uploaded_file, path: deadpath } }

      it 'validates and persists' do
        expect { subject.save! }.not_to raise_error
      end
      it '#read routes to the uploaded_file' do
        expect(subject).to receive(:file_from_uploaded_file!).and_call_original
        subject.read
      end
      it '#mime_type and #original_name draw from the uploaded_file' do
        expect(subject.mime_type).to eq('image/jpeg')
        expect(subject.original_name).to eq('image.jpg')
      end
    end
  end

  it 'has a #user' do
    expect(subject.user).to eq(user)
    expect(subject.user_id).to eq(user.id)
  end

  describe '#relation' do
    it 'has default value' do
      expect(subject.relation).to eq('original_file')
    end
    it 'accepts new value' do
      subject.relation = 'remastered'
      expect(subject.relation).to eq('remastered')
    end
  end

  describe '#original_name' do
    it 'extracts default value' do
      expect(subject.original_name).to eq('world.png')
    end
    it 'accepts new value' do
      subject.original_name = 'foobar'
      expect(subject.original_name).to eq('foobar')
    end
  end

  describe '#mime_type' do
    it 'extracts default value' do
      expect(subject.mime_type).to eq('image/png')
    end
    it 'accepts new value' do
      subject.mime_type = 'text/plain'
      expect(subject.mime_type).to eq('text/plain')
    end
    it 'uses original_name if set' do
      subject.original_name = '汉字.jpg'
      expect(subject.mime_type).to eq('image/jpeg')
      subject.original_name = 'no_suffix'
      expect(subject.mime_type).to eq('application/octet-stream')
    end
  end

  describe '#file_actor' do
    let(:file_actor) { Hyrax::Actors::FileActor.new(file_set, subject.relation, user) }

    it 'produces an appropriate FileActor' do
      allow(FileSet).to receive(:find).with(file_set_id).and_return(file_set)
      expect(subject.file_actor).to eq(file_actor)
    end
  end

  describe '#read' do
    it 'delivers contents' do
      expect(subject.read).to eq(File.open(path, 'rb').read)
    end
    context 'text file' do
      let(:path) { fixture_path + '/png_fits.xml' }

      it 'delivers contents' do
        expect(subject.read).to eq(File.open(path, 'rb').read)
      end
    end
  end
end
