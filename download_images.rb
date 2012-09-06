require 'open-uri'
require 'csv'

csv = CSV.read('./data/matchdata.csv')

csv.each do |row|

  begin
    picture = open("http://itp.nyu.edu/image.php?width=512&height=512&image=/people_pics/itppics/#{row[0]}.jpg").read
  rescue
    puts "404 #{row[0]}"
    picture = nil
  end

  if picture
    open("./data/images/#{row[0]}.jpg", "wb") do |file|
      file << picture
    end
  end
end
