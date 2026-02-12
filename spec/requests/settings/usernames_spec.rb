# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Settings::Usernames", type: :request do
  def sign_in(user)
    al = create(:alias, user: user, email: "login-#{user.id}@example.com")
    user.person.update!(default_alias_id: al.id) if user.person.default_alias_id.nil?
    Alias.by_email(al.email).update_all(verified_at: Time.current)
    user.update!(password: "secret", password_confirmation: "secret") unless user.password_digest.present?
    post session_path, params: { email: al.email, password: "secret" }
  end

  describe "PATCH /settings/username" do
    it "updates username successfully" do
      user = create(:user)
      sign_in(user)

      patch settings_username_path, params: { user: { username: "new_username" } }
      expect(response).to redirect_to(settings_profile_path)
      expect(flash[:notice]).to eq("Username updated")
      expect(user.reload.username).to eq("new_username")
    end

    it "shows error when username is taken by another user" do
      create(:user, username: "taken")
      user = create(:user, username: "original")
      sign_in(user)

      patch settings_username_path, params: { user: { username: "taken" } }
      expect(response).to redirect_to(settings_profile_path)
      expect(flash[:alert]).to match(/already been taken/i)
      expect(user.reload.username).to eq("original")
    end

    it "shows error when username is reserved by a team" do
      Team.create!(name: "devteam")
      user = create(:user, username: "original")
      sign_in(user)

      patch settings_username_path, params: { user: { username: "devteam" } }
      expect(response).to redirect_to(settings_profile_path)
      expect(flash[:alert]).to match(/already taken/i)
      expect(user.reload.username).to eq("original")
    end

    it "preserves old reservation when update is rejected" do
      Team.create!(name: "blocked")
      user = create(:user, username: "keeper")
      sign_in(user)

      patch settings_username_path, params: { user: { username: "blocked" } }
      expect(user.reload.username).to eq("keeper")
      expect(NameReservation.find_by(name: "keeper")).to be_present
    end
  end
end
