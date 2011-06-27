agent = Mechanize.new
url = "http://gdata.youtube.com/feeds/api/standardfeeds/most_viewed" # all time

page = agent.get(url)

# parse again w/ Hpcricot for some XML convenience
doc = Hpricot.parse(page.body)

# pp (doc/:entry) # like "search"; cool division overload
images = (doc/'media:thumbnail') # use strings instead of symbols for namespaces

FileUtils.mkdir_p 'youtube-images' # make the images dir

urls = images.map { |i| i[:url] }

urls.each_with_index do |file,index|
  puts "Saving image #{file}"
  agent.get(file).save_as("youtube-images/vid#{index}_#{File.basename file}")
end
