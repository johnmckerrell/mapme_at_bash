#!/usr/bin/ruby
##
# Mapme.at GPS access script
# (c) John McKerrell 2009
# This code has been released into the public domain and may be modified
# and distributed without restriction.

##
# Quick Ruby script to get the Lat/Lon from NMEA format GPS output
# NMEA format found here: http://www.kh-gps.de/nmea-faq.htm

##
# Parse the NMEA format latitude and longitude and return as a tuple
def self.makeLocation (lat, lon, ns, ew)
  lat = lat.to_f / 100;
  lon = lon.to_f / 100;
  lat = lat.to_i + ( ( (lat - lat.to_i.to_f) * 100 ) / 60)
  lon = lon.to_i + ( ( (lon - lon.to_i.to_f) * 100 ) / 60)
  lat = (lat*100000).round/100000.0
  lon = (lon*100000).round/100000.0
  if ns == "S"
    lat = 0 - lat
  end
  if ew == "W"
    lon = 0 - lon
  end
  [lat,lon]
end

##
# The script is fairly simple, it basically reads up to 15 lines
# of output from the specified device. It tries numerous ways to
# until it gets a location at which point it outputs the location
# and quits.
position = []
linesRead = 0
begin 
  #gpsDev = File.open("/dev/tty.HOLUXGPSlim236-SPPslave-1", "r")
  gpsDev = File.open(ARGV[0], "r")
  gpsDev.each_line do |line|
    if linesRead > 15
      #print "too many lines read\n"
      break
    end
    parts = line.split(',')
    case parts[0]
    when '$GPRMB'
      #position = [parts[6],parts[8]]
      position = makeLocation(parts[6],parts[8],parts[7],parts[9])
    when '$GPRMC'
      #position = [parts[3],parts[5]]
      position = makeLocation(parts[3],parts[5],parts[4],parts[6])
      time = parts[1]
    when '$GPGGA'
      #position = [parts[2],parts[4]]
      position = makeLocation(parts[2],parts[4],parts[3],parts[5])
    when '$GPRMA'
      #position = [parts[2],parts[4]]
      position = makeLocation(parts[2],parts[4],parts[3],parts[5])
    end
    if position.length == 2 
      break
    end
    linesRead+=1
  end
  gpsDev.close
rescue SystemCallError
rescue TypeError
  #gpsDev.close
  #print "Couldn't open GPS device.\n"
end

if position.length == 2
  print position[0].to_s + " " + position[1].to_s+"\n"
end
