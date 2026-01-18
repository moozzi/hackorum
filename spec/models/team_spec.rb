# frozen_string_literal: true

require "rails_helper"

RSpec.describe Team, type: :model do
  let(:user) { create(:user) }
  let(:user2) { create(:user) }
  let(:team) { Team.create!(name: "Team1") }

  before do
    TeamMember.add_member(team: team, user: user, role: :admin)
  end

  it "detects members and admins" do
    expect(team.member?(user)).to be(true)
    expect(team.admin?(user)).to be(true)
    expect(team.member?(user2)).to be(false)
  end

  describe "visibility" do
    it "defaults to private" do
      expect(team.visibility).to eq("private")
      expect(team.visibility_private?).to be(true)
    end

    it "can be set to visible or open" do
      team.update!(visibility: :visible)
      expect(team.visibility_visible?).to be(true)

      team.update!(visibility: :open)
      expect(team.visibility_open?).to be(true)
    end
  end

  describe "#accessible_to?" do
    it "allows members to access private teams" do
      expect(team.accessible_to?(user)).to be(true)
      expect(team.accessible_to?(user2)).to be(false)
    end

    it "allows anyone to access visible teams" do
      team.update!(visibility: :visible)
      expect(team.accessible_to?(user)).to be(true)
      expect(team.accessible_to?(user2)).to be(true)
      expect(team.accessible_to?(nil)).to be(true)
    end

    it "allows anyone to access open teams" do
      team.update!(visibility: :open)
      expect(team.accessible_to?(user)).to be(true)
      expect(team.accessible_to?(user2)).to be(true)
      expect(team.accessible_to?(nil)).to be(true)
    end
  end

  describe "#mentionable_by?" do
    it "allows only members to mention private teams" do
      expect(team.mentionable_by?(user)).to be(true)
      expect(team.mentionable_by?(user2)).to be(false)
    end

    it "allows only members to mention visible teams" do
      team.update!(visibility: :visible)
      expect(team.mentionable_by?(user)).to be(true)
      expect(team.mentionable_by?(user2)).to be(false)
    end

    it "allows anyone to mention open teams" do
      team.update!(visibility: :open)
      expect(team.mentionable_by?(user)).to be(true)
      expect(team.mentionable_by?(user2)).to be(true)
    end
  end
end
