require "minitest/autorun"
require "stringio"
require "./lib/replay_log"

class TestReplayLog < MiniTest::Unit::TestCase
  def setup
    @line  = ' [ FOO ] BAR " GET /foo/bar/bah HTTP/1 " other stuff'
    @file1 = File.open('./test/nginx1.txt', 'r')
    @file2 = File.open('./test/nginx2.txt', 'r')

    # redirect STDOUT
    @newout = StringIO.new
    @oldout = $stdout
    $stdout = @newout
  end

  def teardown
    $stdout = @oldout
  end

  def test_parse_line
    assert_equal "/foo/bar/bah\x00", ReplayLog.parse_line(@line), "with defaults"
    assert_equal "/boo/bar/bah\x00", ReplayLog.parse_line(@line, 'foo', 'boo'), "with match and sub"
  end

  def test_parse_line_nginx
    assert_equal "/foo/bar/bah\x00", ReplayLog.parse_line_nginx(@line), "with defaults"
    assert_equal "/boo/bar/bah\x00", ReplayLog.parse_line_nginx(@line, 'foo', 'boo'), "with match and sub"
  end

  def test_parse_line_apache
    # using nginx formats because that match close enough for testing
    assert_equal "/foo/bar/bah\x00", ReplayLog.parse_line_apache(@line), "with defaults"
    assert_equal "/boo/bar/bah\x00", ReplayLog.parse_line_apache(@line, 'foo', 'boo'), "with match and sub"
  end

  def test_parse
    assert_equal "/foo/bar/bah\x00", ReplayLog.parse(@line), "with defaults"
    assert_equal "/boo/bar/bah\x00", ReplayLog.parse(@line, 'foo', 'boo', :nginx), "nginx with match and sub"
    assert_equal "/boo/bar/bah\x00", ReplayLog.parse(@line, 'foo', 'boo', :apache), "apache with match and sub"
    assert_raises(NoMethodError) {
      ReplayLog.parse(@line, 'foo', 'boo', :badformat)
    }
  end

  def test_with_file
    assert_equal "/\x00"*100,    ReplayLog.parse(@file1), "with defaults"
    assert_equal "/foo\x00"*100, ReplayLog.parse(@file2, 'app', 'foo'), "with match and sub"
  end

  def test_parse_apache
    assert_equal "/\x00"*100,    ReplayLog.parse(@file1, '', '', :apache)
  end

  def test_parse_nginx
    assert_equal "/\x00"*100,    ReplayLog.parse(@file1, '', '', :nginx)
  end
end
