#!/usr/bin/env ruby
# frozen_string_literal: true

# Fix incorrect TopicParticipant records.
#
# This script finds TopicParticipant records where the person has no messages
# in that topic (orphaned records created by a bug in PersonIdPropagationJob),
# and rebuilds the correct participant data from actual messages.
#
# Usage:
#   ruby script/fix_topic_participants.rb           # dry run, report only
#   ruby script/fix_topic_participants.rb --fix     # actually fix the records

require_relative '../config/environment'

dry_run = !ARGV.include?('--fix')

puts "Finding topics with incorrect TopicParticipant records..."
puts "(dry run - use --fix to apply changes)" if dry_run
puts

# Find TopicParticipant records where the person has no messages in that topic
orphaned_participants = TopicParticipant.where(<<~SQL)
  NOT EXISTS (
    SELECT 1 FROM messages
    WHERE messages.topic_id = topic_participants.topic_id
      AND messages.sender_person_id = topic_participants.person_id
  )
SQL

affected_topic_ids = orphaned_participants.distinct.pluck(:topic_id)

if affected_topic_ids.empty?
  puts "No incorrect TopicParticipant records found."
  exit 0
end

puts "Found #{orphaned_participants.count} orphaned TopicParticipant records across #{affected_topic_ids.size} topics."
puts

# Show details of affected topics
affected_topic_ids.each do |topic_id|
  topic = Topic.find(topic_id)
  orphaned = orphaned_participants.where(topic_id: topic_id).includes(:person)

  puts "Topic ##{topic_id}: #{topic.title.truncate(60)}"
  orphaned.each do |tp|
    person_name = tp.person&.display_name || "Person ##{tp.person_id}"
    puts "  - #{person_name} (#{tp.message_count} messages recorded, 0 actual)"
  end
end

puts

if dry_run
  puts "Run with --fix to rebuild these #{affected_topic_ids.size} topics."
else
  puts "Rebuilding #{affected_topic_ids.size} topics..."

  affected_topic_ids.each_with_index do |topic_id, index|
    topic = Topic.find(topic_id)
    topic.recalculate_participants!
    puts "  [#{index + 1}/#{affected_topic_ids.size}] Fixed topic ##{topic_id}"
  end

  puts
  puts "Done. Rebuilt #{affected_topic_ids.size} topics."
end
