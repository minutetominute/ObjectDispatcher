require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    rows = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL

    rows.first.each_with_object([]) do |el, columns|
      columns << el.to_sym
    end
  end

  def self.finalize!
    columns.each do |col|

      define_method(col.to_s + "=") do |arg|
        attributes[col] = arg
      end

      define_method(col) do
        attributes[col]
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.to_s.tableize
  end

  def self.all
    rows = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL

    parse_all(rows)
  end

  def self.parse_all(results)
    results.map do |hash|
      self.new(hash)
    end
  end

  def self.find(id)
    rows = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        id = ?
    SQL
    parse_all(rows).first
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      unless self.class.columns.include?(attr_name.to_sym)
        raise "unknown attribute '#{attr_name}'"
      end
      send("#{attr_name.to_s}=", value)
    end
  end

  def attributes
    @attributes ||= Hash.new
  end

  def attribute_values
    attributes.values
  end

  def insert
    col_names = self.class
      .columns
      .reject{ |name| name == :id }.join(", ")
    values = attribute_values
    DBConnection.execute(<<-SQL, *values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{(["?"] * values.count).join(', ')})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    set_line = self.class
      .columns
      .reject{ |name| name == :id }
      .map do |attr_name|
        "#{attr_name} = ?"
      end.join(", ")

    values = attribute_values.drop(1) << id

    DBConnection.execute(<<-SQL, *values)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_line}
      WHERE
        id = ?
    SQL
  end

  def save
    id ? update : insert
  end
end
