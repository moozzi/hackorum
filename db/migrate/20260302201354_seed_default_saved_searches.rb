class SeedDefaultSavedSearches < ActiveRecord::Migration[8.0]
  def up
    # Global searches (visible to everyone)
    create_search("No contributor/committer replies", "-from:contributor", scope: "global", position: 0)
    create_search("Patch, no replies", "has:patch messages:1", scope: "global", position: 1)

    # User templates (scope=user, user_id=nil — system defaults for logged-in users)
    create_search("Reading in progress", "reading:me", scope: "user", position: 0)
    create_search("New for me", "new:me OR reading:me", scope: "user", position: 1)
    create_search("Started by me", "starter:me", scope: "user", position: 2)
    create_search("I posted here", "from:me", scope: "user", position: 3)
    create_search("Starred by me", "starred:me", scope: "user", position: 4)

    # Team templates (scope=team, team_id=nil — system defaults per team)
    create_search("Starred by team", "starred:{{team_name}}", scope: "team", position: 0)
    create_search("Not yet read by team", "new:{{team_name}}", scope: "team", position: 1)
    create_search("Team reading", "read:{{team_name}} OR reading:{{team_name}}", scope: "team", position: 2)
    create_search("Started by team", "starter:{{team_name}}", scope: "team", position: 3)
    create_search("Team messages", "from:{{team_name}}", scope: "team", position: 4)
  end

  def down
    SavedSearch.where(name: [
      "No contributor/committer replies", "Patch, no replies",
      "Reading in progress", "New for me", "Started by me", "I posted here", "Starred by me",
      "Starred by team", "Not yet read by team", "Team reading", "Started by team", "Team messages"
    ]).where(user_id: nil, team_id: nil).destroy_all
  end

  private

  def create_search(name, query, scope:, position:)
    SavedSearch.find_or_create_by!(name: name, scope: scope, user_id: nil, team_id: nil) do |s|
      s.query = query
      s.position = position
    end
  end
end
