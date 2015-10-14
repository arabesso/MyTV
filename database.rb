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



	end

	# Add episodes to the database. Receives a TVShow and the dataset episodes as parameters
	# PRIVATE?
	# SLOW METHOD?
	# Since it's only called from addShow, maybe we could remove the first conditional to make it faster. addShow already checks if it's in the DB
	# And we don't call addEpisodes if the show is already added, we have addNewEpisodes for that.
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
	end

	# Add only the new episodes to the database. Receives a TVShow and the dataset episodes as parameters
	# PRIVATE=
	# SLOW METHOD?
	def Database.addNewEpisodes (dataset, show, lastEpisodeS, lastEpisodeN)
		id = show.getID
		episodes = show.getEpisodes

		# Quick check if there are new episodes
		if (episodes[-1].getSeason > lastEpisodeS)
		elsif lastEpisodeS == episodes[-1].getSeason and episodes[-1].getNumber > lastEpisodeN
		else
			$logger.info "No new episodes to add to <" + show.getName + ">"
			return
		end
		

		# New episodes to add, full iteration:
		episodes.each do |i|
			if (i.getSeason > lastEpisodeS)
				dataset.insert(:id => i.getID, :title => i.getTitle, :seasonNumber => i.getSeason, :episodeNumber => i.getNumber, :airdate => i.getAirdate, :watched => false, :show_id => id)
				$logger.info "Added episode <" + i.getTitle + ">"
			elsif lastEpisodeS == i.getSeason and i.getNumber > lastEpisodeN
				dataset.insert(:id => i.getID, :title => i.getTitle, :seasonNumber => i.getSeason, :episodeNumber => i.getNumber, :airdate => i.getAirdate, :watched => false, :show_id => id)
				$logger.info "Added episode <" + i.getTitle + ">"
			end
		end

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
		
	end


	def Database.setWatched(dataset, episodeid)
		#if dataset.where(:id => episodeid, :watched => false)
		dataset.where(:id => episodeid).update(:watched => true)
		#else
		#	$logger.warn "The episode with id " + episodeid.to_s + "is already marked as watched"
		#end
		
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

	end

	# Returns a TVShow object. Receives the myShows dataset and the show id
	def Database.getShow (dataset, id)
		tvshowdata = dataset.where(:id => id).to_a
		TVShow.new(tvshowdata[0][:name], tvshowdata[0][:id])
	end

	# Returns the episodes of a specific show id. Receives the episodes dataset and a showid as parameters
	def Database.getEpisodes(dataset, showID)
		dataset.where(:show_id => showID)
		
	end

	# Returns the current number of entries in the given dataset
	def Database.numberOfEntries (dataset)
		dataset.count
	end

	# Sets all the episodes of a tv show as watched
	# SLOW METHOD?
	def Database.setShowWatched(dataset1, dataset2, showid)

		dataset2.where(:show_id => showid).to_a.each do |i|
			Database.setWatched(dataset2, i[:id])
		end

	end

	# Prints general information about the shows in the DB. Receives myShows and episodes as parameters
	# SLOW METHOD?
	def Database.printShows(dataset1, dataset2)
		dataset1.each do |i|
			puts "TV Show <" + i[:name] + "> (id " + i[:id].to_s + ") " + "- " + dataset2.where(:show_id => i[:id]).count.to_s + " episodes stored"
		end
		
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
				puts "\tS" + seasonNumber + "E" + episodeNumber + " - " + j[:title]
			end
		end
	end

end