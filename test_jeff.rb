require 'fis/test'
require_relative 'student_new' ## Change this to your student file

include Fis::Test

test 'should create a table' do
  assert Student.drop
  assert !Student.table_exists?('students')
  assert Student.create_table
  assert Student.table_exists?('students')
end

test 'should be able to instantiate a student' do
  assert Student.new
end

test 'should be able to save a student with a name' do
  avi = Student.new
  avi.name = "Avi Flombaum"
  avi.save

  assert_equal Student.find_by_name("Avi Flombaum").name, "Avi Flombaum"
end

test 'should be able to load all students' do
  s = Student.new
  s.name = "Avi Flombaum"
  s.save

  assert Student.all.collect{|s| s.name}.include?("Avi Flombaum")
end

test 'should be able to find a student by id' do
  s = Student.new
  s.name = "Avi Flombaum"
  s.save

  p s.id


  assert_equal Student.find(s.id).name, "Avi Flombaum"
end

test 'should be able to update a student' do
  s = Student.new
  s.name = "Avi Flombaum"
  s.save

  s.name = "Bob Whitney"
  s.save

  assert_equal Student.find(s.id).name, "Bob Whitney"
end

############################################################################
### LAST 3 TESTS ARE 1) BONUS, AND 2) NEED TO BE UPDATED FROM GIST

test 'should be able to retrive a student with a where statment' do
  s = Student.new
  s.name = "Jeff Baird"
  s.save

  assert_equal Student.where(:name => "Jeff Baird"), [[s.id, "Jeff Baird", nil, nil]]

end

test 'should be able to retrieve multiple students with the same name' do
  s = Student.new
  s.name = "Alice Adams"
  s.save

  s2 = Student.new
  s2.name = "Alice Adams"
  s2.save


  assert_equal Student.where(:name => "Alice Adams"), [[s.id, "Alice Adams", nil, nil],[s2.id, "Alice Adams", nil, nil]]
end

test 'should be able to find_by any attribue' do
  s = Student.new
  s.name = "Avi Flombaum"
  s.tagline = "Hello World"
  s.bio = "Dean at Flatiron School"
  s.save

 assert_equal Student.find_by_tagline("Hello World").tagline, "Hello World"
 assert_equal Student.find_by_bio("Dean at Flatiron School").bio, "Dean at Flatiron School"
 assert_equal Student.find_by_name("Avi Flombaum").name, "Avi Flombaum"
end
