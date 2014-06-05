require 'rubygems'
require 'yaml'
require 'httperf'
require 'json'
require 'autoperf/display'

class Autoperf
  def initialize(config_file, opts = {})
    @conf       = parse_config(config_file).merge(opts)
    @perf       = HTTPerf.new(@conf, @path)
    @perf.parse = true
    @perf.tee   = true if @tee
  end

  def parse_config(config_file)
    raise Errno::EACCES, "#{config_file} is not readable" unless File.readable?(config_file)
    config = YAML::load(File.open(config_file, 'r'))
    if config.has_key?('logRefs') 
        @logDir     = config.delete('logDir').to_s
        @logRefs    = config.delete('logRefs')
        @durr       = config.delete('durr')
        puts "test\n"
        @logRefs.each do |k,v|
            puts k.to_s  + " " + v.to_s
        end
    end

    @rates  = {
      :low_rate  => config.delete('low_rate'),
      :high_rate => config.delete('high_rate'),
      :rate_step => config.delete('rate_step')
    }

    @cols   = config.delete('display_columns')        if config.has_key?('display_columns')
    @tee    = config.delete('tee')||false
    @format = config.delete('display_format').to_sym  if config.has_key?('display_format')
    @path   = config.delete('httperf_path')||nil

    return config
  end

  def run
    @results = {}
    (@rates[:low_rate].to_i..@rates[:high_rate].to_i).step(@rates[:rate_step].to_i) do |rate|
        if @logRefs 
            magicArray={};
            @logRefs.each do |k,v|
                pid = fork do
                    numConns=@durr.to_f * v.to_f
                    @perf.update_option("wsesslog", numConns.to_i.to_s+",0,"+@logDir+k.to_s+".log")
                    @perf.update_option("rate",(rate.to_f * v.to_f).to_s)
                    magicArray[k]=@perf.run
                end
            end
            Process.wait
            @results[rate]=magicArray
        else
            @perf.update_option("rate", rate.to_s)
            @results[rate] = @perf.run
        end 
    end
    return @results
  end

  def display(type=@format)
    @results ||= {}
    @cols    ||= nil
    case type
    when :csv
      Autoperf::Display::CSV.new(@results, @cols)
    when :json
      Autoperf::Display::JSON.new(@results, @cols)
    else
      Autoperf::Display::Console.new(@results, @cols)
    end
  end

  def to_s
    display(:console).to_s
  end

  def to_csv
    display(:csv).to_csv
  end

  def to_json
    display(:json).to_json
  end
end
