module Import
	def Import.import(dataset1, dataset2, filename)
		File.foreach(filename) do |x|
			Database.addShow(dataset1, dataset2, x)
		end
	rescue => e
		$logger.error("Exception importing file <" + filename + "> : " + e.message)
		puts "Error: " + e.message
	end

	# Creates a file ready for importing from http://www.myepisodes.com/myshows/manage/.
	def Import.myEpisodesImport(user, pass)
		agent = Mechanize.new

		page = agent.get 'http://www.myepisodes.com/login.php'

		loginform = page.forms[3]
		loginform.username = user
		loginform.password = pass
		loginform.u = "myshows/manage/"

		page = agent.submit(loginform, loginform.buttons.first)
		shows = page.parser.css('select#shows option')

		file = File.open("shows.txt", 'w')
		shows.each do |i|
			file.write(i.text + "\n")
		end
		file.close

	end

end
=begin

=end