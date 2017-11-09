require "minitest/pride"
require "minitest/autorun"
require_relative "../lib/luno.rb"

module OrderStubs
  def self.conn
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|

      get_orders_response_body = JSON.dump(
        {
          orders: [
            {
              fee_counter: '0.00',
              order_id: 'BXMC2CJ7HNB88U4',
              creation_timestamp: 1367849297609,
              counter: '0.00',
              limit_volume: '0.80',
              limit_price: '1000.00',
              state: 'PENDING',
              base: '0.00',
              fee_base: '0.00',
              type: 'ASK',
              expiration_timestamp: 1367935697609
            }
          ]
        })

      get_order_response_body = JSON.dump(
        {
          order_id: "BXHW6PFRRXKFSB4",
          creation_timestamp: 1402866878367,
          expiration_timestamp: 0,
          type: "ASK",
          state: "PENDING",
          limit_price: "6500.00",
          limit_volume: "0.05",
          base: "0.03",
          counter: "195.02",
          fee_base: "0.000",
          fee_counter: "0.00",
          trades:
            [
              {price: "6501.00", timestamp: 1402866878467, volume: "0.02"},
              {price: "6500.00", timestamp: 1402866878567, volume: "0.01"}
            ]
        }
      )

      post_orders_response_body = JSON.dump(order_id: 'BXRANDOMORDERID23')
      post_stoporder_response_body = JSON.dump(success: true)

      stub.get('/api/1/listorders?pair=XBTZAR') { [200, {}, get_orders_response_body] }
      stub.post('/api/1/postorder', {pair: 'XBTZAR', type: 'BID', volume: '0.1', price: '1000'}) { [200, {}, post_orders_response_body] }
      stub.get('/api/1/orders/BXHW6PFRRXKFSB4') { [200, {}, get_order_response_body] }
      stub.post('/api/1/stoporder', {order_id: 'BXMC2CJ7HNB88U4'}) { [200, {}, post_stoporder_response_body] }
    end

    Faraday.new { |faraday| faraday.adapter :test, stubs }
  end
end

class TestOrders < Minitest::Test

  def setup_module
    Luno.set_conn(OrderStubs.conn)
  end

  def setup_connection
    Luno::Connection.new(OrderStubs.conn)
  end

  def test_connection_list
    response_body = setup_connection.list_orders('XBTZAR')
    assert_equal response_body.size, 1
  end

  def test_list
    setup_module
    response_body = Luno.list_orders('XBTZAR')
    assert_equal response_body.size, 1
  end

  def test_connection_post_order
    response_body = setup_connection.post_order('BID', 0.1, 1000, 'XBTZAR')
    assert_equal response_body[:order_id], 'BXRANDOMORDERID23'
  end

  def test_post_order
    setup_module
    response_body = Luno.post_order('BID', 0.1, 1000, 'XBTZAR')
    assert_equal response_body[:order_id], 'BXRANDOMORDERID23'
  end

  def test_connection_get_order
    response_body = setup_connection.get_order('BXHW6PFRRXKFSB4')
    assert_equal response_body[:order_id], 'BXHW6PFRRXKFSB4'
    assert_equal response_body[:trades].length, 2
  end

  def test_get_order
    setup_module
    response_body = Luno.get_order('BXHW6PFRRXKFSB4')
    assert_equal response_body[:order_id], 'BXHW6PFRRXKFSB4'
  end

  def test_connection_stop_order
    response_body = setup_connection.stop_order('BXMC2CJ7HNB88U4')
    assert_equal response_body[:success], true
  end

  def test_stop_order
    setup_module
    response_body = Luno.stop_order('BXMC2CJ7HNB88U4')
    assert_equal response_body[:success], true
  end

end
