class AddMentionRestrictionToUsers < ActiveRecord::Migration[8.0]
  def change
    create_enum :user_mention_restriction, %w[anyone teammates_only]
    add_column :users, :mention_restriction, :enum, enum_type: :user_mention_restriction, default: "anyone", null: false
  end
end
