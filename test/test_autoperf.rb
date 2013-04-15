require "minitest/autorun"
require "./lib/autoperf"

class TestAutoperf < MiniTest::Unit::TestCase
  def setup
    @config_file = "./test/test.yml"
  end

  def test_initialize_from_file
    assert_equal "www.rubyops.net",
      Autoperf.new(@config_file).instance_variable_get(:@conf)['server'],
      "configuration from file"
  end

  def test_initialize_with_overide
    assert_equal "www.example.com",
      Autoperf.new(@config_file, { "server" => "www.example.com" }).instance_variable_get(:@conf)['server'],
      "configuration with overide"
  end

  def test_initialize_rates
    assert_equal 5,  Autoperf.new(@config_file).instance_variable_get(:@rates)[:low_rate],  "low_rate"
    assert_equal 20, Autoperf.new(@config_file).instance_variable_get(:@rates)[:high_rate], "high_rate"
    assert_equal 5,  Autoperf.new(@config_file).instance_variable_get(:@rates)[:rate_step], "rate_step"
  end

  def test_initialize_clean_config
    refute Autoperf.new(@config_file).instance_variable_get(:@conf)['low_rate'],  "low_rate"
    refute Autoperf.new(@config_file).instance_variable_get(:@conf)['high_rate'], "high_rate"
    refute Autoperf.new(@config_file).instance_variable_get(:@conf)['rate_step'], "rate_step"

    refute Autoperf.new(@config_file).instance_variable_get(:@conf)['display_columns'], "display_columns"

    refute Autoperf.new(@config_file, { "tee" => true }).instance_variable_get(:@conf)['tee'], "tee"
  end

  def test_initialize_httperf
    assert_kind_of HTTPerf, Autoperf.new(@config_file).instance_variable_get(:@perf)
  end

  def test_initialize_cols
    assert_kind_of Array,  Autoperf.new(@config_file).instance_variable_get(:@cols)
    assert_kind_of Symbol, Autoperf.new(@config_file).instance_variable_get(:@cols).first
  end

  def test_bad_configuration
    assert_raises(Errno::EACCES) { Autoperf.new("/this/does/not/exist.yml") }
  end

  def test_to_json
    autoperf = Autoperf.new(@config_file)
    assert_equal "{}", autoperf.to_json

    autoperf.instance_variable_set(:@results, { "foo" => "bar" })
    assert_equal '{"foo":"bar"}', autoperf.to_json
  end
end
