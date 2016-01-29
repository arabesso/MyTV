require "mechanize"

module MyTV
	class Import
		def Import.import(dataset1, dataset2, filename, verbose=true)
			File.foreach(filename) do |showname|
				Database.add_show(dataset1, dataset2, showname, verbose)
			end
		rescue => e
			$logger.error("Exception importing file <" + filename + "> : " + e.message + " [" + e.class.to_s + "]")
			puts "Error: " + e.message + " [" + e.class.to_s + "]"
		end

		# Creates a file ready for importing from http://www.myepisodes.com/myshows/manage/.
		def Import.myepisodes_import(user, pass, filename = "shows.txt")
			agent = Mechanize.new

			page = agent.get "http://www.myepisodes.com/login.php"

			loginform = page.forms[1]
			loginform.username = user
			loginform.password = pass
			loginform.u = "myshows/manage/"

			page = agent.submit(loginform, loginform.buttons.first)
			shows = page.parser.css('select#shows option')

			file = File.open(filename, 'w')
			shows.each do |i|
				file.write(i.text + "\n")
			end
			file.close

		rescue => e
			$logger.error("Exception importing from myEpisodes : " + e.message + " [" + e.class.to_s + "]")
			puts "Error: " + e.message + " [" + e.class.to_s + "]"
		end

	end
end