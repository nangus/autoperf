class Autoperf
  class Display
    class JSON
      def initialize(results, fields=nil)
        @results = []
        fields ||= ::Autoperf::Display::DEFAULT_FIELDS
        results.each do |rate, result|
          result.keep_if { |k,v| fields.include?(k) }
          result.merge!(:rate => rate) if fields.include?(:rate)
          @results.push(result)
        end
      end

      def to_s
        to_json
      end

      def to_json
        @results.to_json
      end

      def print
        puts ::JSON.pretty_generate(@results)
      end
    end
  end
end
