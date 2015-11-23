module MyTV
	class TVShow

		attr_reader :name, :episodes, :id

		def initialize(n, id)
			@name = n
			@id = id
			loadEpisodes(id)
			
		end

		def getEpisodes
			@episodes
		end

		def loadEpisodes(id)
			@episodes = Array.new()
			episodelist = Web.getEpisodes(id)
			episodelist.each do |i|
				@episodes << Episode.new(i['name'].to_s, i['season'], i['number'], i['airdate'], i['id'])
			end

			rescue => e
			$logger.error("Exception in loadEpisodes trying to add episodes for <" + @name + "> : " + e.message)
			puts "Error: " + e.message
		end

		def to_s
			puts "This is the TV show named " + @name + " which has " + @episodes.size.to_s + " episodes"
		end
	end
end