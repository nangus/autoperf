require "./lib/autoperf/display"
require "minitest/autorun"

class TestAutoperfDisplayConsole < MiniTest::Unit::TestCase
  def setup
    @result = {
      100 => {
        :connection_rate_per_sec => 10,
        :request_rate_per_sec    => 10,
        :connection_time_avg     => 10,
        :errors_total            => 2,
        :reply_status_5xx        => 2,
        :net_io_kb_sec           => 1000,
        :never_used              => 999
      }
    }
  end

  def test_init_default
    display = Autoperf::Display::Console.new(@result)
    assert_equal 7,   display.instance_variable_get(:@table).column_names.size
    assert       display.instance_variable_get(:@table).column_names.include?(:rate)
  end

  def test_table
    display = Autoperf::Display::Console.new(@result)
    assert_equal Ruport::Data::Table, display.table.class
  end

  def test_init_array
    table = [ :rate, :connection_rate_per_sec, :errors_total ]
    display = Autoperf::Display::Console.new(@result, table)
    assert_equal 3,   display.instance_variable_get(:@table).column_names.size
    assert       display.instance_variable_get(:@table).column_names.include?(:rate)
  end

  def test_init_table
    table = Table( :column_names => [ :rate, :connection_rate_per_sec, :errors_total, :connection_time_avg, :reply_status_5xx ] )
    display = Autoperf::Display::Console.new(@result, table)
    assert_equal 5,   display.instance_variable_get(:@table).column_names.size
    assert       display.instance_variable_get(:@table).column_names.include?(:rate)
  end

  def test_init_table_without_rate
    table = Table( :column_names => [ :connection_rate_per_sec, :errors_total, :connection_time_avg, :reply_status_5xx ] )
    display = Autoperf::Display::Console.new(@result, table)
    assert_equal 4, display.instance_variable_get(:@table).column_names.size
    refute       display.instance_variable_get(:@table).column_names.include?(:rate)
  end

  def test_to_s
    display = Autoperf::Display::Console.new(@result)
    assert display.to_s.include?("| rate |")
    assert display.to_s.include?("|  100 |")
  end

  def test_print
    display = Autoperf::Display::Console.new(@result)
    out, err = capture_io { display.print }
    assert out.include?("| rate |")
    assert out.include?("|  100 |")
    assert_empty err
  end
end
