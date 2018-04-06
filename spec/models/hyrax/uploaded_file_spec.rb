require 'rails_helper'

RSpec.describe Hyrax::UploadedFile, type: :model do
  context 'when an uploaded file has a virus'

  let(:file) { fixture_file_upload('/world.png') }

  subject(:create_with_virus) { described_class.create(file: file) }

  before do
    allow(Hydra::Works::VirusCheckerService).to receive(:file_has_virus?).and_return(true)
  end

  it "fails validation" do
    expect(create_with_virus.valid?).to eq false
    expect(create_with_virus.errors[:base]).to eq ["Virus detected in file"]
  end
end
