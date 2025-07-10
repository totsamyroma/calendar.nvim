require 'icalendar'
require 'net/http'
require 'pry-byebug'

uri = URI(url)

filename = "personal.ics"

File.open(filename, "wb") do |f|
  resp = Net::HTTP.get(uri)

  f.write(resp)
end

file = File.open(filename)

cal = Icalendar::Calendar.parse(file).first

puts 'end'

