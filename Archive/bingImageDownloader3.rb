#!/usr/bin/env ruby -w
#
require 'rubygems'
require 'mechanize'

class BingImageDownload

  @@bing_url= "http://www.bing.com"
  @@default_save_as_target_directory = './'

  attr_reader :save_as_target_directory, :todays_image_url

  def initialize ()
    @save_as_target_directory = @@default_save_as_target_directory
    @agent = Mechanize.new
  end


  def download_todays_image(params = {:save_directory => @@default_save_as_target_directory})
  
    @save_as_target_directory = params[:save_directory]
    
    if ! validate_directory?(@save_as_target_directory)
      $stderr.puts "Invalid directory: #{save_as_target_directory}"
      return false
    end
    
    image_url = get_bing_image_url
    
    save_as_filename = image_url_to_default_filename(image_url)
    save_as_fullpath = @save_as_target_directory + save_as_filename    
 
    # Go get the image from Bing and save it locally
    #
    puts "Getting image from: #{image_url}\nSaving to: #{save_as_fullpath}"
    result = @agent.get(image_url).save_as(save_as_fullpath)

    return File.exists?(save_as_fullpath)

  end

def validate_directory?(dir_to_validate)

    return File.directory?(dir_to_validate)
    
  end

  # Create the filename to save the image locally as
  #  
  def image_url_to_default_filename (image_url = @todays_image_url)

    matches = image_url.scan(/\S+\/(\S+.jpg)/)  # returns an array

    if (matches.length != 1)
      return nil
    end
    
    return matches[0].to_s
    
  end

  def get_bing_image_url
    
    # Connect to bing.com and get the "raw" HTML/JavaScript text of that page
    #
    page = @agent.get @@bing_url
    raw = page.root.to_s
        
    # Parse the background image URL from the Bing's obfuscated JavaScript.
    #
    # This is what we're looking for:
    #
    #    g_img={url:'\/fd\/hpk2\/TerceiraIsland_EN-US600272719.jpg'
    #
    
    start_idx = raw.index('g_img={url')                                     # Find index of 'g_img' string in the raw web page text
    first_quote_idx   = raw.index('\'', start_idx)                          # Get index of the first quote after the 'g_img' string
    first_quote_idx += 1                                                    # Advance past the quote
    last_quote_idx = raw.index('\'', first_quote_idx)                       # Find the next quote after the first one. Image name is between them
    image_path = raw.slice(first_quote_idx, last_quote_idx-first_quote_idx) # Copy the string between the two quotes
    image_path.delete!('\\')                                                # Cut out extraneous slash chars

    @todays_image_url = @@bing_url + image_path
    
  end

end

if __FILE__ == $0

  bid = BingImageDownload.new  
  
  if bid.download_todays_image(:save_directory => "/Users/Dave/Dropbox/Photos/Bing/")
    puts "File download appears successful :-)"
  else
    $stderr.puts "File download failed :-("
    exit(1)
  end
  
end

