require 'rubygems'
require 'yaml'
require 'httperf'
require 'json'
require './lib/autoperf/display'

class Autoperf
  def initialize(config_file, opts = {})
    @conf = parse_config(config_file).merge(opts)
    @perf = HTTPerf.new(@conf)
    @perf.parse = true
  end

  def parse_config(config_file)
    raise Errno::EACCES, "#{config_file} is not readable" unless File.readable?(config_file)
    config = YAML::load(File.open(config_file, 'r'))
    @rates = {
      :low_rate  => config.delete('low_rate'),
      :high_rate => config.delete('high_rate'),
      :rate_step => config.delete('rate_step')
    }
    @cols  = config.delete('display_columns') if config.has_key?('display_columns')
    @tee   = config.delete('tee')||false
    return config
  end

  def run report=nil
    @results = {}
    (@rates[:low_rate].to_i..@rates[:high_rate].to_i).step(@rates[:rate_step].to_i) do |rate|
      @perf.update_option("num-conns", rate.to_s)
      @results[rate] = @perf.run
    end
    return @results
  end

  def display
    @results ||= {}
    if @cols
      Autoperf::Display.new(@results, @cols)
    else
      Autoperf::Display.new(@results)
    end
  end

  def to_s
    display.to_s
  end

  def to_json
    @results ||= {}
    @results.to_json
  end
end
