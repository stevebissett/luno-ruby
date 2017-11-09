require "minitest/pride"
require "minitest/autorun"
require_relative "../lib/luno.rb"

  module SendStubs
    def self.conn
      stubs = Faraday::Adapter::Test::Stubs.new do |stub|
        success_body = JSON.dump(success: true)
        stub.post('/api/1/send') {[ 200, {}, success_body]}
      end

      Faraday.new { |faraday| faraday.adapter :test, stubs }
    end
  end

  class TestSend < Minitest::Test
    def setup_module
      Luno.set_conn(SendStubs.conn)
    end

    def setup_connection
      Luno::Connection.new(SendStubs.conn)
    end

    def test_send
      #Luno.send(amount, address, currency='XBT', description='', message='', pin=nil)
      setup_module
      response_body = Luno.send(1, 'mockaddress')
      assert_equal response_body[:success], true
    end

    def test_connection_send
      response_body = setup_connection.send(1, 'mockaddress')
      assert_equal response_body[:success], true
    end
  end
