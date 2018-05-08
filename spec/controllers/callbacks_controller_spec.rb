# frozen_string_literal: true

require 'rails_helper'

describe CallbacksController do

  describe 'omniauth-orcid' do
    let(:uid) { 'sixplus2@test.com' }
    let(:provider) { :orcid }
    before do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      omniauth_hash_orcid = { "provider": "orcid",
                              "uid": "0000-0003-2012-0010",
                              "info": {
                                "name": "John Smith",
                                "email": uid
                              },
                              "credentials": {
                                "token": "e82938fa-a287-42cf-a2ce-f48ef68c9a35",
                                "refresh_token": "f94c58dd-b452-44f4-8863-0bf8486a0071",
                                "expires_at": 1_979_903_874,
                                "expires": true
                              },
                              "extra": {
                              } }
      OmniAuth.config.add_mock(provider, omniauth_hash_orcid)
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[provider]
    end

    context 'with a user who is already logged in' do
      let(:user) { FactoryBot.create(:user) }
      before do
        allow(controller).to receive(:current_user) { user }
      end

      it 'redirects to catalog index path with success notice' do
        get provider
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to match(/You have successfully connected with your ORCID record/)
      end
    end
  end

  describe 'omniauth-shibboleth' do
    let(:uid) { 'sixplus2@test.com' }
    let(:provider) { :shibboleth }

    before do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      omniauth_hash = { provider: 'shibboleth',
                        uid: uid,
                        extra: {
                          raw_info: {
                            mail: uid,
                            givenName: 'Fake',
                            sn: 'User',
                            uceduPrimaryAffiliation: 'staff',
                            ou: 'department'
                          }
                        } }
      OmniAuth.config.add_mock(provider, omniauth_hash)
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[provider]
    end

    context 'with a user who is already logged in' do
      let(:user) { FactoryBot.create(:user) }

      before do
        controller.stub(:current_user).and_return(user)
      end
      it 'redirects to the dashboard' do
        get provider
        response.should redirect_to(Hyrax::Engine.routes.url_helpers.dashboard_path)
      end
    end

    shared_examples 'Shibboleth login' do
      it 'assigns the user and redirects' do
        get provider
        expect(flash[:notice]).to match(/You are now signed in as */)
        expect(assigns(:user).email).to eq(email)
        expect(response).to be_redirect
      end
    end

    context 'with a brand new user' do
      let(:email) { uid }

      it_behaves_like 'Shibboleth login'
    end

    context "when the parameter is set" do
      before do
        allow(controller).to receive(:parameter_set?).and_return(true)
        get provider
      end

      it 'redirects to the welcome page' do
        response.should redirect_to(Rails.application.routes.url_helpers.welcome_page_index_path)
      end
    end

    context 'with a brand new user when Shibboleth email is not defined' do
      before do
        omniauth_hash = { provider: 'shibboleth',
                          uid: uid,
                          extra: {
                            raw_info: {
                              title: 'title',
                              telephoneNumber: '123-456-7890',
                              givenName: 'Fake',
                              sn: 'User',
                              uceduPrimaryAffiliation: 'staff',
                              ou: 'department'
                            }
                          } }
        OmniAuth.config.add_mock(provider, omniauth_hash)
        request.env["omniauth.auth"] = OmniAuth.config.mock_auth[provider]
      end
      let(:email) { uid }

      it_behaves_like 'Shibboleth login'
    end

    context 'with a brand new user when Shibboleth email is blank' do
      before do
        omniauth_hash = { provider: 'shibboleth',
                          uid: uid,
                          extra: {
                            raw_info: {
                              mail: '',
                              title: 'title',
                              telephoneNumber: '123-456-7890',
                              givenName: 'Fake',
                              sn: 'User',
                              uceduPrimaryAffiliation: 'staff',
                              ou: 'department'
                            }
                          } }
        OmniAuth.config.add_mock(provider, omniauth_hash)
        request.env["omniauth.auth"] = OmniAuth.config.mock_auth[provider]
      end
      let(:email) { uid }

      it_behaves_like 'Shibboleth login'
    end

    context 'with a registered user who has previously logged in' do
      let!(:user) { FactoryBot.create(:shibboleth_user, count: 1) }
      let(:email) { user.email }

      it_behaves_like 'Shibboleth login'
    end

    context 'with a registered user who has never logged in' do
      let!(:user) { FactoryBot.create(:shibboleth_user, count: 0) }
      let(:email) { user.email }

      it_behaves_like 'Shibboleth login'
    end

    context 'with a brand new user when Shibboleth email is blank and uid is nil' do
      before do
        omniauth_hash = { provider: 'shibboleth',
                          uid: nil,
                          extra: {
                            raw_info: {
                              mail: '',
                              title: 'title',
                              telephoneNumber: '123-456-7890',
                              givenName: 'Fake',
                              sn: 'User',
                              uceduPrimaryAffiliation: 'staff',
                              ou: 'department'
                            }
                          } }
        OmniAuth.config.add_mock(provider, omniauth_hash)
        request.env["omniauth.auth"] = OmniAuth.config.mock_auth[provider]
      end
      let(:email) { uid }

      it 'raises an error' do
        expect { get provider }.to raise_error('User does not have an email address or uid')
      end
    end
  end
end
