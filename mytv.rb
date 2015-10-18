require "rubygems"
require "sequel"
require "date"
require 'net/http'
require 'mechanize'
require 'nokogiri'
require 'digest'
require 'json'
require 'logger' # debug, info, warn, error, fatal

require_relative "web"
require_relative "TVShow"
require_relative "Episode"
require_relative "database"
require_relative "import"

module MyTV
	class Cli

		PROMPT = 'MyTV > '

		$logger = Logger.new('test.log', 'daily')
		$logger.level = Logger::DEBUG

		def initialize
			$logger.debug "Connecting to the database"

			if (!File.exist?("MyTV.db")) 
				File.write("MyTV.db", "")
			end

			@DB = Sequel.connect('sqlite://MyTV.db')

			if (@DB.table_exists?(:TVShows) and @DB.table_exists?(:Episodes))
				@myShows = @DB[:TVShows] 
				@episodes = @DB[:Episodes]
			else
				$logger.debug "Creating tables... "
				createTables
				@myShows = @DB[:TVShows] 
				@episodes = @DB[:Episodes]
			end
			$logger.debug "...completed"
		end

		# Creates the TVShows and Episodes tables
		def createTables

			@DB.create_table :TVShows do
	  		Integer :id, :primary_key=>true #TVMAZE ID
	  		String :name
	  	end

	  	@DB.create_table :Episodes do
			  Integer :id, :primary_key=>true #tvmaze id
			  String :title
			  Integer :seasonNumber
			  Integer :episodeNumber
			  Date :airdate
			  Boolean :watched
			  Integer :show_id #FOREIGN KEY REFERENCES TVSHOWS ID
			end

		rescue => e
			$logger.error("Exception in createTables : " + e.message)
			puts "Error: " + e.message
		
		end
		
		def help_text
			puts
			puts "Usage: <command> [<args>]"
			puts
			puts "Commands:"
			puts "  addshow <showname>\t\t\tAdds a show to the database."
			puts "  removeshow <showname>\t\t\tRemoves a show from the database."
			puts "  watch [options] (args) <show>\t\tSets an episode as watched."
			puts "  update\t\t\t\tUpdates the database"
			puts "  nexteps\t\t\t\tShows the @episodes airing soon."
			puts "  help\t\t\t\t\tShows this text."
			puts "  exit\t\t\t\t\tExit the application."
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
				data = "S" + seasonNumber + "E" + episodeNumber + " - " + i[:title] + " - " + i[:airdate].to_s
				puts showname + "\t\t" + data

			end
			
			puts

		end

		def run

			loop do

				PROMPT.display
				begin
					input = gets.chomp
				rescue NoMethodError # Solves NoMethodError when doing Ctrl D without typing anything
					puts
					next
				end
				command, *params = input.split(/\s/)

				case command
				when /\Ahelp\z/i
					help_text
					
				when /\Aaddshow\z/i
					Database.addShow(@myShows, @episodes, params.join(" "))
					puts

				when /\Aremoveshow\z/i
					Database.removeShow(@myShows, @episodes, Database.getShowID(@myShows, params.join(" ")))
					puts

				when /\Aupdate\z/i
					Database.update(@myShows, @episodes)
					puts

				when /\Anexteps\z/i
					printNextEpisodes(@myShows, Database.nextEpisodes(@myShows, @episodes))

				when /\Awatch\z/i
					if params.first == "-s" && params.size >=2 # watch -s Quantico 
						showid = Database.getShowID(@myShows, params.slice(1,params.size).join(" "))
						Database.setShowWatched(@myShows, @episodes, showid)
						puts
						next

					elsif params.first == "-e" && params.size >= 4# watch -e 1 <ep> Quantico
						showname = params.slice(3, params.size).join(" ")

						if !params[2].is_a?(Integer) # Watch several episodes at the same time. watch -e 1 3-5 Quantico
							eps = params[2].split("-")
							range = eps.first .. eps.last
							range.to_a.each do |i|
								epid = Database.getEpisodeID(@myShows, @episodes, params[1], i, showname)
								Database.setWatched(@episodes, epid)
							end
							puts
							next
						else #Watch only one episode. watch -e 1 3 Quantico
							epid = Database.getEpisodeID(@myShows, @episodes, params[1], params [2], showname)
							Database.setWatched(@episodes, epid)
							puts
							next
						end

					end

					puts "Invalid/insufficient arguments."
					help_text

				when /\Aprint\z/i
					(params.first == "-a")?Database.printFull(@myShows, @episodes):Database.printShows(@myShows, @episodes)


				when /\Aimport\z/i # import <filename>
					if params.size == 0
						puts "Insufficient arguments"
						help_text

					elsif params.first != "-e" 
						Import.import(@myShows, @episodes, params.join(" ").to_s)

					else  # External importing import -e
						Import.myEpisodesImport(params[1], params[2])
						Import.import(@myShows, @episodes, "shows.txt")
					end
					puts

				when /\Aexit\z/i, /\Aq\z/i
					break
					
				else
					puts 'Invalid command'
					help_text
				end

			end
		end

	end

end

=begin

BabaNna
TODO:
Change Web Net HTTP to Mechanize (how to json parse)
Find subtitles
Add commands for torrent
Support for importing from files with spaces (my shows.txt)


Bugs:
Adding Breaking In: Invalid date

Exceptions:
class MyError < StandardError
end
raise MyError

nexteps:
(distinction before @episodes that haven't aired yet)
(distinction for shows airing that day?)

Gem structure
Later on
Follow https://github.com/mthssdrbrg/my_episodes/tree/master/lib/my_episodes

=end