require 'minitest/pride'
require 'minitest/autorun'
require_relative '../lib/luno.rb'

module ReceiveAddressStubs
  def self.conn
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|

      funding_address_body_1 = JSON.dump({
                                           asset: 'XBT',
                                           address: 'supersecretotherbicoinwallet',
                                           total_received: '929.23001',
                                           total_unconfirmed: '0.30'
                                         })

      funding_address_body_2 = JSON.dump({
                                           asset: 'XBT',
                                           address: 'B1tC0InExAMPL3fundIN6AdDreS5t0Use1',
                                           total_received: '1.234567',
                                           total_unconfirmed: '0.00'
                                         })

      funding_address_body_3 = JSON.dump({
                                           asset: 'XBT',
                                           address: 'B1tC0InExAMPL3fundIN6AdDreS5t0Use2',
                                           total_received: '0.00',
                                           total_unconfirmed: '0.00'
                                         })

      stub.get('/api/1/funding_address?address=supersecretotherbicoinwallet&asset=XBT') { [200, {}, funding_address_body_1] }
      stub.get('/api/1/funding_address?asset=XBT') { [200, {}, funding_address_body_2] }
      stub.post('/api/1/funding_address') { [200, {}, funding_address_body_3] }

    end

    Faraday.new { |faraday| faraday.adapter :test, stubs }
  end
end

class TestReceiveAddress < Minitest::Test

  def setup_module
    Luno.set_conn(ReceiveAddressStubs.conn)
  end

  def setup_connection
    Luno::Connection.new(ReceiveAddressStubs.conn)
  end

  def test_get_receive_address
    setup_module
    response_body = Luno.received_by_address
    assert_equal response_body[:total_received], '1.234567'
    assert_equal response_body[:total_unconfirmed], '0.00'
    assert_equal response_body[:address], 'B1tC0InExAMPL3fundIN6AdDreS5t0Use1'
    assert_equal response_body[:asset], 'XBT'
  end

  def test_connection_get_receive_address
    response_body = setup_connection.received_by_address
    assert_equal response_body[:total_received], '1.234567'
    assert_equal response_body[:total_unconfirmed], '0.00'
    assert_equal response_body[:address], 'B1tC0InExAMPL3fundIN6AdDreS5t0Use1'
    assert_equal response_body[:asset], 'XBT'
  end

  def test_new_receive_address
    setup_module
    response_body = Luno.new_receive_address
    assert_equal response_body[:total_received], '0.00'
    assert_equal response_body[:total_unconfirmed], '0.00'
    assert_equal response_body[:address], 'B1tC0InExAMPL3fundIN6AdDreS5t0Use2'
    assert_equal response_body[:asset], 'XBT'
  end

  def test_connection_new_receive_address
    response_body = setup_connection.new_receive_address
    assert_equal response_body[:total_received], '0.00'
    assert_equal response_body[:total_unconfirmed], '0.00'
    assert_equal response_body[:address], 'B1tC0InExAMPL3fundIN6AdDreS5t0Use2'
    assert_equal response_body[:asset], 'XBT'
  end

  def test_specify_address
    setup_module
    response_body = Luno.received_by_address('supersecretotherbicoinwallet')
    assert_equal response_body[:total_received], '929.23001'
    assert_equal response_body[:total_unconfirmed], '0.30'
    assert_equal response_body[:address], 'supersecretotherbicoinwallet'
    assert_equal response_body[:asset], 'XBT'
  end

  def test_connection_specify_address
    response_body = setup_connection.received_by_address({address: 'supersecretotherbicoinwallet'})
    assert_equal response_body[:total_received], '929.23001'
    assert_equal response_body[:total_unconfirmed], '0.30'
    assert_equal response_body[:address], 'supersecretotherbicoinwallet'
    assert_equal response_body[:asset], 'XBT'
  end
end
