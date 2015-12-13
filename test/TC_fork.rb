$:.unshift File.dirname(__FILE__)
$:.unshift File.join(File.dirname(__FILE__), "..")
$topdir = File.expand_path File.dirname(__FILE__)
require "baseclient"
require "shogi_server/buoy.rb"

class TestFork < BaseClient
  def parse_game_name(player)
    player.puts "%%LIST"
    sleep 1
    if /##\[LIST\] (.*)/ =~ player.message
      return $1
    end
  end

  def test_wrong_game
    @admin = SocketPlayer.new "dummy", "admin", false
    @admin.connect
    sleep 0.1
    @admin.reader
    sleep 0.1
    @admin.login
    sleep 0.1

    result, result2 = handshake do
      @admin.puts "%%FORK wronggame-900-0 buoy_WrongGame-900-0"
      sleep 1
    end

    assert /##\[ERROR\] wrong source game name/ =~ @admin.message
    @admin.logout
  end

  def test_too_short_fork
    @admin = SocketPlayer.new "dummy", "admin", false
    @admin.connect
    sleep 0.1
    @admin.reader
    sleep 0.1
    @admin.login
    sleep 0.1

    result, result2 = handshake do
      source_game = parse_game_name(@admin)
      @admin.puts "%%FORK #{source_game} buoy_TooShortFork-900-0 0"
      sleep 1
    end

    assert /##\[ERROR\] number of moves to fork is out of range/ =~ @admin.message
    @admin.logout
  end

  def test_fork
    buoy = ShogiServer::Buoy.new
    
    @admin = SocketPlayer.new "dummy", "admin", "*"
    @admin.connect
    sleep 0.1
    @admin.reader
    sleep 0.1
    @admin.login
    sleep 0.1

    assert buoy.is_new_game?("buoy_Fork-1500-0")

    result, result2 = handshake do
      source_game = parse_game_name(@admin)
      @admin.puts "%%FORK #{source_game} buoy_Fork-1500-0"
      sleep 1
    end

    assert buoy.is_new_game?("buoy_Fork-1500-0")
    @p1 = SocketPlayer.new "buoy_Fork", "p1", true
    @p2 = SocketPlayer.new "buoy_Fork", "p2", false
    @p1.connect
    sleep 0.1
    @p2.connect
    sleep 0.1
    @p1.reader
    sleep 0.1
    @p2.reader
    sleep 0.1
    @p1.login
    sleep 0.1
    @p2.login
    sleep 0.1
    @p1.game
    sleep 0.1
    @p2.game
    @p1.agree
    sleep 0.1
    @p2.agree
    sleep 0.1
    assert /^Total_Time:1500/ =~ @p1.message
    assert /^Total_Time:1500/ =~ @p2.message
    @p2.move("-3334FU")
    sleep 0.1
    @p1.toryo
    sleep 0.1
    @p2.logout
    sleep 0.1
    @p1.logout
    sleep 0.1

    @admin.logout
  end

  def test_fork2
    buoy = ShogiServer::Buoy.new
    
    @admin = SocketPlayer.new "dummy", "admin", "*"
    @admin.connect
    sleep 0.1
    @admin.reader
    sleep 0.1
    @admin.login
    sleep 0.1

    result, result2 = handshake do
      source_game = parse_game_name(@admin)
      sleep 0.2
      @admin.puts "%%FORK #{source_game}" # nil for new_buoy_game name
      sleep 1.2
      assert /##\[FORK\]: new buoy game name: buoy_TestFork_1-1500-0/ =~ @admin.message
    end

    assert buoy.is_new_game?("buoy_TestFork_1-1500-0")
    @p1 = SocketPlayer.new "buoy_TestFork_1", "p1", true
    @p2 = SocketPlayer.new "buoy_TestFork_1", "p2", false
    @p1.connect
    sleep 0.1
    @p2.connect
    sleep 0.1
    @p1.reader
    sleep 0.1
    @p2.reader
    sleep 0.1
    @p1.login
    sleep 0.1
    @p2.login
    sleep 0.1
    @p1.game
    sleep 0.1
    @p2.game
    sleep 0.1
    @p1.agree
    sleep 0.1
    @p2.agree
    sleep 0.1
    assert /^Total_Time:1500/ =~ @p1.message
    assert /^Total_Time:1500/ =~ @p2.message
    @p2.move("-3334FU")
    sleep 0.1
    @p1.toryo
    sleep 0.1
    @p2.logout
    sleep 0.1
    @p1.logout
    sleep 0.1

    @admin.logout
  end
end
