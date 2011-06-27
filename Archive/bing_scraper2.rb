#!/usr/bin/env ruby -wKU

require 'rubygems'
require 'mechanize'

mech = Mechanize.new
page = mech.get("http://www.bing.com")


# This is what we're looking for:
#
#    g_img={url:'\/fd\/hpk2\/TerceiraIsland_EN-US600272719.jpg'
#

page.body.match(/g_img=\{url:\'(\S+?)\'/)

puts "Matched: #{$1}" if $1


#imgs = page.search("img[src]").map { |src| src['src'] }
#puts imgs