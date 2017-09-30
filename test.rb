require 'nokogiri'
require 'pp'
require 'cgi'

class TeachingSession
	
	attr_accessor :module_name, :type, :team, :location, :weeks, :start_time, :end_time, :programme, :day, :programmes
	
	def initialize(module_name, type, team, location, weeks, time, programme, duration, day)
		@module_name = module_name
		@type = type
		@team = team.split(",").sort
		@location = location
		@weeks = weeks
		@start_time = time
    @end_time =  "#{time.to_i + (duration / 2)}:00"
    @programme = programme
	  @programmes = [programme]
    @day = day
    filter
	end
  
  def day 
    days=Hash["Mon", 1, "Tue", 2, "Wed", 3, "Thu", 4, "Fri", 5, "Sat", 6]
    return "#{days[@day]} #{@day}"
  end
  
  def filter
    assistants = team.select { |member| member.match(/^(LA|TA)/)}
    @team = @team - assistants
  end
  
  def hash
    2
  end
  
  def add_programme(other)
    @programmes << other
  end
  
  def eql?(other)
    if (start_time == other.start_time) and (team == other.team) and (weeks == other.weeks) and (location == other.location)
		  other.add_programme(programme)
		  return true
	end
    return false
  end
  
	def to_s
		return "Module = #{@module_name}, type = #{@type}, time = #{day} #{start_time}-#{end_time}, team #{@team.inspect}"
	end
	
end

def get_file_as_string(filename)
  data = ''
  f = File.open(filename, "r") 
  f.each_line do |line|
    data += line
  end
  return data
end

sessions = []
programmes = []
progcounter = 0

doc = Nokogiri::HTML(get_file_as_string("timetable-full.html"))

doc.search("//span[contains(@class, 'header-0-0-1')]").each do |cell|
  programmes << cell.content
end


doc.search('/html/body/table[contains(@class, "grid-border-args")]').each do |cell|

  times = cell.search('tbody/tr[1]')[0]
      
  row = cell.search('tbody/tr')
  day = "Mon"

  row.each { |ce| 
    c = 3
    var = ce.search('td')
    
    if var[0].attributes["class"] != nil and var[0].attributes["class"].value =~ /row-label-one/
      day = var[0].content
    end
        
     var.each { |session|
           
      if session.attributes["class"] != nil and session.attributes["class"].value =~ /Lab|Lec|Book|object-cell-border/
              
        duration = session.attributes['colspan'].content.to_i
        time = times.search("td[#{c}]")[0].content
      
        inners = session.search('table/tbody/tr/td')
		    modul = inners[0].content
		    type = inners[1].content
		    team =  inners[2].content
		    loc = inners[3].content
		    weeks = inners[4].content
        		  
		    programme = programmes[progcounter]

		    sessions << TeachingSession.new(modul,type,team,loc, weeks, time, programme, duration, day)
        
        c+= session.attributes['colspan'].value.to_i
      
      elsif  session.attributes["class"] != nil and session.attributes["class"].value =~ /row-label-one/
        day = session.content
      elsif session.attributes["class"] != nil and session.attributes["class"].value =~ /cell-border/
        c+=1
      end
    }
  }
  
  progcounter +=1
end

sessions = sessions.uniq
require "csv"

CSV.open("test.csv", "wb") do |csv|
  csv << %w(Module Type team1 team1 team1 team1 Location Weeks Day Start End Programme)
  sessions.each { |session| 
    arr = [session.module_name, session.type]
    4.times { |i| arr << session.team[i] }
    arr += [session.location, session.weeks, session.day, session.start_time, session.end_time, session.programmes.inspect]
    csv << arr
  }
end
