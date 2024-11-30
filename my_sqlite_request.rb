require 'csv'

class MySqliteRequest
  def initialize
    @Request_Type   = :none
    @select_columns    = []
    @where_params      = []
    @insert_attributes = {}
    @update_attributes = {}
    @table_name        = nil
    @order             = :asc
    @join_params       = nil
  end

  def from(table_name)
    @table_name = table_name
    self
  end

  def select(columns)
    if columns.is_a?(Array)
      @select_columns += columns.collect { |elem| elem.to_s }
    else
      @select_columns << columns.to_s
    end
    self._setTypeOfRequest(:select)
    self
  end

  def where(column_name, criteria)
    @where_params << [column_name, criteria]
    self
  end

  def join(column_on_db_a, filename_db_b, column_on_db_b)
    @join_params = {
      column_on_db_a: column_on_db_a,
      filename_db_b: filename_db_b,
      column_on_db_b: column_on_db_b
    }
    self
  end

  def order(order, column_name)
    @order = { order: order, column_name: column_name }
    self
  end

  def insert(table_name)
    self._setTypeOfRequest(:insert)
    @table_name = table_name
    self
  end

  def values(data)
    if @Request_Type == :insert
      @insert_attributes = data
    else
      raise 'Wrong type of request to call values()'
    end
    self
  end

  def update(table_name)
    self._setTypeOfRequest(:update)
    @table_name = table_name
    self
  end

  def set(data)
    if @Request_Type == :update
      @update_attributes = data
    else
      raise 'Wrong type of request to call set()'
    end
    self
  end

  def delete
    self._setTypeOfRequest(:delete)
    self
  end

  def print_select_type
    puts "Select Attributes #{@select_columns}"
    puts "Where Attributes #{@where_params}"
  end

  def print_insert_type
    puts "Insert Attributes #{@insert_attributes}"
  end

  def print_update_type
    puts "Update Attributes #{@update_attributes}"
    puts "Where Attributes #{@where_params}"
  end

  def print
    puts "Type Of Request #{@Request_Type}"
    puts "Table Name #{@table_name}"
    if @Request_Type == :select
      print_select_type
    elsif @Request_Type == :insert
      print_insert_type
    elsif @Request_Type == :update
      print_update_type
    end
  end

  def run
    print
    if @Request_Type == :select
      _run_select
    elsif @Request_Type == :insert
      _run_insert
    elsif @Request_Type == :update
      _run_update
    elsif @Request_Type == :delete
      _run_delete
    end
  end

  def _setTypeOfRequest(new_type)
    if @Request_Type == :none or @Request_Type == new_type
      @Request_Type = new_type
    else
      raise "Invalid: type of request already set to #{@Request_Type} (new type => #{new_type})"
    end
  end

  def _run_select
    result = []
    data = CSV.read(@table_name, headers: true).map(&:to_hash)

    if @join_params
      join_data = CSV.read(@join_params[:filename_db_b], headers: true).map(&:to_hash)
      data = data.map do |row|
        join_row = join_data.find { |j_row| j_row[@join_params[:column_on_db_b]] == row[@join_params[:column_on_db_a]] }
        row.merge(join_row || {})
      end
    end

    if @where_params.any?
      data.select! do |row|
        @where_params.all? { |column, value| row[column] == value }
      end
    end

    result = data.map { |row| row.slice(*@select_columns) }
    result.sort_by! { |row| row[@order[:column_name]] } if @order
    result.reverse! if @order && @order[:order] == :desc

    result
  end

  def _run_insert
    CSV.open(@table_name, 'a') do |csv|
      csv << @insert_attributes.values
    end
  end

  def _run_update
    data = CSV.read(@table_name, headers: true).map(&:to_hash)

    data.each do |row|
      if @where_params.all? { |column, value| row[column] == value }
        @update_attributes.each do |column, value|
          row[column] = value
        end
      end
    end

    CSV.open(@table_name, 'w') do |csv|
      csv << data.first.keys
      data.each do |row|
        csv << row.values
      end
    end
  end

  def _run_delete
    data = CSV.read(@table_name, headers: true).map(&:to_hash)

    data.reject! do |row|
      @where_params.all? { |column, value| row[column] == value }
    end

    CSV.open(@table_name, 'w') do |csv|
      csv << data.first.keys
      data.each do |row|
        csv << row.values
      end
    end
  end
