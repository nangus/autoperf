require 'ruport'
require 'json'
require 'autoperf/display/console'
require 'autoperf/display/csv'
require 'autoperf/display/json'
class Autoperf
  class Display
    DEFAULT_FIELDS = [
      :rate,
      :connection_rate_per_sec,
      :request_rate_per_sec,
      :connection_time_avg,
      :errors_total,
      :reply_status_5xx,
      :net_io_kb_sec
    ]

    # class Console # display/console
    # class CSV     # display/csv
    # class JSON    # display/json
  end
end
