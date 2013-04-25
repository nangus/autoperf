class Autoperf::Display
  class Console
    def initialize results, report=nil
      @table = if report.kind_of?(Array)
                 table_from_array(report)
               elsif report.kind_of?(Ruport::Data::Table)
                 report
               else
                 # ignore input and use defaults
                 table_from_array(::Autoperf::Display::DEFAULT_FIELDS)
               end
      results.each do |rate, result|
        result.merge!(:rate => rate) if @table.column_names.include?(:rate)
        @table << result
      end
      @table
    end

    def table
      @table
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
