module MyTV
	class Database

		# Add a new show and its episodes. Receives a string and the dataset my_shows and episodes as parameters
		def Database.add_show(shows, dataset2, show_name, verbose=true)
			# Finding the show
			obj = Web.search_show(show_name)
			$logger.debug "Trying to add show <#{obj['name']}>"

			# Checks it's not in the database already
			if shows.where(:show_id => obj['id']).count == 1
				$logger.warn "The show <#{obj['name']}> is already in the database"
				puts "The show #{obj['name']} is already in the database" unless !verbose
			else
				newshow = TVShow.new(obj['name'], obj['id'])
				shows.insert(:show_id => newshow.id, :name => newshow.name)
				Database.add_episodes(dataset2, newshow)
				puts "Added show #{show_name}" unless !verbose
				$logger.debug "...completed"
			end

		rescue => e
			$logger.error("Exception in add_show trying to add <#{show_name}> : #{e.message} [#{e.class.to_s}]")
			puts "Error: #{e.message} [#{e.class.to_s}]" unless !verbose
		end

		# Add episodes to the database. Receives a TVShow and the dataset episodes as parameters
		# PRIVATE?
		# SLOW METHOD?
		# 
		def Database.add_episodes (dataset, show)
			id = show.id
			show.episodes.each do |i|

				if dataset.where(:ep_id => i.id).count == 1
					$logger.warn "The episode <#{i.title}> is already in the database"
				else
					dataset.insert(:ep_id => i.id, :title => i.title, :season_number => i.season, :episode_number => i.number, :airdate => i.airdate, :watched => false, :show_id => id)
					$logger.debug "Added episode <#{i.title}>"
				end

			end

		rescue => e
			$logger.error("Exception in add_episodes : #{e.message} [#{e.class.to_s}]")
			puts "Error: #{e.message} [#{e.class.to_s}]"
		end

		# Add only the new episodes to the database. Receives a TVShow and the dataset episodes as parameters
		# PRIVATE=
		# SLOW METHOD?
		def Database.add_new_episodes (dataset, show, last_episode_s, last_episode_n)
			id = show.id
			episodes = show.episodes

			if episodes.empty?
				return
			end
			
			# Quick check if there are new episodes
			if episodes[-1].season > last_episode_s
			elsif last_episode_s == episodes[-1].season && episodes[-1].number > last_episode_n
			else
				$logger.info "No new episodes to add to <#{show.name}>"
				return
			end
			
			# New episodes to add, full iteration:
			episodes.each do |i|
				if i.season > last_episode_s
					dataset.insert(:ep_id => i.id, :title => i.title, :season_number => i.season, :episode_number => i.number, :airdate => i.airdate, :watched => false, :show_id => id)
					$logger.debug "Added episode <#{i.title}>"
				elsif last_episode_s == i.season && i.number > last_episode_n
					dataset.insert(:ep_id => i.id, :title => i.title, :season_number => i.season, :episode_number => i.number, :airdate => i.airdate, :watched => false, :show_id => id)
					$logger.debug "Added episode <#{i.title}>"
				end
			end

		rescue => e
			puts "Error: #{e.message} [#{e.class.to_s}]"
			$logger.error("Exception in add_new_episodes trying to add episodes for <#{show.name}> : #{e.message} [#{e.class.to_s}]")
		end

		# Removes an episodes from the database.
		# PRIVATE?
		def Database.remove_episode (dataset, id)
			if dataset.where(:ep_id => id).count == 1
				dataset.where(:ep_id => id).delete
				$logger.debug "Deleting episode with id <#{id.to_s}> from dataset "
			else
				$logger.warn "Couldn't delete episode with id <#{id.to_s}>. Entry not found."
			end
		
		rescue => e
			puts "Error: #{e.message} [#{e.class.to_s}]"
			$logger.error("Exception in remove_episode trying to remove item <#{id.to_s}> : #{e.message} [#{e.class.to_s}]")
		
		end

		# Removes a TVShow and all its episodes
		# SLOW METHOD 
		def Database.remove_show(shows, dataset2, show_id)
			if shows.where(:show_id => show_id).count == 1
				shows.where(:show_id => show_id).delete
				$logger.debug "Deleting show with id <#{show_id.to_s}> from dataset "
			else
				$logger.warn "Couldn't delete show with id <#{show_id.to_s}>. Entry not found."
			end
			# Remove episodes of that show
			#dataset2.where(:show_id => show_id).each do |i|
			#	Database.remove_episode(dataset2, i[:ep_id])
			#end
			
		rescue => e
			$logger.error("Exception in remove_show trying to remove show <#{show_id}> : #{e.message} [#{e.class.to_s}]")
			puts "Error: #{e.message} [#{e.class.to_s}]"
		
		end

		# Performs all the updates to the DB
		# SLOW METHOD?
		def Database.update(shows, dataset2)
			# scan database for watched=true
			# once found one, check if the count of episodes where show_id is the same as the watched is higher than 1
			# if it is higher, delete watched=true episode
			dataset2.where(:watched => true).each do |i|
				if dataset2.where(:show_id => i[:show_id]).count > 1
					Database.remove_episode(dataset2, i[:ep_id])
				else
					$logger.info "The episode id <#{i[:ep_id].to_s}> wasn't deleted because it's the last one."
				end
			end

			# Storing the "update" and only calling add_episodes when the update field changes would make this much faster
			# Adds the new episodes of every tvshow checking the last season and episode numbers stored in the DB
			shows.each do |i|
				show = TVShow.new(i[:name], i[:show_id])
				last_episode = dataset2.where(:show_id => i[:show_id]).order(:season_number, :episode_number).last
				if (last_episode)
					lasteps = last_episode[:season_number]
					lastepn = last_episode[:episode_number]
				else # Show without episodes stored
					lasteps = 0
					lastepn = 0
				end
				Database.add_new_episodes(dataset2, show, lasteps, lastepn)
			end
			
		rescue => e
			$logger.error("Exception in update : #{e.message} [#{e.class.to_s}]")
			puts "Error: #{e.message} [#{e.class.to_s}]"
		
		end

		# Returns the ID of a show stored in the database. Receives a string with the show name
		# Mechanize::ResponseCodeError if show isn't found
		def Database.get_show_id(dataset, showname)
			show = dataset.where(:name => showname).to_a[0]
			if show # Found in the database
				show[:show_id]	
			else # Search online
				$logger.warn("Show wasn't found in the database. Searching online.")
				Web.get_show_id(showname)
			end

		rescue => e
			$logger.error("Exception in get_show_id trying to get the id for <#{showname}> : #{e.message} [#{e.class.to_s}]")
			puts "Error: #{e.message} [#{e.class.to_s}]"
		
		end

		# NoMethodError when the episode id isn't found
		def Database.get_episode_id(shows, dataset2, season, episode, show)
			show_id = Database.get_show_id(shows, show)
			dataset2.where(:show_id => show_id, :season_number => season, :episode_number => episode).to_a[0][:ep_id]

		rescue => e
			$logger.error("Exception in get_episode_id trying to get <#{show}>'s S#{season}E#{episode} id : #{e.message} [#{e.class.to_s}]")
			puts "Error: #{e.message} [#{e.class.to_s}]"
		
		end


		def Database.set_watched(dataset, episodeid)
			dataset.where(:ep_id => episodeid).update(:watched => true)
		
		rescue => e
			$logger.error("Exception in set_watched trying to set episode <#{episodeid}> as watched : #{e.message} [#{e.class.to_s}]")
			puts "Error: #{e.message} [#{e.class.to_s}]"
			
		end

		# Returns a TVShow object. Receives the my_shows dataset and the show id
		def Database.get_show (shows, id)
			tvshowdata = shows.where(:show_id => id).to_a
			TVShow.new(tvshowdata[0][:name], tvshowdata[0][:show_id])

		rescue => e
			$logger.error("Exception in get_show trying to get id <#{id}> : #{e.message} [#{e.class.to_s}]")
			puts "Error: #{e.message} [#{e.class.to_s}]"
		
		end

		# Returns the episodes of a specific show id. Receives the episodes dataset and a show_id as parameters
		def Database.get_episodes(dataset, show_id)
			dataset.where(:show_id => show_id)
			
		rescue => e
			$logger.error("Exception in get_episodes trying to get episodes for show <#{show_id}> : #{e.message} [#{e.class.to_s}]")
			puts "Error: #{e.message} [#{e.class.to_s}]"
		
		end

		# Returns the current number of entries in the given dataset
		def Database.number_of_entries (dataset)
			dataset.count

		rescue => e
			$logger.error("Exception in number_of_entries : #{e.message} [#{e.class.to_s}]")
			puts "Error: #{e.message} [#{e.class.to_s}]"
		
		end

		# Sets all the episodes of a tv show as watched
		# SLOW METHOD?
		def Database.set_show_watched(shows, dataset2, show_id)

			dataset2.where(:show_id => show_id).to_a.each do |i|
				Database.set_watched(dataset2, i[:ep_id])
			end

		rescue => e
			$logger.error("Exception in set_show_watched with show <#{show_id}> : #{e.message} [#{e.class.to_s}]")
			puts "Error: #{e.message} [#{e.class.to_s}]"
		
		end

		# Returns an array of non-watched episodes, one per show.
		def Database.next_episodes(shows, dataset2)
			next_episodes = Array.new
			shows.each do |i|
				episode = dataset2.where(:show_id => i[:show_id], :watched => false).order(:airdate).to_a[0]
				if episode != nil
					next_episodes <<  episode
				end
			end

		return next_episodes

		rescue => e
			$logger.error("Exception in next_episodes : #{e.message} [#{e.class.to_s}]")
			puts "Error: #{e.message} [#{e.class.to_s}]"
		
		end

		def Database.contains(show, show_id)
			shows.where(:show_id => show_id).count == 1


		rescue => e
			$logger.error("Exception in contains : #{e.message} [#{e.class.to_s}]")
			puts "Error: #{e.message} [#{e.class.to_s}]"
		
		end

		def Database.clear(shows, dataset2)
			shows.delete
			dataset2.delete
			
		rescue => e
			$logger.error("Exception in clear : #{e.message} [#{e.class.to_s}]")
			puts "Error: #{e.message} [#{e.class.to_s}]"

			
		end

		# Prints general information about the shows in the DB. Receives my_shows and episodes as parameters
		# SLOW METHOD?
		def Database.print_shows(shows, dataset2)
			shows.order(:name).each do |i|
				puts "TV Show <#{i[:name]}> (id #{i[:show_id].to_s}) - #{dataset2.where(:show_id => i[:show_id]).count.to_s} episodes stored"
			end
			puts
		end

		# Prints information about every show and episode stored in a readable format. Receives my_shows and episodes as parameters
		def Database.print_full(shows, dataset2)
			shows.order(:name).each do |show|
				puts "TV Show <#{show[:name]}> (id #{show[:show_id].to_s})"
				dataset2.where(:show_id => show[:show_id]).each do |ep|
					season_number =  ep[:season_number]<10 ? "0" + ep[:season_number].to_s : ep[:season_number].to_s
					episode_number = ep[:episode_number]<10 ? "0" + ep[:episode_number].to_s : ep[:episode_number].to_s
					watch = ep[:watched]? "watched" : "not watched"
					puts "\tS#{season_number}E#{episode_number} - #{ep[:title].to_s} - #{watch}"
				end
			end
			puts

		end

	end
end