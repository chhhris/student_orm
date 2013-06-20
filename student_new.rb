require 'sqlite3'


class Student
  attr_accessor :id, :name


  DB_NAME = "flatiron.db"
  db = SQLite3::Database.open DB_NAME

  def self.create_table
    db = SQLite3::Database.open DB_NAME
    db.execute("CREATE TABLE IF NOT EXISTS students(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)")    
  end

  def self.drop
    # begin
    db = SQLite3::Database.open DB_NAME
    db.execute("DROP TABLE IF EXISTS students") 
  end

  def self.db
    SQLite3::Database.open DB_NAME
  end

  def self.table_exists?(table_name)
    db = SQLite3::Database.open DB_NAME
    db.execute("SELECT * FROM sqlite_master WHERE type='table'AND name=?", table_name)
  end

  def save
    db = SQLite3::Database.open DB_NAME
    db.execute("INSERT INTO students(name) VALUES(?)", @name)
    self.id=(db.execute("SELECT last_insert_rowid()").flatten[0])
  end

  def self.find_by_name(name)
    db = SQLite3::Database.open DB_NAME
    rows = db.execute("SELECT * FROM students WHERE name=?", name)
    self.to_student(rows.first) if !rows.empty?
  end

  def self.to_student(row_array)
    # this method takes an array and returns an object
    new_person = Student.new
    new_person.id = row_array[0]
    new_person.name = row_array[1]
    new_person
  end

  def self.all
    db = SQLite3::Database.open DB_NAME
    all_rows = db.execute("SELECT * FROM students")
    all_rows.collect {|s| to_student(s)}
  end

  def self.find(id)
    db = SQLite3::Database.open DB_NAME
    rows = db.execute("SELECT * FROM students WHERE id=?", id)
    self.to_student(rows.first) if !rows.empty?
  end

end