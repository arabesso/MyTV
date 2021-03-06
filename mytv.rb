require 'rubygems'
require 'sequel'
require 'date'
require 'mechanize'
require 'nokogiri'
require 'json'
require 'logger' # debug, info, warn, error, fatal

require_relative 'Web'
require_relative 'TVShow'
require_relative 'Episode'
require_relative 'Database'
require_relative 'Import'

module MyTV

	class Cli

		PROMPT = "MyTV > "

		$logger = Logger.new("test.log", "daily")
		$logger.level = Logger::WARN
		attr_reader :DB
		attr_reader :episodes
		attr_reader :my_shows


		def initialize
			$logger.debug "Connecting to the database"

			if (!File.exist?("mytv.db"))
				File.write("mytv.db", "")
			end

			@DB = Sequel.connect("sqlite://mytv.db")
			@DB.synchronous = :off
			@DB.temp_store = :memory

			if (@DB.table_exists?(:TVShows) and @DB.table_exists?(:Episodes))
				@my_shows = @DB[:TVShows] 
				@episodes = @DB[:Episodes]
			else
				$logger.debug "Creating tables... "
				create_tables
				@my_shows = @DB[:TVShows] 
				@episodes = @DB[:Episodes]
			end
			$logger.debug "...completed"
		end

		# Creates the TVShows and Episodes tables
		def create_tables
			
			@DB.create_table :TVShows do
	  		Integer :show_id, :primary_key=>true #TVMAZE ID
	  		String :name
	  	end

	  	@DB.create_table :Episodes do
			  Integer :ep_id, :primary_key=>true #tvmaze id
			  String :title
			  Integer :season_number
			  Integer :episode_number
			  Date :airdate
			  Boolean :watched
			  foreign_key :show_id, :TVShows ,:on_delete=>:cascade #FOREIGN KEY REFERENCES TVSHOWS ID
			  #Integer :show_id
			end

		rescue => e
			$logger.error("Exception in create_tables : " + e.message + " [" + e.class.to_s + "]")
			puts "Error: " + e.message + " [" + e.class.to_s + "]"
		
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

		def print_next_episodes(dataset1, next_episodes)
			next_episodes = next_episodes.sort_by { |hsh| hsh[:airdate] }

			next_episodes.each do |i|
				if i[:season_number]<10
					season_number = "0" + i[:season_number].to_s
				end
				if i[:episode_number]<10
					episode_number = "0" + i[:episode_number].to_s
				end
				
				showname = dataset1.where(:show_id => i[:show_id]).to_a[0][:name]
				if i[:airdate] == Date.today
					data = "(!) S" + season_number + "E" + episode_number + " - " + i[:title] + " - " + i[:airdate].to_s
				elsif i[:airdate] > Date.today
					data = "... S" + season_number + "E" + episode_number + " - " + i[:title] + " - " + i[:airdate].to_s
				else
					data = "S" + season_number + "E" + episode_number + " - " + i[:title] + " - " + i[:airdate].to_s
				end
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
					@DB.transaction do
						Database.add_show(@my_shows, @episodes, params.join(" "))
					end
					puts

				when /\Aremoveshow\z/i
					Database.remove_show(@my_shows, @episodes, Database.get_show_id(@my_shows, params.join(" ")))
					puts

				when /\Aupdate\z/i
					Database.update(@my_shows, @episodes)
					puts

				when /\Anexteps\z/i
					print_next_episodes(@my_shows, Database.next_episodes(@my_shows, @episodes))

				when /\Awatch\z/i
					if params.first == "-s" && params.size >=2 # watch -s Quantico 
						showid = Database.get_show_id(@my_shows, params.slice(1,params.size).join(" "))
						@DB.transaction do
							Database.set_show_watched(@my_shows, @episodes, showid)
						end
						puts
						next

					elsif params.first == "-e" && params.size >= 4# watch -e 1 <ep> Quantico
						showname = params.slice(3, params.size).join(" ")
						

						if params[2].include?"-" # Watch several episodes at the same time. watch -e 1 3-5 Quantico
							eps = params[2].split("-")
							range = eps.first .. eps.last
							@DB.transaction do
								range.each do |ep_number|
									epid = Database.get_episode_id(@my_shows, @episodes, params[1], ep_number, showname)
									Database.set_watched(@episodes, epid) unless epid.nil?
								end
							end
							puts
							next

						else #Watch only one episode. watch -e 1 3 Quantico

							epid = Database.get_episode_id(@my_shows, @episodes, params[1], params [2], showname)
							Database.set_watched(@episodes, epid) unless epid.nil?
							puts
							next
						end

					end

					puts "Invalid/insufficient arguments."
					help_text

				when /\Aprint\z/i
					(params.first == "-a")?Database.print_full(@my_shows, @episodes):Database.print_shows(@my_shows, @episodes)

				when /\Adownload\z/i # download 1 2 Quantico
					showname = params.slice(2, params.size).join(" ")
					magnet = Web.get_magnet_link(params[0], params[1], showname).to_s
					exec = "deluge-gtk \"" + magnet + "\" &> /dev/null"
					Process.detach(Process.spawn(exec))
					sleep(1) # Formatting
					puts

				when /\Aimport\z/i # import <filename>
					if params.size == 0
						puts "Insufficient arguments"
						help_text

					elsif params.first != "-e" 
						@DB.transaction do
							Import.import(@my_shows, @episodes, params.join(" ").to_s)
						end

					else  # External importing import -e
						Import.myepisodes_import(params[1], params[2])
						@DB.transaction do
							Import.import(@my_shows, @episodes, "shows.txt")
						end
					end
					puts

				when /\Aclear\z/i
					Database.clear(@my_shows, @episodes)
					puts

				when /\Aexit\z/i, /\Aq\z/i
					break
					
				else
					puts "Invalid command"
					help_text
				end

			end
		end

	end
end