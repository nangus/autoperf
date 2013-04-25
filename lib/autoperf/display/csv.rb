class Autoperf
  class Display
    class CSV
      def initialize results, report=nil
        @table = ::Autoperf::Display::Console.new(results, report).table
      end

      def to_s
        @table.to_csv
      end

      def to_csv
        to_s
      end

      def print
        puts to_s
      end
    end
  end
end
