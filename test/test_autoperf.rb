require "minitest/autorun"
require "stringio"
require "./lib/autoperf"

class TestReplayLog < MiniTest::Unit::TestCase
  def setup
    @config_file = "./config/sample.yml"

    # redirect STDOUT
    @newout = StringIO.new
    @oldout = $stdout
    $stdout = @newout
  end

  def teardown
    $stdout = @oldout
  end

  def test_initialize_from_file
    assert_equal "localhost",
      Autoperf.new(@config_file).instance_variable_get(:@conf)['server'],
      "configuration from file"
  end

  def test_initialize_with_overide
    assert_equal "www.example.com",
      Autoperf.new(@config_file, { "server" => "www.example.com" }).instance_variable_get(:@conf)['server'],
      "configuration with overide"
  end

  def test_initialize_rates
    assert_equal 100, Autoperf.new(@config_file).instance_variable_get(:@rates)[:low_rate],  "low_rate"
    assert_equal 500, Autoperf.new(@config_file).instance_variable_get(:@rates)[:high_rate], "high_rate"
    assert_equal 50,  Autoperf.new(@config_file).instance_variable_get(:@rates)[:rate_step], "rate_step"
  end

  def test_initialize_clean_config
    refute Autoperf.new(@config_file).instance_variable_get(:@conf)['low_rate'],  "low_rate"
    refute Autoperf.new(@config_file).instance_variable_get(:@conf)['high_rate'], "high_rate"
    refute Autoperf.new(@config_file).instance_variable_get(:@conf)['rate_step'], "rate_step"
    refute Autoperf.new(@config_file, { "tee" => true }).instance_variable_get(:@conf)['tee'], "tee"
  end

  def test_initialize_httperf
    assert_kind_of HTTPerf, Autoperf.new(@config_file).instance_variable_get(:@perf)
  end

  def test_bad_configuration
    assert_raises(Errno::EACCES) { Autoperf.new("/this/does/not/exist.yml") }
  end
end
