require "json"
require "yaml"
require "date"
require "icalendar"

SCHEDULE_FILE = File.join(__dir__, "schedule.json")
MEMBER_FILE = File.join(__dir__, "member.yml")
ICAL_FILE = File.join(__dir__, "schedule.ics")

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
File.write(SCHEDULE_FILE, JSON.pretty_generate(schedules))

cal = Icalendar::Calendar.new
cal.append_custom_property("X-WR-CALNAME;VALUE=TEXT", "CSM Notification checker")
schedules.each do |s|
  cal.event do |e|
    e.dtstart     = Icalendar::Values::Date.new(Date.parse(s["start"]))
    e.dtend       = Icalendar::Values::Date.new(Date.parse(s["end"]) + 1)
    e.summary     = "#{s["assignee"]} 👈 CSM"
  end
end
File.write(ICAL_FILE, cal.to_ical)
