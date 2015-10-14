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
	puts "\taddshow\t\tAdds a show to the database."
	puts "\tupdate\t\tUpdates the database"
	puts "\twatched\t\tSets an episode as watched."
	puts

end

def help(command)
	case command
	when "addshow"
		puts
		puts "NAME"
		puts "\taddshow - Adds a show and all its episodes to the database."
		puts "SYNTAX"
		puts "\taddshow <show name>"
		puts "ARGUMENTS"
		puts "\t<show name> - Name of the show to add."
		puts
	when "watched"
		puts
		puts "Sets an episode as watched."
		puts "Receives as arguments season number, episode number and show name"
		puts
	end
	
end


loop do

	PROMPT.display
	input = gets.chomp

	command, *params = input.split(/\s/)

	case command
	when /\Ahelp\z/i
		if params.size == 0
			help_text
		else
			help(params.first)
		end

	when /\Aaddshow\z/i
		Database.addShow(myShows, episodes, params.join(" "))

	when /\Aupdate\z/i
		Database.update(myShows, episodes)

	when /\Aprint\z/i
		(params.first == "-a")?Database.printFull(myShows, episodes):Database.printShows(myShows, episodes)

	when /\Aexit\z/i
		break
	else
		puts 'Invalid command'
	end

end


=begin

ALL THE METHODS IN DATABASE MUST HAVE THE SAME STYLE
(DATASET1, DATASET2, PARAM1, PARAM2,...)

Marking an episode as watched twice doesn't log properly, takes too long

# Method getShowID (showName)
myShows.where(:name => "The Blacklist").to_a[0][:id]
if it doesnt find anything -> try Web.searchShowFast //FASTER?

# Import from a csv/file

# Method that gives you ID of a show passing its name? Necessary?
# Method that gives you ID of an episode passing season, num and show? Necessary?

#puts Database.getEpisodes(episodes, 2244).to_a #[0]
#puts Database.getEpisodes(episodes, 2244).to_a[0][:airdate]

=end