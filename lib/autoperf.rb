require 'rubygems'
require 'ruport'
require 'yaml'
require 'httperf'

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
    @tee   = config.delete('tee')||false
    return config
  end

  def run report=nil
    results = {}
    report = Table(
      :column_names => [
        :rate,
        :connection_rate_per_sec,
        :request_rate_per_sec,
        :reply_rate_avg,
        :errors_total,
        :reply_status_5xx,
        :net_io_kb_sec
      ]
    ) unless report.kind_of?(Ruport::Data::Table)

    (@rates[:low_rate].to_i..@rates[:high_rate].to_i).step(@rates[:rate_step].to_i) do |rate|
      @perf.update_option("num-conns", rate.to_s)
      results[rate] = @perf.run
      report << results[rate].merge(:rate => rate)
    end

    puts report.to_s

    return results
  end
end