end

def _main
  request = MySqliteRequest.new
  request = request.insert('nba_player_data_light.csv')
  request = request.values({
    "name" => "Don Adams",
    "year_start" => "1971",
    "year_end" => "1977",
    "position" => "F",
    "height" => "6-6",
    "weight" => "210",
    "birth_date" => "November 27, 1947",
    "college" => "Northwestern University"
  })
  request.run
end

_main()



# ORIGINAL CODE 

# require  'csv'

# class MySqliteRequest
#     def initialize
#         @type_of_request   = :none
#         @select_columns    = []
#         @where_params      = []
#         @insert_attributes = {}
#         @table_name        = nil
#         @order             = :asc
#     end

#     def from(table_name)
#         @table_name = table_name
#         self
#     end

#     def select(columns)
#         # @type_of_request = :select
#         if(columns.is_a?(Array))
#             @select_columns += columns.collect { |elem| elem.to_s}
#         else
#             @select_columns << columns.to_s
#         end
#         self._setTypeOfRequest(:select)
#         self
#     end

#     def where(column_name, criteria)
#         @where_params << [column_name , criteria]
#         self
#     end

#     def join(column_on_db_a, filename_db_b, column_on_db_b)
#         self
#     end

#     def order(order, column_name)
#         self
#     end

#     def insert(table_name)
#         self._setTypeOfRequest(:insert)
#         @table_name = table_name
#         self
#     end

#     def values(data)
#         if(@type_of_request == :insert)
#             @insert_attributes = data
#         else
#             raise 'Wrong type of request to call values()'
#         end
#         self
#     end

#     def update(table_name)
#         self._setTypeOfRequest(:update)
#         @table_name = table_name
#         self
#     end

#     def set(data)
#         self
#     end

#     def delete
#         self._setTypeOfRequest(:delete)
#         self
#     end

#     def print_select_type
#         puts "Select Attributes #{@select_columns}"
#         puts "where Attributes #{@where_params}"
#     end

#     def print_insert_type
#         puts "Insert Attributes #{@insert_attributes}"
#     end

#     def print
#         puts "Type Of Request #{@type_of_request}"
#         puts "Table Name #{@table_name}"
#         if(@type_of_request == :select)
#            print_select_type
#         elsif (@type_of_request == :insert)
#             print_insert_type
#         end
#     end

#     def run
#         print
#         if(@type_of_request == :select)
#             _run_select
#         elsif (@type_of_request == :insert)
#             _run_insert
#         end
#     end

#     def _setTypeOfRequest(new_type)
#         if(@type_of_request == :none or @type_of_request == new_type)
#             @type_of_request = new_type
#         else
#             raise"Invalid: type of request already set to #{@type_of_request} (new type => #{new_type}"
#         end
#     end


#     def _run_select
#         result = []
#         CSV.parse(File.read(@table_name), headers: true).each do |row|
#             @where_params.each do |where_attribute|
#                 if row[where_attribute[0]] == where_attribute[1]
#                     result << row.to_hash.slice(*@select_columns)
#                 end
#             end
#         end
#         result
#     end

#     def _run_insert
#         File.open(@table_name, 'a') do |f|
#             f.puts @insert_attributes.values.join(',')
#         end
#     end
# end

# def _main()
# =begin
#     request = MySqliteRequest.new
#     request = request.from('nba_player_data.csv')
#     request = request.select('name')
#     request = request.where('year_start', '1991')
#     p request.run.count
# =end
#     request = MySqliteRequest.new
#     request = request.insert('nba_player_data_light.csv')
#     request = request.values({"name" => "Don Adams" ,"year_start" => "1971" ,"year_end" => "1977" ,"position" => "F" ,"height" => "6-6" ,"weight" => "210" ,"birth_date" => "November 27, 1947" ,"college" => "Northwestern University"})
#     request.run
# end

# _main()

