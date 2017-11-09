module PublicApi

  def ticker(pair)
    ticker = self.get('/api/1/ticker', {pair: pair})
    {
      pair: pair,
      timestamp: time(ticker['timestamp']),
      ask: BigDecimal(ticker['ask']),
      bid: BigDecimal(ticker['bid']),
      last: BigDecimal(ticker['last_trade']),
      volume: BigDecimal(ticker['rolling_24_hour_volume'])
    }
  end

  def tickers
    self.get('/api/1/tickers')['tickers'].map do |ticker|
      {
        pair: ticker['pair'],
        timestamp: time(ticker['timestamp']),
        ask: BigDecimal(ticker['ask']),
        bid: BigDecimal(ticker['bid']),
        last: BigDecimal(ticker['last_trade']),
        volume: BigDecimal(ticker['rolling_24_hour_volume'])
      }
    end
  end

  def orderbook(pair)
    response = self.get('/api/1/orderbook', {pair: pair})
    bids = response['bids'].map do |order|
      {
        price: BigDecimal(order['price']),
        volume: BigDecimal(order['volume'])
      }
    end

    asks = response['asks'].map do |order|
      {
        price: BigDecimal(order['price']),
        volume: BigDecimal(order['volume'])
      }
    end

    {bids: bids, asks: asks, timestamp: time(response['timestamp'])}
  end

  def trades(pair)
    response = self.get('/api/1/trades', {pair: pair})
    response['trades'].map do |trade|
      {
        timestamp: time(trade['timestamp']),
        price: BigDecimal(trade['price']),
        volume: BigDecimal(trade['volume'])
      }
    end
  end

  def get(url, params=nil)
    response = self.conn.get(url, params)
    response_body = Oj.load(response.body, mode: :compat)
    raise ::BitX::Error.new("BitX error: #{response.status}") if response.status != 200
    raise ::BitX::Error.new("BitX error: #{response_body['error']}") if response_body['error']
    response_body
  end

  private

  def time(epoch_time)
    Time.at(epoch_time.to_i/1000)
  end

end
