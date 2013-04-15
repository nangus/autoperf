require "./lib/autoperf/display"
require "minitest/autorun"

class TestAutoperfDisplay < MiniTest::Unit::TestCase
  def setup
    @result = {
      100 => {
        :connection_rate_per_sec => 10,
        :request_rate_per_sec    => 10,
        :reply_rate_avg          => 10,
        :errors_total            => 2,
        :reply_status_5xx        => 2,
        :net_io_kb_sec           => 1000
      }
    }
  end

  def test_init_default
    display = Autoperf::Display.new(@result)
    assert_equal Ruport::Data::Table, display.instance_variable_get(:@table).class
    assert_equal 7,   display.instance_variable_get(:@table).column_names.size
    assert       display.instance_variable_get(:@table).column_names.include?(:rate)
  end

  def test_init_array
    table = [ :rate, :connection_rate_per_sec, :errors_total ]
    display = Autoperf::Display.new(@result, table)
    assert_equal Ruport::Data::Table, display.instance_variable_get(:@table).class
    assert_equal 3,   display.instance_variable_get(:@table).column_names.size
    assert       display.instance_variable_get(:@table).column_names.include?(:rate)
  end

  def test_init_table
    table = Table( :column_names => [ :rate, :connection_rate_per_sec, :errors_total, :reply_rate_avg, :reply_status_5xx ] )
    display = Autoperf::Display.new(@result, table)
    assert_equal Ruport::Data::Table, display.instance_variable_get(:@table).class
    assert_equal 5,   display.instance_variable_get(:@table).column_names.size
    assert       display.instance_variable_get(:@table).column_names.include?(:rate)
  end

  def test_init_table_without_rate
    table = Table( :column_names => [ :connection_rate_per_sec, :errors_total, :reply_rate_avg, :reply_status_5xx ] )
    display = Autoperf::Display.new(@result, table)
    assert_equal Ruport::Data::Table, display.instance_variable_get(:@table).class
    assert_equal 4, display.instance_variable_get(:@table).column_names.size
    refute       display.instance_variable_get(:@table).column_names.include?(:rate)
  end

  def test_to_s
    display = Autoperf::Display.new(@result)
    result_string = "+--------------------------------------------------------------------------------------------------------------------------+\n| rate | connection_rate_per_sec | request_rate_per_sec | reply_rate_avg | errors_total | reply_status_5xx | net_io_kb_sec |\n+--------------------------------------------------------------------------------------------------------------------------+\n|  100 |                      10 |                   10 |             10 |            2 |                2 |          1000 |\n+--------------------------------------------------------------------------------------------------------------------------+\n"
    assert_equal result_string, display.to_s
  end

  def test_print
    display = Autoperf::Display.new(@result)
    out, err = capture_io {
      display.print
    }
    assert out.include?("| rate | connection_rate_per_sec | request_rate_per_sec | reply_rate_avg | errors_total | reply_status_5xx | net_io_kb_sec |")
    assert out.include?("|  100 |                      10 |                   10 |             10 |            2 |                2 |          1000 |")
    assert_empty err
  end
end
