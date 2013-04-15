require 'ruport'
class Autoperf
  class Display
    def initialize results, report=nil
      @table = if report.kind_of?(Array)
                 table_from_array(report)
               elsif report.kind_of?(Ruport::Data::Table)
                 report
               else
                 # ignore input and use defaults
                 table_from_array([
                     :rate,
                     :connection_rate_per_sec,
                     :request_rate_per_sec,
                     :connection_time_avg,
                     :errors_total,
                     :reply_status_5xx,
                     :net_io_kb_sec
                   ])
               end
      results.each do |rate, result|
        result.merge!(:rate => rate) if @table.column_names.include?(:rate)
        @table << result
      end
    end

    def to_s
      @table.to_s
    end

    def print
      puts to_s
    end

    def table_from_array report
      Table(:column_names => report)
    end
  end
end

