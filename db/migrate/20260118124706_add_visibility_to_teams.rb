class AddVisibilityToTeams < ActiveRecord::Migration[8.0]
  def change
    create_enum :team_visibility, %w[private visible open]
    add_column :teams, :visibility, :enum, enum_type: :team_visibility, default: "private", null: false
  end
end
