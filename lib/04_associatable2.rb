require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options
        .model_class.assoc_options[source_name]

      source_table = source_options.table_name
      through_table = through_options.table_name
      primary_key = source_options.primary_key
      through_foreign_key = through_options.foreign_key
      source_foreign_key = source_options.foreign_key

      rows = DBConnection.execute(<<-SQL, send(through_foreign_key))
        SELECT
          #{source_table}.*
        FROM
          #{through_table}
        JOIN
          #{source_table}
          ON #{through_table}.#{source_foreign_key} = #{source_table}.#{primary_key}
        WHERE
          #{through_table}.id = ?
      SQL

      rows.map do |hash|
        source_options.model_class.new(hash)
      end.first
    end
  end
end
