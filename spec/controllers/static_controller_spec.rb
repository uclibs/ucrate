
# frozen_string_literal: true

require 'rails_helper'
describe StaticController do
  describe '#about' do
    it 'renders the about page' do
      get :about
      expect(response.status).to be == 200
      expect(response).to render_template('static/about')
    end
  end
  describe '#coll_policy' do
    it 'renders the collection policy page' do
      get :coll_policy
      expect(response.status).to be == 200
      expect(response).to render_template('static/coll_policy')
    end
  end
  describe '#format_advice' do
    it 'renders the format advice page' do
      get :format_advice
      expect(response.status).to be == 200
      expect(response).to render_template('static/format_advice')
    end
  end
  describe '#faq' do
    it 'renders the faq advice page' do
      get :faq
      expect(response.status).to be == 200
      expect(response).to render_template('static/faq')
    end
  end
  describe '#documenting_data' do
    it 'renders the documenting_data page' do
      get :documenting_data
      expect(response.status).to be == 200
      expect(response).to render_template('static/documenting_data_help')
    end
  end
  describe '#creators_rights' do
    it 'renders the creators_rights page' do
      get :creators_rights
      expect(response.status).to be == 200
      expect(response).to render_template('static/creators_rights')
    end
  end
  describe '#student_work_help' do
    it 'renders the student_work_help page' do
      get :student_work_help
      expect(response.status).to be == 200
      expect(response).to render_template('static/student_work_help')
    end
  end
  describe '#advisor_guidelines' do
    it 'renders the advisor_guidelines page' do
      get :advisor_guidelines
      expect(response.status).to be == 200
      expect(response).to render_template('static/advisor_guidelines')
    end
  end
  describe '#student_instructions' do
    it 'renders the student_instructions page' do
      get :student_instructions
      expect(response.status).to be == 200
      expect(response).to render_template('static/student_instructions')
    end
  end

  describe '#help' do
    it 'renders the help page' do
      get :help
      expect(response.status).to be == 200
      expect(response).to render_template('static/help')
    end
  end

  describe '#doi_help' do
    it 'renders the doi_help page' do
      get :doi_help
      expect(response.status).to be == 200
      expect(response).to render_template('static/doi_help')
    end
  end
  describe '#login' do
    let(:user) { FactoryBot.create(:user) }

    before do
      controller.stub(:current_user).and_return(user)
    end
    it 'redirects to dashboard when already logged in' do
      get :login
      response.should redirect_to(Hyrax::Engine.routes.url_helpers.dashboard_path)
    end
  end
end
