require 'nokogiri'
require 'pp'
require 'cgi'

headers = "-H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: en-US,en;q=0.8' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.113 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' -H 'Cache-Control: max-age=0' -H 'Referer: http://timetable.ncirl.ie/SWS/1718/default.aspx' -H 'Connection: keep-alive' -H 'DNT: 1'"

login = `curl -v 'http://timetable.ncirl.ie/SWS/1718/login.aspx' #{headers} --cookie cookies.txt --cookie-jar cookies.txt `
# puts login


contents = `curl 'http://timetable.ncirl.ie/SWS/1718/default.aspx' #{headers} --cookie cookies.txt --cookie-jar cookies.txt`
# puts contents

doc = Nokogiri::HTML(contents)

rows = doc.xpath('//*[@id="__EVENTVALIDATION"]/@value')
event_validation = rows[0].to_s
puts "SOMETHING"
puts event_validation

rows = doc.xpath('//*[@id="__VIEWSTATE"]/@value')
view_state = rows[0].to_s
puts view_state

data = "--data '__EVENTTARGET=&__EVENTARGUMENT=&__LASTFOCUS=&__VIEWSTATE=#{view_state}&__EVENTVALIDATION=#{event_validation}&tLinkType=studentSet&dlFilter2=&tWildcard=BSHC&dlObject=%23SPLUS9DDCBE&lbWeeks=1%3B2%3B3%3B4%3B5%3B6%3B7%3B8%3B9%3B10%3B11%3B12%3B13%3B14%3B15%3B16%3B17%3B18&lbDays=1-5&dlPeriod=5-20&RadioType=individual%3Bswsurlssg%3Bgrid&bGetTimetable=View+Timetable'"

puts "-------------default"
contents = `curl -v -X POST 'http://timetable.ncirl.ie/SWS/1718/default.aspx' #{headers} --cookie cookies.txt --cookie-jar cookies.txt  #{data} --compressed`
# puts contents

doc = Nokogiri::HTML(contents)

# rows = doc.xpath('//*[@id="__EVENTVALIDATION"]/@value')
# event_validation = rows[0].to_s
# puts event_validation
# rows = doc.xpath('//*[@id="__VIEWSTATE"]/@value')
# view_state = rows[0].to_s
# puts view_state

data = "--data '__EVENTTARGET=&__EVENTARGUMENT=&__LASTFOCUS=&__VIEWSTATE=#{view_state}&__EVENTVALIDATION=#{event_validation}&tLinkType=studentSet&dlFilter2=&tWildcard=BSHC&dlObject=%23SPLUS9DDCBE&lbWeeks=1%3B2%3B3%3B4%3B5%3B6%3B7%3B8%3B9%3B10%3B11%3B12%3B13%3B14%3B15%3B16%3B17%3B18&lbDays=1-5&dlPeriod=5-20&RadioType=individual%3Bswsurlssg%3Bgrid&bGetTimetable=View+Timetable'"


file = `curl -v 'http://timetable.ncirl.ie/SWS/1718/showtimetable.aspx' --cookie cookies.txt --cookie-jar cookies.txt`

puts "-------------timetable"
puts file