require_relative "../config/environment"
# One-time script to fix the incorrectly stripped message IDs


def extract_message_id(raw_message)
  mail = Mail.new(raw_message)
  mail.message_id
rescue StandardError
  nil
end

def clean_reference_old(ref)
  return '' if ref.nil?

  ref_str = ref.to_s
  if ref_str.include?('<')
    matches = ref_str.scan(/<([^>]+)>/)
    ref_str = matches.last&.first || ref_str
  end

  ref_str.gsub(/[^A-Za-z0-9.@_+%-]/, '')
end

def clean_reference_new(ref)
  return '' if ref.nil?

  ref_str = ref.to_s
  if ref_str.include?('<')
    matches = ref_str.scan(/<([^>]+)>/)
    ref_str = matches.last&.first || ref_str
  end

  ref_str.gsub(/[^A-Za-z0-9.!#$%&'*+\/=?^_`{|}~@-]/, '')
end

def process_message(raw_message)
  message_id = extract_message_id(raw_message)
  return if message_id.nil?

  old_id = clean_reference_old(message_id)
  new_id = clean_reference_new(message_id)
  return if old_id.blank? || new_id.blank?
  return if old_id == new_id

  msg = Message.find_by_message_id(old_id)
  return unless msg

  existing = Message.find_by_message_id(new_id)
  if existing && existing.id != msg.id
    puts "SKIP: #{msg.id} #{old_id} -> #{new_id} (already claimed by #{existing.id})"
    return
  end

  msg.update!(message_id: new_id)
  puts "FIX: #{msg.id} #{old_id} -> #{new_id}"
end

def process_mbox(path)
  message = ""
  File.open(path, "r") do |f|
    f.each_line do |line|
      line = line.force_encoding("ISO-8859-1").encode("utf-8", replace: nil)
      if line.match(/^From [^@]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+/i)
        process_message(message) unless message.empty?
        message = ""
      else
        message << line
      end
    end
  end
  process_message(message) unless message.empty?
end

if ARGV.empty?
  puts "Usage: ruby script/mbox_fix_message_ids.rb <mbox file> [<mbox file> ...]"
  exit 1
end

ARGV.each do |fn|
  puts "Processing #{fn}..."
  process_mbox(fn)
end
