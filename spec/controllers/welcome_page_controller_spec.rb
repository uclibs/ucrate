# frozen_string_literal: true

require 'rails_helper'

describe WelcomePageController, type: :controller do
  context 'without signed in user' do
    describe 'index' do
      it 'renders the page' do
        get :index
        expect(response.status).to eq(200)
        expect(response).to render_template('index')
      end
    end
  end

  context 'with signed in user' do
    before do
      sign_in(user)
    end

    describe 'without already waiving the page' do
      let(:user) { FactoryBot.create(:user, waived_welcome_page: false) }

      describe '.user_waived_welcome_page?' do
        it 'returns the status of waived_welcome_page' do
          expect(controller.user_waived_welcome_page?).to eq user.waived_welcome_page
        end
      end

      describe '#index' do
        it 'renders the page' do
          get :index
          expect(response.status).to eq(200)
          expect(response).to render_template('index')
        end
      end

      describe '#create' do
        describe 'if welcome page waived' do
          let(:params) { { waive_welcome_page: '1', commit: I18n.t('hyrax.welcome.waive_page') } }

          before do
            post :create, params: params
          end
          it 'redirects to landing page' do
            expect(response).to redirect_to(Hyrax::Engine.routes.url_helpers.root_path)
          end

          it 'sets user waived_welcome_page to true' do
            user.reload
            expect(user.waived_welcome_page).to be true
          end
        end

        describe 'if welcome page not waived' do
          let(:params) { { waive_welcome_page: false } }

          before do
            post :create, params: params
          end
          it 'redirects to landing page' do
            expect(response).to redirect_to(Hyrax::Engine.routes.url_helpers.root_path)
          end

          it 'keeps user.waived_welcome_page as false' do
            expect(user.waived_welcome_page).to be false
          end
        end
      end
    end

    describe 'after waiving the page' do
      let(:user) { FactoryBot.create(:user, waived_welcome_page: true) }

      describe '#index' do
        it 'renders the page' do
          get :index
          expect(response.status).to eq(200)
          expect(response).to render_template('index')
        end
      end
    end
  end
end
