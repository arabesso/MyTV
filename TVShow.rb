module MyTV
	class TVShow

		attr_reader :name, :episodes, :id

		def initialize(n, id)
			@name = n
			@id = id
			load_episodes(id)
			
		end

		def load_episodes(id)
			@episodes = Array.new()
			episodelist = Web.get_episodes(id)
			episodelist.each do |i|
				@episodes << Episode.new(i['name'].to_s, i['season'], i['number'], i['airdate'], i['id'])
			end

			rescue => e
			$logger.error("Exception in load_episodes trying to add episodes for <" + @name + "> : " + e.message)
			puts "Error: " + e.message
		end

		def to_s
			puts "This is the TV show named " + @name + " which has " + @episodes.size.to_s + " episodes"
		end
	end
end