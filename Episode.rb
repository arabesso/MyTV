module MyTV
	class Episode

		attr_reader :title, :season, :id, :number, :airdate

		def initialize (n, s, e, air, id)
			@title, @season, @number, @id = n, s, e, id
			if air!=""
				@airdate = Date.parse(air)   # YYYY-MM-DD
			else
				@airdate = Date.new(2100, 1, 1) # Shows stored with missing air dates are set to air in 1/1/2100. I have 94 years to figure out a better solution.
			end
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