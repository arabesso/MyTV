require "rubygems"
require "sequel"
require "date"
require 'net/http'
require 'digest'
require 'json'
require 'logger' # debug, info, warn, error, fatal

require_relative 'web'
require_relative 'TVShow'
require_relative 'Episode'
require_relative 'database'

PROMPT = 'MyTV > '

$logger = Logger.new('test.log', 'daily')
$logger.level = Logger::DEBUG

# Initialising the DB connection,
$logger.debug "Connecting to the database"
DB = Sequel.connect('sqlite://MyTV.db')
if (DB.table_exists?(:TVShows) and DB.table_exists?(:Episodes))
	myShows = DB[:TVShows] 
	episodes = DB[:Episodes]
else
	$logger.debug "Creating tables... "
	Database.createTables
	myShows = DB[:TVShows] 
	episodes = DB[:Episodes]
end
$logger.debug "...completed"

def help_text
	puts
	puts "Usage: <command> [<args>]"
	puts "Common commands:"
	puts "\taddshow <showname>\t\tAdds a show to the database."
	puts "\tremoveshow <showname>\t\tRemoves a show from the database."
	puts "\tupdate\t\tUpdates the database"
	puts "\twatched\t\tSets an episode as watched."
	puts

end

def printNextEpisodes(dataset1, nextEpisodes)
	nextEpisodes.sort_by { |hsh| hsh[:airdate] }

	nextEpisodes.each do |i|
		if i[:seasonNumber]<10
			seasonNumber = "0" + i[:seasonNumber].to_s
		end
		if i[:episodeNumber]<10
			episodeNumber = "0" + i[:episodeNumber].to_s
		end
		
		showname = dataset1.where(:id => i[:show_id]).to_a[0][:name]

		puts showname + "\tS" + seasonNumber + "E" + episodeNumber + " - " + i[:title] + " - " + i[:airdate].to_s

	end
	
	puts

end

#main

loop do

	PROMPT.display
	input = gets.chomp

	command, *params = input.split(/\s/)

	case command
	when /\Ahelp\z/i
		help_text
		
	when /\Aaddshow\z/i
		Database.addShow(myShows, episodes, params.join(" "))
		puts

	when /\Aremoveshow\z/i
		Database.removeShow(myShows, episodes, Database.getShowID(myShows, params.join(" ")))
		puts

	when /\Aupdate\z/i
		Database.update(myShows, episodes)
		puts

	when /\Anextepisodes\z/i
		printNextEpisodes(myShows, Database.nextEpisodes(myShows, episodes))

	when /\Awatch\z/i
		if params.first == "-s" && params.size >=2 # watch -s Quantico 
			showid = Database.getShowID(myShows, params.slice(1,params.size).join(" "))
			Database.setShowWatched(myShows, episodes, showid)
			puts
			next
		elsif params.first == "-e" && params.size >= 4# watch -e 1 2 Quantico
			showname = params.slice(3, params.size).join(" ")
			epid = Database.getEpisodeID(myShows, episodes, params[1], params [2], showname)
			puts epid
			Database.setWatched(episodes, epid)
			puts
			next
		end

		puts "Invalid/insufficient arguments."
		help_text

	when /\Aprint\z/i
		(params.first == "-a")?Database.printFull(myShows, episodes):Database.printShows(myShows, episodes)

	when /\Aexit\z/i
		break
		
	else
		puts 'Invalid command'
		help_text
	end

end


=begin

TODO:
Readline support
Import shows from a file
Add exceptions raising and handling (logger error level)
Show feedback to the user ("Completed, etc")
Better logging
Gem structure
Do I need TVShow.rb and Episode.rb? I can simulate the classes
(Find torrent link and subtitles)
#!/usr/bin/env ruby

Exceptios:
Web module throws exceptions when it can't connect. Show message and move on
Catch console interrupts (Ctrl D, Ctrl C)
Ctrl c --> Interrupt
Ctrl D --> NoMethodError if prompt is empty. Screws up formatting if using a command 
Trying to remove a show that's not in the database
Trying to set as watched episode/show not in the DB

Good practices
* Change and for &&
* Remove parenthesis from if
* Add spaces in blocks like
array.each { |i| do ... end }


# returns an array of Episodes, one per show
Database.netEpisodes(dataset1, dataset2)
get next non watched episode from each show
ordering those by airdate
returning that array
method in MyTV.rb that receives that array and prints it properly
(distinction before episodes that haven't aired yet)
(distinction for shows airing that day?)

=end