# frozen_string_literal: true
RSpec.describe Hyrax::Forms::BatchEditForm do
  let(:model) { GenericWork.new }
  let(:work1) do
    create :generic_work,
           title: ["title 1"],
           creator: ["Wilma"],
           language: ['en'],
           description: ['description1'],
           license: ['license1'],
           subject: ['subject1'],
           related_url: ['related_url1']
  end

  # Using a different work type in order to show that the form supports
  # batches containing multiple types of works
  let(:work2) do
    create :image,
           title: ["title 2"],
           creator: ["Fred"],
           publisher: ['Rand McNally'],
           language: ['en'],
           description: ['description2'],
           license: ['license2'],
           subject: ['subject2'],
           related_url: ['related_url2']
  end

  let(:batch) { [work1.id, work2.id] }
  let(:form) { described_class.new(model, ability, batch) }
  let(:ability) { Ability.new(user) }
  let(:user) { build(:user, display_name: 'Jill Z. User') }

  describe "#terms" do
    subject { form.terms }

    it do
      is_expected.to eq [:creator,
                         :alternate_title,
                         :subject,
                         :geo_subject,
                         :language,
                         :related_url]
    end
  end

  describe "#model" do
    it "combines the models in the batch" do
      expect(form.model.creator).to match_array ["Wilma", "Fred"]
      expect(form.model.subject).to match_array ["subject1", "subject2"]
      expect(form.model.language).to match_array ["en"]
      expect(form.model.related_url).to match_array ["related_url1", "related_url2"]
    end
  end

  describe ".build_permitted_params" do
    subject { described_class.build_permitted_params }

    it do
      is_expected.to eq [{ creator: [] },
                         { subject: [] },
                         { geo_subject: [] },
                         { language: [] },
                         { alternate_title: [] },
                         { related_url: [] },
                         { permissions_attributes: [:type, :name, :access, :id, :_destroy] },
                         :on_behalf_of,
                         :version,
                         :add_works_to_collection,
                         :visibility_during_embargo,
                         :embargo_release_date,
                         :visibility_after_embargo,
                         :visibility_during_lease,
                         :lease_expiration_date,
                         :visibility_after_lease,
                         :visibility,
                         { based_near_attributes: [:id, :_destroy] }]
    end
  end
end
