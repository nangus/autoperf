module ReplayLog
  def self.parse input, match='', sub='', type=:nginx
    result = ""
    if input.respond_to?(:each)
      input.each do |line|
        line_result = send("parse_line_#{type}".to_sym, line, match, sub)
        print line_result
        result << line_result
      end
    else
      result = send("parse_line_#{type}".to_sym, input, match, sub)
      print result
    end
    return result
  end

  def self.parse_line_apache line, match='', sub=''
    parse_line(line, match, sub)
  end

  def self.parse_line_nginx line, match='', sub=''
    parse_line(line, match, sub)
  end

  def self.parse_line line, match='', sub=''
    request = line.split('"')[1]
    return if request.nil?

    uri = request.split[1]
    return if uri.nil?

    begin
      uri[match] = sub unless match.empty?
    rescue IndexError
      # simply output line that don't contain the 'replace' string
    ensure
      return uri.chomp + "\0"
    end
  end
end
