# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::ContactFormController do
  routes { Hyrax::Engine.routes }
  let(:user) { create(:user) }
  let(:required_params) do
    {
      category: "Depositing content",
      name: "Gandalf the Grey",
      email: "gandalf@middle.earth",
      subject: "When in doubt,",
      message: "Follow your nose!"
    }
  end

  describe 'while user is unauthenticated' do
    it 'successfully allows reCaptcha' do
      described_class.any_instance.stub(:verify_google_recaptcha).and_return(true)
      Hyrax::ContactMailer.any_instance.stub(:mail).and_return(true)
      post :create, params: { contact_form: required_params }
      expect(flash[:notice]).to match(/Thank you for your message/)
    end

    it 'fails on reCaptcha failure' do
      post :create, params: { contact_form: required_params }
      expect(flash[:error]).to match(/You must complete the Captcha to confirm the form/)
    end
  end

  describe "while user is authenticated" do
    before { sign_in(user) }

    describe "#new" do
      subject { response }

      before { get :new }
      it { is_expected.to be_success }
    end

    describe "#create" do
      subject { flash }

      before { post :create, params: { contact_form: params } }
      context "with the required parameters" do
        let(:params) { required_params }

        its(:notice) { is_expected.to eq("Thank you for your message!") }
      end

      context "without a name" do
        let(:params)  { required_params.except(:name) }

        its([:error]) { is_expected.to eq("Sorry, this message was not sent successfully. You must complete the Captcha to confirm the form. Name can't be blank") }
      end

      context "without an email" do
        let(:params)  { required_params.except(:email) }

        its([:error]) { is_expected.to eq("Sorry, this message was not sent successfully. You must complete the Captcha to confirm the form. Email can't be blank") }
      end

      context "without a subject" do
        let(:params)  { required_params.except(:subject) }

        its([:error]) { is_expected.to eq("Sorry, this message was not sent successfully. You must complete the Captcha to confirm the form. Subject can't be blank") }
      end

      context "without a message" do
        let(:params)  { required_params.except(:message) }

        its([:error]) { is_expected.to eq("Sorry, this message was not sent successfully. You must complete the Captcha to confirm the form. Message can't be blank") }
      end

      context "with an invalid email" do
        let(:params)  { required_params.merge(email: "bad-wolf") }

        its([:error]) { is_expected.to eq("Sorry, this message was not sent successfully. You must complete the Captcha to confirm the form. Email is invalid") }
      end
    end

    describe "#after_deliver" do
      context "with a successful email" do
        it "calls #after_deliver" do
          expect(controller).to receive(:after_deliver)
          post :create, params: { contact_form: required_params }
        end
      end
      context "with an unsuccessful email" do
        it "does not call #after_deliver" do
          expect(controller).not_to receive(:after_deliver)
          post :create, params: { contact_form: required_params.except(:email) }
        end
      end
    end

    describe "test configuration values" do
      context "for the contact form" do
        it "check contact email" do
          expect(Hyrax.config.contact_email).to eq 'scholar@uc.edu'
        end
        it "check form name" do
          expect(Hyrax.config.subject_prefix).to eq 'Scholar@UC Contact form:'
        end
      end
    end

    context "when encoutering a RuntimeError" do
      let(:logger) { double(info?: true) }

      before do
        allow(controller).to receive(:logger).and_return(logger)
        allow(Hyrax::ContactMailer).to receive(:contact).and_raise(RuntimeError)
      end
      it "is logged via Rails" do
        expect(logger).to receive(:error).with("Contact form failed to send: #<RuntimeError: RuntimeError>")
        post :create, params: { contact_form: required_params }
      end
    end
  end
end
