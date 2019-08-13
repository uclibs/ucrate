# frozen_string_literal: true

shared_examples 'is remotely identifiable by doi' do
  describe '#locally_managed_remote_identifier?' do
    let(:work) { FactoryBot.build(described_class.to_s.underscore.to_sym) }

    context 'when #identifier_url is set' do
      before { work.stub(:identifier_url).and_return("http://example.org") }
      it 'is true' do
        expect(work.locally_managed_remote_identifier?).to eq(true)
      end
    end

    context 'when #identifier_url is not set' do
      before { work.stub(:identifier_url).and_return(nil) }
      it 'is false' do
        expect(work.locally_managed_remote_identifier?).to eq(false)
      end
    end
  end

  describe '#doi_status' do
    let(:work) { FactoryBot.build(described_class.to_s.underscore.to_sym) }

    context 'when the work is public' do
      before { work.stub(:visibility).and_return(Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC) }
      context 'and a DOI has already been minted' do
        before { work.stub(:locally_managed_remote_identifier?).and_return(true) }
        it 'is "public"' do
          expect(work.doi_status).to eq("publish")
        end
      end

      context 'and a DOI has not already been minted' do
        before { work.stub(:locally_managed_remote_identifier?).and_return(false) }
        it 'is "public"' do
          expect(work.doi_status).to eq("publish")
        end
      end
    end

    context 'when the work is embargoed' do
      before { work.stub(:visibility).and_return(Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_EMBARGO) }
      context 'and a DOI has already been minted' do
        before { work.stub(:locally_managed_remote_identifier?).and_return(true) }

        context 'and the DOI is still registered' do
          before { work.stub(:identifier_status).and_return("registered") }
          it 'is "registered"' do
            expect(work.doi_status).to eq("hide")
          end
        end
        context 'and the DOI is not still registered' do
          before { work.stub(:identifier_status).and_return("publish") }
          it 'is "registered"' do
            expect(work.doi_status).to eq("hide")
          end
        end
      end

      context 'and a DOI has not already been minted' do
        before { work.stub(:locally_managed_remote_identifier?).and_return(false) }
        it 'is "registered"' do
          expect(work.doi_status).to eq("hide")
        end
      end
    end

    context 'when the work is authenticated' do
      before { work.stub(:visibility).and_return(Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED) }
      context 'and a DOI has already been minted' do
        before { work.stub(:locally_managed_remote_identifier?).and_return(true) }

        context 'and the DOI is still registered' do
          before { work.stub(:identifier_status).and_return("register") }
          it 'is "registered"' do
            expect(work.doi_status).to eq("hide")
          end
        end
        context 'and the DOI is not still registered' do
          before { work.stub(:identifier_status).and_return("publish") }
          it 'is "registered"' do
            expect(work.doi_status).to eq("hide")
          end
        end
      end

      context 'and a DOI has not already been minted' do
        before { work.stub(:locally_managed_remote_identifier?).and_return(false) }
        it 'is "registered"' do
          expect(work.doi_status).to eq("hide")
        end
      end
    end

    context 'when the work is restricted' do
      before { work.stub(:visibility).and_return(Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE) }
      context 'and a DOI has already been minted' do
        before { work.stub(:locally_managed_remote_identifier?).and_return(true) }

        context 'and the DOI is still registered' do
          before { work.stub(:identifier_status).and_return("register") }
          it 'is "registered"' do
            expect(work.doi_status).to eq("hide")
          end
        end
        context 'and the DOI is not still registered' do
          before { work.stub(:identifier_status).and_return("publish") }
          it 'is "unavailable"' do
            expect(work.doi_status).to eq("hide")
          end
        end
      end

      context 'and a DOI has not already been minted' do
        before { work.stub(:locally_managed_remote_identifier?).and_return(false) }
        it 'is "registered"' do
          expect(work.doi_status).to eq("hide")
        end
      end
    end
  end

  context "doi minting" do
    subject { described_class.new }

    it { is_expected.to respond_to(:doi) }
    it { is_expected.to respond_to(:doi=) }
    it { is_expected.to respond_to(:existing_identifier) }
    it { is_expected.to respond_to(:existing_identifier=) }
    it { is_expected.to respond_to(:doi_assignment_strategy=) }
    it { is_expected.to respond_to(:doi_assignment_strategy) }
    it { is_expected.to respond_to(:identifier_url) }
    it { is_expected.to respond_to(:identifier_url=) }
    it { is_expected.to respond_to(:identifier_status) }
    it { is_expected.to respond_to(:identifier_status=) }

    context 'with valid attributes' do
      let(:attributes) {
        {
          publisher: ['An Interesting Chap!'],
          id: "3t94g081v",
          date_uploaded: Date.parse('2013-01-30'),
          date_modified: Date.parse('2013-01-30'),
          title: ["A Title"]
        }
      }

      it 'mints!' do
        work = build(:work, attributes: attributes)
        work.stub(:save).and_return(true)
        VCR.use_cassette "remotely_identified_doi_mint_work", record: :new_episodes do
          expect {
            Hydra::RemoteIdentifier.mint(:doi, work)
          }.to change(work, :doi).from(nil)
        end
      end
    end

    context 'with invalid attributes' do
      subject { build(:work, attributes: attributes) }
      let(:attributes) { { publisher: [] } }
      it 'fails validation' do
        expect(subject).to receive(:remote_doi_assignment_strategy?).and_return(true)
        expect(subject).not_to be_valid
        expect(subject.errors[:publisher]).to eq(["is required for remote DOI minting"])
      end
    end

    describe 'MintingBehavior' do
      shared_examples 'minting behavior returning value' do
        it 'returns the returning value' do
          expect(subject.apply_doi_assignment_strategy(&perform_persistence_block)).to eq(returning_value)
        end
      end
      subject { described_class.new.tap { |m| m.extend RemotelyIdentifiedByDoi::MintingBehavior } }
      let(:returning_value) { true }
      let(:perform_persistence_block) { ->(*) { returning_value } }

      context 'with indentifier_url attribute set' do
        let(:identifier_request) { double }
        before do
          subject.stub(:identifier_url) { 'http://example.org' }
        end

        it 'calls #identifier_request' do
          expect(subject).to receive(:identifier_request)
          subject.apply_doi_assignment_strategy(&perform_persistence_block)
        end
      end

      context 'with doi_assignment_strategy accessor' do
        let(:doi_assignment_strategy) { nil }

        context '#apply_doi_assignment_strategy' do
          let(:accessor_name) { 'mint_doi' }
          let(:existing_identifier) { 'abc' }
          let(:doi_remote_service) { double(accessor_name: accessor_name) }
          before do
            subject.existing_identifier = existing_identifier
            subject.doi_assignment_strategy = doi_assignment_strategy
            subject.doi_remote_service = doi_remote_service
          end

          context 'with explicit identifier specified' do
            it_behaves_like 'minting behavior returning value'

            let(:doi_assignment_strategy) { 'already_got_one' }
            it 'allows explicit assignment of doi' do
              expect {
                subject.apply_doi_assignment_strategy(&perform_persistence_block)
              }.to change(subject, :doi).from(nil).to(existing_identifier)
            end

            it 'yields the subject' do
              expect { |b| subject.apply_doi_assignment_strategy(&b) }.to yield_with_args(subject)
            end

            it 'does not set identifier_url attribute' do
              expect {
                subject.apply_doi_assignment_strategy(&perform_persistence_block)
              }.not_to change(subject, :identifier_url)
            end

            it 'does not set doi_status' do
              expect {
                subject.apply_doi_assignment_strategy(&perform_persistence_block)
              }.not_to change(subject, :doi_status)
            end
          end

          context 'with not now specified' do
            it_behaves_like 'minting behavior returning value'

            let(:doi_assignment_strategy) { 'not_now' }

            it 'returns the returning value' do
              expect(subject.apply_doi_assignment_strategy(&perform_persistence_block)).to eq(returning_value)
            end

            it 'sets the doi to nil' do
              subject.doi = "doi:foo"
              subject.save
              expect {
                subject.apply_doi_assignment_strategy(&perform_persistence_block)
              }.to change(subject, :doi).to(nil)
            end

            it 'sets the existing identifier to nil' do
              subject.existing_identifier = "doi:foo"
              subject.save
              expect {
                subject.apply_doi_assignment_strategy(&perform_persistence_block)
              }.to change(subject, :existing_identifier).to(nil)
            end

            it 'yields the subject' do
              expect { |b| subject.apply_doi_assignment_strategy(&b) }.to yield_with_args(subject)
            end

            it 'does not set identifier_url attribute' do
              expect {
                subject.apply_doi_assignment_strategy(&perform_persistence_block)
              }.not_to change(subject, :identifier_url)
            end

            it 'does not set doi_status' do
              expect {
                subject.apply_doi_assignment_strategy(&perform_persistence_block)
              }.not_to change(subject, :doi_status)
            end
          end

          context 'with request for minting' do
            let(:doi_assignment_strategy) { accessor_name }
            context 'with valid save' do
              before do
                doi_remote_service.should_receive(:mint).with(subject).and_return(true)
              end
              it_behaves_like 'minting behavior returning value'
              let(:returning_value) { true }

              ## These specs are odd - the real spec is the before block above
              it 'requests a minting' do
                expect {
                  subject.apply_doi_assignment_strategy(&perform_persistence_block)
                }.not_to change(subject, :doi).from(nil)
              end
            end

            context 'with invalid save' do
              it_behaves_like 'minting behavior returning value'
              let(:returning_value) { false }
              it 'does not request a minting if the perform_persistence_block failed' do
                expect {
                  subject.apply_doi_assignment_strategy(&perform_persistence_block)
                }.not_to change(subject, :doi).from(nil)
              end
              it 'does not set identifier_url attribute' do
                expect {
                  subject.apply_doi_assignment_strategy(&perform_persistence_block)
                }.not_to change(subject, :identifier_url)
              end
            end
          end
        end

        context 'without doi_assignment_strategy accessor' do
          it_behaves_like 'minting behavior returning value'

          it 'yields the subject' do
            expect { |b| subject.apply_doi_assignment_strategy(&b) }.to yield_with_args(subject)
          end
        end
      end
    end
  end

  context "deleting a work" do
    let(:work) { FactoryBot.create(described_class.to_s.underscore.to_sym) }

    context "when a DOI has been minted" do
      before do
        work.stub(:identifier_url).and_return("http://example.org")
      end

      it "removes the identifier" do
        expect(IdentifierDeleteJob).to receive(:perform_later)
        work.destroy
      end
    end

    context "when a DOI has not been minted" do
      before { work.stub(:identifier_url).and_return(nil) }

      it "does not remove the identifier" do
        expect(IdentifierDeleteJob).not_to receive(:perform_later)
        work.destroy
      end
    end
  end
end
