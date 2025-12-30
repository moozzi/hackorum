require 'rails_helper'

RSpec.describe 'People profile', type: :request do
  it 'renders a person profile page' do
    person = create(:person)
    alias_record = create(:alias, person: person, name: 'Profile Person', email: 'profile@example.com')
    person.update!(default_alias_id: alias_record.id)

    get person_path(alias_record.email)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Profile Person')
    expect(response.body).to include('profile@example.com')
  end
end
