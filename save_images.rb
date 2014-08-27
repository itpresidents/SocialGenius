

require 'open-uri'
require 'csv'

netid_col = 0
first_name_col = 1
last_name_col = 2
preffered_first_name_col = 3
preffered_last_name_col = 4
year_col = 5

args = ARGV

opts = {
  :width => 200,
  :height => 300
}

while args.length > 0
  a = args.shift
  case a
  when "-w"
    opts[:width] = args.shift
    next
  when "-h"
    opts[:height] = args.shift
    next
  when "-y"
    opts[:year] = args.shift
    next
  else
    filename = a
  end
end

%x[mkdir -p images]

if filename.nil?
  puts "ERROR: You must provide a path to a csv"
  exit 1
end

# Open CSV as a CSV object
csv = CSV.open('./' + filename)

# Now go through the CSV line by line
csv.each do |row|

  # If a year was specified
  if !opts[:year].nil?
    # Skip to the next line if this line doesn't match the year
    next if row[year_col] != opts[:year]
  end

  begin
    image_url = "http://itp.nyu.edu/image.php?width=#{opts[:width]}&height=#{opts[:height]}&image=/people_pics/itppics/#{row[netid_col]}.jpg"
    puts image_url
    picture = open(image_url).read
  rescue
    puts "404 #{row[netid_col]}"
    picture = nil
  end

  if picture
    open("./images/#{row[netid_col]}.jpg", "wb") do |file|
      file << picture
    end
  end
end