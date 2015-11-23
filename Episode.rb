module MyTV
	class Episode

		attr_reader :title, :season, :id, :number, :airdate

		def initialize (n, s, e, air, id)
			@title, @season, @number = n, s, e
			@id = id
			@airdate = Date.parse(air)#.next  # YYYY-MM-DD
			@watched = false
			
		end
	
		def watched
			@watched=true
		end

		def to_s
			puts "This is the Episode named " + @title + " S" + @season + "E" + @number
		end

	end
end