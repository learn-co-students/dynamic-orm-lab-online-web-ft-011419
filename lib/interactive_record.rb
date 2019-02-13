require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = "PRAGMA table_info('#{table_name}')"
    # Retrieves the "hidden data from the specified table. This data will contain each column name"

    table_info = DB[:conn].execute(sql)
    # Saves the "hidden data" to the variable table_info
    binding.pry 
    column_names = []

    table_info.each {|column| column_names << column["name"]}
    # Adds the "name" value of each column from the table_info variable and adds it to the column_names array

    column_names.compact # .compact removes any nil values
  end

  def initialize(options={})
    options.each {|property, value| self.send("#{property}=", value)}
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col_name| col_name == "id"}.join(", ")
  end
  # .delete_if removes all "id" columns from the array returned by column_names. We do not want to submit id columns when saving because the id column is created by the table automatically when a new row is added

  def values_for_insert
    values = []
    self.class.column_names.each {|col_name| values << "'#{send(col_name)}'" unless send(col_name).nil?}
    values.join(", ")
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"

    DB[:conn].execute(sql)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]

  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

  def self.find_by(attribute_hash)
    sql = "SELECT * FROM #{self.table_name} WHERE #{attribute_hash.keys[0].to_s} = '#{attribute_hash.values[0].to_s}'"
    DB[:conn].execute(sql)
  end

end
