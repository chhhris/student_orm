# Columns to add to Students table:
#  Name
#  Profile Pic
#  Social media links/ Twitter, LinkedIn, GitHub, Blog(RSS)
#  Quote
#  About/ Bio, Education, Work
#  Coder Cred / Treehouse, Codeschool, Coderwal .reject(Github)

require 'nokogiri'
require 'open-uri'
require 'sqlite3'

database = "flatiron.db"
index_html = "http://students.flatironschool.com"


# Scrape index.html

  index = Nokogiri::HTML(open(index_html))

  student_css_selector = "li.home-blog-post div.blog-title a" # div.big-comment before "a" won't select Matt's profile
  students = index.css("#{student_css_selector}")


  # create an array of relative URLs for each student
  students_html_array = []
  students.each do |student|
    students_html_array << student.attr("href").downcase
  end

  puts "\nThe students_html_array looks like this:\n #{students_html_array.inspect}"

  puts "\nThere are #{students_html_array.size} elements in the array"




# Scrape individual student profiles based on the array created from scraping index.html

  # Create a new database and drop the students table from the database if it exists
  begin
    db = SQLite3::Database.new database
    db = SQLite3::Database.open database
    db.execute("DROP TABLE IF EXISTS Students")
  rescue SQLite3::Exception => e 
    puts "Exception occurred"
    puts e
  ensure
    db.close if db
  end 


  # Loop through each student profile URL in the array and insert all the info as a row in the students table
  students_html_array.each do |student_html|

    if student_html != "#" #only scrape page if page linked to from index.html exists

      begin

        puts # empty row
        student_page = Nokogiri::HTML(open("#{index_html}/#{student_html}"))

        # Get student's name
        name_css_selector = "h4.ib_main_header"
        html_tag_for_name = student_page.css("#{name_css_selector}").first # will return nil if the ib_main_header css selector is not found
        puts html_tag_for_name.class

        # only scrape the rest of page if html_tag_for_name is found (to make sure that only correctly formatted pages are scraped)
        if html_tag_for_name

          puts "...scraping: #{student_html}"

          new_student_hash = {}

          # Get name
          new_student_hash[:name] = html_tag_for_name.content

          # Get social media links
          social_media_selector = "div.social-icons a"
          new_student_hash[:twitter] = student_page.css("#{social_media_selector}" )[0].attr("href")

          # Get rest of columns for students
          # CODE TO BE FILLED

          new_student_string = new_student_hash.keys.to_s.gsub("]", "").gsub("[", "")
          columns_string = new_student_hash.keys.join(",").gsub(",", " TEXT, ") + " TEXT"


          # start manipulating the database
          # open the database
          db = SQLite3::Database.open database

          # create Students table if it doesn't exist
          db.execute("CREATE TABLE IF NOT EXISTS Students(id INTEGER PRIMARY KEY AUTOINCREMENT, 
                                                          #{columns_string})"
                    )

          # insert specific student into Students table if it doesn't exist
          db.execute("DELETE FROM Students WHERE name=?", new_student_hash[:name])
          db.execute("INSERT INTO Students(#{new_student_hash.keys.join(",")}) 
                                  VALUES (#{new_student_string})", new_student_hash
                    )

        else

          puts "#{student_html} isn't the correct template.  Page will not be scraped."

        end # end if html_tag_for_name doesn't exist

      rescue OpenURI::HTTPError => e

        puts "No profile found at " + student_html
        puts e

      rescue SQLite3::Exception => e     

        puts "SQLite3 Exception occurred"
        puts e

      ensure

        db.close if db

      end # end the begin-rescues block (potential errors: OpenURI::HTTPError, SQLite3::Exception)

    end  # end the if student_html != "#" block

  end # end the loop students_html_array.each