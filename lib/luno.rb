require 'faraday'
require 'json'
require 'bigdecimal'
require 'bigdecimal/util'
require_relative 'public_api'
require_relative 'private_api'
require_relative 'version'

module Luno
  class Configuration
    attr_accessor :api_key_id, :api_key_secret, :api_key_pin
  end

  def self.configuration
    @configuration ||=  Configuration.new
  end

  def self.configure
    yield(configuration) if block_given?
  end

  class Error < StandardError
  end

  extend PublicApi
  extend PrivateApi

  def self.set_conn(conn=nil)
    @conn = conn || Luno.conn
  end

  def self.conn
    return @conn if @conn
    @conn = Faraday.new(url: 'https://api.mybitx.com')
    @conn.headers[:user_agent] = "luno-ruby/#{Luno::VERSION::STRING}"
    @conn
  end

  #connection object to be used in concurrent systems where connections and configurations might differ
  class Connection
    include PublicApi
    include PrivateApi
    attr_accessor :configuration, :conn

    def initialize(connection=nil)
      @conn = connection || Luno.conn
      @configuration = Luno.configuration
      yield(@configuration) if block_given?
    end

    def self.conn
      @conn
    end

    def self.get(url, params=nil)
      get(url, params)
    end

    def self.configuration
      @configuration
    end
  end
end
