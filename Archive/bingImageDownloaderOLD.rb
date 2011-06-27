#!/usr/bin/env ruby
#

require 'rubygems'
require 'mechanize'

C_BING_URL = "http://www.bing.com"
C_SAVEAS_DIR = "bing_images/"

#
# Connect to bing.com and get the "raw" HTML/JavaScript text of that page
#

agent = Mechanize.new
page = agent.get C_BING_URL
raw = page.root.to_s

#
# Parse the background image URL from the Bing's obfuscated JavaScript.
#
# This is what we're looking for:
#
#    g_img={url:'\/fd\/hpk2\/TerceiraIsland_EN-US600272719.jpg'
#

start_idx = raw.index('g_img={url')   # Find index of 'g_img' string in the raw web page text
first_quote_idx   = raw.index('\'', start_idx)  # Get index of the first quote after the 'g_img' string
first_quote_idx += 1 # Advance past the quote
last_quote_idx = raw.index('\'', first_quote_idx)  # Find the next quote after the first one. Image name is between them
image_path = raw.slice(first_quote_idx, last_quote_idx-first_quote_idx) # Copy the string between the two quotes
image_path.delete!('\\') # Cut out extraneous slash chars

image_url = C_BING_URL + image_path

#
# Create the filename to save the image locally as
#

matches = image_path.scan(/\S+\/(\S+.jpg)/)  # returns an array

if (matches.length != 1)
  $stderr.puts "Failed to match filename to save image"
  exit(1)
end

save_as_filename = C_SAVEAS_DIR + matches[0].to_s

#
# Create the local directory if necessary
#

if (File.directory?(C_SAVEAS_DIR) != true)   # If the save as directory doesn't exist...
  FileUtils.mkdir C_SAVEAS_DIR, :verbose => true   # create it
end

print "start_idx: #{start_idx}\nfirst_quote_idx #{first_quote_idx}\nlast_quote_idx #{last_quote_idx}\nurl string = \"#{image_url}\" save_as_filename = \"#{save_as_filename}\"\n"

#
# Go get the image from Bing and save it locally
#

agent.get(image_url).save_as(save_as_filename)
