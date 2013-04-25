require "./lib/autoperf/display"
require "minitest/autorun"

class TestAutoperfDisplayJSON < MiniTest::Unit::TestCase
  def setup
    @result = {
      100 => {
        :connection_rate_per_sec => 10,
        :request_rate_per_sec    => 10,
        :connection_time_avg     => 10,
        :errors_total            => 2,
        :reply_status_5xx        => 2,
        :net_io_kb_sec           => 1000
      }
    }
  end

  def test_init_default
    display      = Autoperf::Display::JSON.new(@result)
    assert_equal Array, display.instance_variable_get(:@results).class
    assert_equal 7,     display.instance_variable_get(:@results).first.keys.size
  end

  def test_init_array
    fields       = [ :rate, :connection_rate_per_sec, :errors_total ]
    display      = Autoperf::Display::JSON.new(@result, fields)
    assert_equal 3, display.instance_variable_get(:@results).first.keys.size
  end

  def test_to_s
    display       = Autoperf::Display::JSON.new(@result)
    result_string = "[{\"connection_rate_per_sec\":10,\"request_rate_per_sec\":10,\"connection_time_avg\":10,\"errors_total\":2,\"reply_status_5xx\":2,\"net_io_kb_sec\":1000,\"rate\":100}]"
    assert_equal  result_string, display.to_s
  end

  def test_print
    display      = Autoperf::Display::JSON.new(@result)
    out, err     = capture_io { display.print }

    expected_out = %{[
  {
    "connection_rate_per_sec": 10,
    "request_rate_per_sec": 10,
    "connection_time_avg": 10,
    "errors_total": 2,
    "reply_status_5xx": 2,
    "net_io_kb_sec": 1000,
    "rate": 100
  }
]
}
    assert_equal expected_out, out
    assert_empty err
  end
end
