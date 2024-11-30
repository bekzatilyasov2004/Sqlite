require 'readline'
require_relative 'my_sqlite_request.rb'

class MySqliteCLI
  def initialize
    @running = true
  end

  def start
    puts "MySQLite version 0.1 #{Time.now.strftime('%Y-%m-%d')}"
    while @running
      input = Readline.readline('my_sqlite_cli> ', true)
      handle_command(input)
    end
  end

  def handle_command(input)
    case input.strip.downcase
    when /^select\s+.*;$/i
      handle_select(input)
    when /^insert\s+.*;$/i
      handle_insert(input)
    when /^update\s+.*;$/i
      handle_update(input)
    when /^delete\s+.*;$/i
      handle_delete(input)
    when /^quit$/i, /^exit$/i
      @running = false
    else
      puts "Invalid command."
    end
  end

  def handle_select(input)
    request = MySqliteRequest.new
    table_name = extract_table_name(input)
    columns = extract_columns(input)
    where_clause = extract_where_clause(input)
    order_clause = extract_order_clause(input)
    
    request = request.from(table_name)
    request = request.select(columns)
    
    if where_clause
      where_clause.each do |column, value|
        request = request.where(column, value)
      end
    end

    if order_clause
      request = request.order(order_clause[:order], order_clause[:column])
    end

    results = request.run
    results.each { |row| puts row.values.join('|') }
  end

  def handle_insert(input)
    request = MySqliteRequest.new
    table_name = extract_table_name(input, :insert)
    values = extract_values(input)
    
    request = request.insert(table_name)
    request = request.values(values)
    request.run
  end

  def handle_update(input)
    request = MySqliteRequest.new
    table_name = extract_table_name(input, :update)
    set_clause = extract_set_clause(input)
    where_clause = extract_where_clause(input)

    request = request.update(table_name)
    request = request.set(set_clause)
    
    if where_clause
      where_clause.each do |column, value|
        request = request.where(column, value)
      end
    end

    request.run
  end

  def handle_delete(input)
    request = MySqliteRequest.new
    table_name = extract_table_name(input, :delete)
    where_clause = extract_where_clause(input)

    request = request.from(table_name)
    request = request.delete
    
    if where_clause
      where_clause.each do |column, value|
        request = request.where(column, value)
      end
    end

    request.run
  end

  def extract_table_name(input, command_type = :select)
    case command_type
    when :select, :delete
      input.match(/from\s+(\w+)/i)[1]
    when :insert
      input.match(/into\s+(\w+)/i)[1]
    when :update
      input.match(/update\s+(\w+)/i)[1]
    end
  end

  def extract_columns(input)
    input.match(/select\s+(.*?)\s+from/i)[1].split(',').map(&:strip)
  end

  def extract_values(input)
    values = input.match(/\((.*?)\)/)[1]
    values.split(',').map(&:strip).map { |v| v.delete("'") }
  end

  def extract_set_clause(input)
    set_clause = input.match(/set\s+(.*?)\s+where/i)[1]
    Hash[set_clause.split(',').map { |pair| pair.split('=').map(&:strip) }]
  end

  def extract_where_clause(input)
    return nil unless input =~ /where\s+(.*?)(;|order)/i
    where_clause = input.match(/where\s+(.*?)(;|order)/i)[1]
    Hash[where_clause.split('and').map { |pair| pair.split('=').map(&:strip) }]
  end

  def extract_order_clause(input)
    return nil unless input =~ /order\s+by\s+(\w+)\s+(asc|desc)/i
    order_clause = input.match(/order\s+by\s+(\w+)\s+(asc|desc)/i)
    { column: order_clause[1], order: order_clause[2].to_sym }
  end
end

MySqliteCLI.new.start if __FILE__ == $0
