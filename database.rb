module Database

	# DATABASE_NAME = "MyTV.db"
	# DB = Sequel.connect('sqlite://MyTV.db')

	# Add a new show and its episodes. Receives a string and the dataset myShows and episodes as parameters
	def Database.addShow(dataset1, dataset2, showName)
		# Finding the show
		obj = Web.searchShowFast(showName)
		$logger.info "Trying to add show <" + obj['name'] + ">"

		# Checks it's not in the database already
		if dataset1.where(:id => obj['id']).count == 1
			$logger.warn "The show <" + obj['name'] + "> is already in the database"
		else
			newshow = TVShow.new(obj['name'], obj['id'])
			dataset1.insert(:id => newshow.getID, :name => newshow.getName)
			Database.addEpisodes(dataset2, newshow)
			$logger.info "...completed"
		end

	rescue => e
		$logger.error("Exception in addShow trying to add <" + showName + "> : " + e.message)
		puts "Error."
	end

	# Add episodes to the database. Receives a TVShow and the dataset episodes as parameters
	# PRIVATE?
	# SLOW METHOD?
	# 
	def Database.addEpisodes (dataset, show)
		id = show.getID
		show.getEpisodes().each do |i|

			if dataset.where(:id => i.getID).count == 1
				$logger.warn "The episode <" + i.getTitle + "> is already in the database"
			else
				dataset.insert(:id => i.getID, :title => i.getTitle, :seasonNumber => i.getSeason, :episodeNumber => i.getNumber, :airdate => i.getAirdate, :watched => false, :show_id => id)
				$logger.info "Added episode <" + i.getTitle + ">"
			end

		end

	rescue => e
		$logger.error("Exception in addEpisodes : " + e.message)
		puts "Error."
	end

	# Add only the new episodes to the database. Receives a TVShow and the dataset episodes as parameters
	# PRIVATE=
	# SLOW METHOD?
	def Database.addNewEpisodes (dataset, show, lastEpisodeS, lastEpisodeN)
		id = show.getID
		episodes = show.getEpisodes

		# Quick check if there are new episodes
		if episodes[-1].getSeason > lastEpisodeS
		elsif lastEpisodeS == episodes[-1].getSeason && episodes[-1].getNumber > lastEpisodeN
		else
			$logger.info "No new episodes to add to <" + show.getName + ">"
			return
		end
		

		# New episodes to add, full iteration:
		episodes.each do |i|
			if i.getSeason > lastEpisodeS
				dataset.insert(:id => i.getID, :title => i.getTitle, :seasonNumber => i.getSeason, :episodeNumber => i.getNumber, :airdate => i.getAirdate, :watched => false, :show_id => id)
				$logger.info "Added episode <" + i.getTitle + ">"
			elsif lastEpisodeS == i.getSeason && i.getNumber > lastEpisodeN
				dataset.insert(:id => i.getID, :title => i.getTitle, :seasonNumber => i.getSeason, :episodeNumber => i.getNumber, :airdate => i.getAirdate, :watched => false, :show_id => id)
				$logger.info "Added episode <" + i.getTitle + ">"
			end
		end

	rescue => e
		puts "Error"
		$logger.error("Exception in addNewEpisodes trying to add episodes for <" + show.getName + "> : " + e.message)
	end

	# Removes an episodes from the database.
	# PRIVATE?
	def Database.removeEntry (dataset, id)
		if dataset.where(:id => id).count == 1
			dataset.where(:id => id).delete
			$logger.info "Deleting entry with id <" + id.to_s + "> from dataset "
		else
			$logger.warn "Couldn't delete entry with id <" + id.to_s + ">. Entry not found."
		end
	
	rescue => e
		puts "Error"
		$logger.error("Exception in removeEntry trying to remove item <" + id + "> : " + e.message)
	
	end

	# Performs all the updates to the DB
	# SLOW METHOD?
	def Database.update(dataset1, dataset2)
		# scan database for watched=true
		# once found one, check if the count of episodes where show_id is the same as the watched is higher than 1
		# if it is higher, delete watched=true episode
		dataset2.where(:watched => true).each do |i|
			if dataset2.where(:show_id => i[:show_id]).count > 1
				Database.removeEntry(dataset2, i[:id])
			else
				$logger.info "The episode id " + i[:id].to_s + "wasn't deleted because it's the last one."
			end
		end

		# Storing the "update" and only calling addEpisodes when the update field changes would make this much faster
		# Adds the new episodes of every tvshow checking the last season and episode numbers stored in the DB
		dataset1.each do |i|
			show = TVShow.new(i[:name], i[:id])
			lasteps = dataset2.where(:show_id => i[:id]).order(:seasonNumber, :episodeNumber).last[:seasonNumber]
			lastepn = dataset2.where(:show_id => i[:id]).order(:seasonNumber, :episodeNumber).last[:episodeNumber]
			#puts i[:name]
			#puts lasteps.to_s + " x " + lastepn.to_s
			Database.addNewEpisodes(dataset2, show, lasteps, lastepn)
		end
		
	rescue => e
		$logger.error("Exception in update : " + e.message)
		puts "Error."
	
	end

	# Removes a TVShow and all its episodes
	# SLOW METHOD?
	def Database.removeShow(dataset1, dataset2, showid)

		# Remove episodes of that show
		dataset2.where(:show_id => showid).each do |i|
			Database.removeEntry(dataset2, i[:id])
		end

		# Removing the show
		Database.removeEntry(dataset1, showid)
		
	rescue => e
		$logger.error("Exception in removeShow trying to remove show <" + showid + "> : " + e.message)
		puts "Error."
	
	end


	# Returns the ID of a show stored in the database. Receives a string with the show name
	# Would it be faster using the tvmaze api?
	# Initially trying to do it with web, do this if connection problem?
	# Initially doing this here, do it with Web if show isn't found?
	# Watch the infinite loop
	def Database.getShowID(dataset, showname)
		var = dataset.where(:name => showname).to_a[0]
		if var != nil # Found in the database
			var[:id]
		else # Search online
			$logger.warn("Show wasn't found in the database. Searching online.")
			Web.getShowID(showname)
		end

	rescue => e
		$logger.error("Exception in getShowID trying to get <" + showname + ">'s id : " + e.message)
		puts "Error."
	
	end

	def Database.getEpisodeID(dataset1, dataset2, season, episode, show)
		showid = Database.getShowID(dataset1, show)
		dataset2.where(:show_id => showid, :seasonNumber => season, :episodeNumber => episode).to_a[0][:id]

	rescue => e
		$logger.error("Exception in getEpisodeID trying to get <" + showname + ">'s id : " + e.message)
		puts "Error."
	
	end


	def Database.setWatched(dataset, episodeid)
		dataset.where(:id => episodeid).update(:watched => true)
	
	rescue => e
		$logger.error("Exception in setWatched trying to set episode <" + episodeid + "> as watched : " + e.message)
		puts "Error."
		
	end

	# Creates the TVShows and Episodes tables
	def Database.createTables

		DB.create_table :TVShows do
  		Integer :id, :primary_key=>true #TVMAZE ID
  		String :name
  	end

  	DB.create_table :Episodes do
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
		puts "Error."
	
	end

	# Returns a TVShow object. Receives the myShows dataset and the show id
	def Database.getShow (dataset, id)
		tvshowdata = dataset.where(:id => id).to_a
		TVShow.new(tvshowdata[0][:name], tvshowdata[0][:id])

	rescue => e
		$logger.error("Exception in getShow trying to get id <" + id + "> : " + e.message)
		puts "Error."
	
	end

	# Returns the episodes of a specific show id. Receives the episodes dataset and a showid as parameters
	def Database.getEpisodes(dataset, showID)
		dataset.where(:show_id => showID)
		
	rescue => e
		$logger.error("Exception in getEpisodes trying to get episodes for show <" + showID + "> : " + e.message)
		puts "Error."
	
	end

	# Returns the current number of entries in the given dataset
	def Database.numberOfEntries (dataset)
		dataset.count

	rescue => e
		$logger.error("Exception in numberOfEntries : " + e.message)
		puts "Error."
	
	end

	# Sets all the episodes of a tv show as watched
	# SLOW METHOD?
	def Database.setShowWatched(dataset1, dataset2, showid)

		dataset2.where(:show_id => showid).to_a.each do |i|
			Database.setWatched(dataset2, i[:id])
		end

	rescue => e
		$logger.error("Exception in setShowWatched with show <" + showid + "> : " + e.message)
		puts "Error."
	
	end

	# Returns an array of non-watched episodes, one per show.
	def Database.nextEpisodes(dataset1, dataset2)
		nextEpisodes = Array.new
		dataset1.each do |i|
			nextEpisodes <<  dataset2.where(:show_id => i[:id], :watched => false).order(:airdate).to_a[0]
		end

	return nextEpisodes

	rescue => e
		$logger.error("Exception in nextEpisodes : " + e.message)
		puts "Error."
	
	end

	# Prints general information about the shows in the DB. Receives myShows and episodes as parameters
	# SLOW METHOD?
	def Database.printShows(dataset1, dataset2)
		dataset1.each do |i|
			puts "TV Show <" + i[:name] + "> (id " + i[:id].to_s + ") " + "- " + dataset2.where(:show_id => i[:id]).count.to_s + " episodes stored"
		end
		puts
	end

	# Prints information about every show and episode stored in a readable format. Receives myShows and episodes as parameters
	def Database.printFull(dataset1, dataset2)
		dataset1.each do |i|
			puts "TV Show <" + i[:name] + "> (id " + i[:id].to_s + ")"
			dataset2.where(:show_id => i[:id]).each do |j|
				if j[:seasonNumber]<10
					seasonNumber = "0" + j[:seasonNumber].to_s
				end
				if j[:episodeNumber]<10
					episodeNumber = "0" + j[:episodeNumber].to_s
				end
				puts "\tS" + seasonNumber + "E" + episodeNumber + " - " + j[:title].to_s + " - " + (j[:watched]?"watched":"not watched")
			end
		end
		puts

	end

end