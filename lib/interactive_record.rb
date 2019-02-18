require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end
  def self.column_names
    sql ="PRAGMA table_info('#{self.table_name}')"
    file=DB[:conn].execute(sql)
    file.map do |element| element["name"]
    end.compact
  end
  def initialize(hash={})
    hash.each do |key , value|
    self.send("#{key}=", value )
    end
  end


def table_name_for_insert
  self.class.table_name
end

def col_names_for_insert
self.class.column_names.delete_if {|col| col =="id"}.join(", ")
end

def values_for_insert
  values = []
  self.class.column_names.each do |x|
  values  <<  "'#{send(x)}'" unless send(x).nil?
end
  values.join(", ")
end
  def save
    sql= "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"

    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end
def self.find_by(hash)
  data= hash.values.first
  data_fixed = data.class == Fixnum ? data : "'#{data}'"
  sql = "SELECT * FROM #{self.table_name} WHERE #{hash.keys.first} = #{data_fixed}"
  DB[:conn].execute(sql)
end
end
