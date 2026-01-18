# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, "mention restriction", type: :model do
  let(:user) { create(:user) }
  let(:teammate) { create(:user) }
  let(:non_teammate) { create(:user) }
  let(:team) { create(:team) }

  before do
    create(:team_member, team: team, user: user)
    create(:team_member, team: team, user: teammate)
  end

  describe "mention_restriction" do
    it "defaults to anyone" do
      expect(user.mention_restriction).to eq("anyone")
      expect(user.anyone?).to be(true)
    end

    it "can be set to teammates_only" do
      user.update!(mention_restriction: :teammates_only)
      expect(user.teammates_only?).to be(true)
    end
  end

  describe "#shares_team_with?" do
    it "returns true for users in the same team" do
      expect(user.shares_team_with?(teammate)).to be(true)
    end

    it "returns false for users not in any shared team" do
      expect(user.shares_team_with?(non_teammate)).to be(false)
    end

    it "returns false for nil" do
      expect(user.shares_team_with?(nil)).to be(false)
    end
  end

  describe "#mentionable_by?" do
    context "when mention_restriction is anyone" do
      it "allows anyone to mention" do
        expect(user.mentionable_by?(teammate)).to be(true)
        expect(user.mentionable_by?(non_teammate)).to be(true)
      end
    end

    context "when mention_restriction is teammates_only" do
      before { user.update!(mention_restriction: :teammates_only) }

      it "allows teammates to mention" do
        expect(user.mentionable_by?(teammate)).to be(true)
      end

      it "blocks non-teammates from mentioning" do
        expect(user.mentionable_by?(non_teammate)).to be(false)
      end
    end
  end
end
