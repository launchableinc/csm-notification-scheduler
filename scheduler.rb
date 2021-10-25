require "json"
require "yaml"
require "date"

SCHEDULE_FILE = File.join(__dir__, "schedule.json")
MEMBER_FILE = File.join(__dir__, "member.yml")

schedules = JSON.load(File.open(SCHEDULE_FILE))
members = YAML.load_file(MEMBER_FILE)

this_cutoverday = Date.parse(schedules.first["end"]) + 1
next_cutoverday = this_cutoverday + 6

this_assignee = schedules.first["assignee"]
next_assignee = members[(members.index(this_assignee) + 1) % members.size]

schedules.unshift(
  "start" => this_cutoverday.iso8601,
  "end" => next_cutoverday.iso8601,
  "assignee" => next_assignee
)
File.write(SCHEDULE_FILE ,JSON.pretty_generate(schedules))
today = Date.today
current_index = schedules.index {|schedule| (Date.parse(schedule["start"])..Date.parse(schedule["end"])).cover? today }
p current_index
