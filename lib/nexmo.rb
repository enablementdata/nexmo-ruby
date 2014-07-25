require 'net/http'
require 'json'
require 'cgi'

module Nexmo
  class Client
    def initialize(options = {})
      @key = options.fetch(:key) { ENV.fetch('NEXMO_API_KEY') }

      @secret = options.fetch(:secret) { ENV.fetch('NEXMO_API_SECRET') }

      @host = options.fetch(:host) { 'rest.nexmo.com' }

      @http = Net::HTTP.new(@host, Net::HTTP.https_default_port)

      @http.use_ssl = true
    end

    attr_accessor :key, :secret, :http

    def send_message(params)
      response = post('/sms/json', params)

      item = response['messages'].first

      status = item['status'].to_i

      if status == 0
        item['message-id']
      else
        raise Error, "#{item['error-text']} (status=#{status})"
      end
    end

    def get_balance
      get('/account/get-balance')
    end

    def get_country_pricing(country_code)
      get('/account/get-pricing/outbound', {:country => country_code})
    end

    def get_prefix_pricing(prefix)
      get('/account/get-prefix-pricing/outbound', {:prefix => prefix})
    end

    def get_account_numbers(params)
      get('/account/numbers', params)
    end

    def number_search(country_code, params = {})
      get('/number/search', {:country => country_code}.merge(params))
    end

    def buy_number(params)
      post('/number/buy', params)
    end

    def cancel_number(params)
      post('/number/cancel', params)
    end

    def update_number(params)
      post('/number/update', params)
    end

    def get_message(id)
      get('/search/message', {:id => id})
    end

    def get_message_rejections(params)
      get('/search/rejections', params)
    end

    def search_messages(params)
      get('/search/messages', Hash === params ? params : {:ids => Array(params)})
    end

    private

    def get(path, params = {})
      parse @http.get(request_uri(path, params.merge(:api_key => @key, :api_secret => @secret)))
    end

    def post(path, params)
      parse @http.post(path, JSON.generate(params.merge(:api_key => @key, :api_secret => @secret)), {'Content-Type' => 'application/json'})
    end

    def parse(http_response)
      unless Net::HTTPSuccess === http_response
        raise Error, "Unexpected HTTP response (code=#{http_response.code})"
      end

      if http_response['Content-Type'].split(';').first == 'application/json'
        JSON.parse(http_response.body)
      else
        http_response.body
      end
    end

    def request_uri(path, hash = {})
      if hash.empty?
        path
      else
        query_params = hash.map do |key, values|
          Array(values).map { |value| "#{escape(key)}=#{escape(value)}" }
        end

        path + '?' + query_params.flatten.join('&')
      end
    end

    def escape(component)
      CGI.escape(component.to_s)
    end
  end

  class Error < StandardError
  end
end
