#!/usr/bin/env ruby -wKU
#
#  Simple script ecapsulating BingImageDownload class to get the daily image from www.bing.com and save it as a file locally
#
# Written by Dave Hodgson
# Cribbed and hacked from various other sources
#

require 'optparse'
require 'rubygems'
require 'mechanize'

class BingImageDownload

  @@bing_url= "http://www.bing.com"
  @@default_save_as_target_directory = './'

  attr_reader :save_as_target_directory, :save_as_fullpath, :image_url

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
    
    @image_url = get_bing_image_url
    
    save_as_filename = image_url_to_default_filename(@image_url)
    @save_as_fullpath = @save_as_target_directory + save_as_filename    
 
    # Go get the image from Bing and save it locally
    #
    puts "Getting image from: #{@image_url}\nSaving to: #{@save_as_fullpath}"
    result = @agent.get(@image_url).save_as(@save_as_fullpath)

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
        
    # Parse the background image URL from the Bing's obfuscated JavaScript.
    #
    # This is what we're looking for:
    #
    #    g_img={url:'\/fd\/hpk2\/TerceiraIsland_EN-US600272719.jpg'
    #
    page.body.match(/g_img=\{url:\'(\S+?)\'/)
 
    @todays_image_url = @@bing_url + $1
    
  end

end

if __FILE__ == $0

  t = Time.now
  puts t.strftime("\nStarted on: %A, %B %d at %I:%M %p\n")

  # This hash will hold all of the options
  # parsed from the command-line
  options = {}
  optparse = OptionParser.new do|opts|

    opts.banner = "Usage: #{$0} [-s]"

    # Define the options, and what they do
    options[:sleep] = false
    opts.on('-s', '--sleep', 'Sleep awhile before running' ) do
      options[:sleep] = true
    end

    opts.on( '-h', '--help', 'Display this text' ) do
      puts opts
      exit
    end

  end

  optparse.parse!

  # Build in delay to workaround the problem when the script is called by
  # LaunchCtrl just after the computer is awakes from sleep and the network 
  # connection hasn't restored yet...
  #
  if options[:sleep]
    puts "Sleeping for 30 seconds...";
    sleep 30;
  end

  puts t.strftime("\nRe-starting at: %I:%M %p\n")

  bid = BingImageDownload.new  
  
  if bid.download_todays_image(:save_directory => "/Users/Dave/Dropbox/Photos/Bing/")
    puts "File download appears successful :-)"
  else
    $stderr.puts "File download failed :-("
    exit(1)
  end
  
end

