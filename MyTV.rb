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


loop do

	PROMPT.display
	input = gets.chomp

	command, *params = input.split(/\s/)

	case command
	when /\Ahelp\z/i
		help_text
		
	when /\Aaddshow\z/i
		Database.addShow(myShows, episodes, params.join(" "))

	when /\Aremoveshow\z/i
		Database.removeShow(myShows, episodes, Database.getShowID(myShows, params.join(" ")))

	when /\Aupdate\z/i
		Database.update(myShows, episodes)

	when /\Awatch\z/i
		if params.first == "-s" && params.size >=2 # watch -s Quantico 
			showid = Database.getShowID(myShows, params.slice(1,params.size).join(" "))
			Database.setShowWatched(myShows, episodes, showid)
			next
		elsif params.first == "-e" && params.size >= 4# watch -e 1 2 Quantico
			showname = params.slice(3, params.size).join(" ")
			epid = Database.getEpisodeID(myShows, episodes, params[1], params [2], showname)
			puts epid
			Database.setWatched(episodes, epid)
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
Implementation of getShowID and getEpisodeID using web

Exceptios:
Web module throws exceptions when it can't connect. Show message and move on
Catch console interrupts (Ctrl D, Ctrl C)
Trying to remove a show that's not in the database
Trying to set as watched episode/show not in the DB

ALL THE METHODS IN DATABASE MUST HAVE THE SAME STYLE
(DATASET1, DATASET2, PARAM1, PARAM2,...)

# Import from a csv/file

# Method that gives you ID of a show passing its name? Necessary?
# Method that gives you ID of an episode passing season, num and show? Necessary?

#puts Database.getEpisodes(episodes, 2244).to_a #[0]
#puts Database.getEpisodes(episodes, 2244).to_a[0][:airdate]

=end