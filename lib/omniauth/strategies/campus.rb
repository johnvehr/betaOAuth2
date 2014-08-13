require 'omniauth-oauth2'
require 'multi_json'
require 'faraday'

module OmniAuth
  module Strategies
    class Campus < OmniAuth::Strategies::OAuth2
      option :params, {username: 'name', password: 'pass'}

      option :client_options, {
        :site => "http://dev-onelessleg.gotpantheon.com",
        :authorize_url => "/oauth2/authorize",
        :token_url => "/oauth2/token"
      }
      attr_accessor :access_token

      uid { raw_info['uid'] }

      info do
        prune!({
        :email => raw_info['mail'],
        :username => raw_info['name']
      })
      end

      extra do
        hash = {}
        hash['raw_info'] = raw_info unless skip_info?
        prune! hash
      end

      #thinking one of these
      #extra do
      #  hash = {}
      #  hash['raw_info'] = raw_info unless skip_info?
      #  prune! hash
      #end
      #or
      #extra do {
      #  :raw_info = raw_info
      #}
      #end

      def request_phase
        '/users/sign_in'
      end

      def callback_phase
        @access_token = client.password.get_token(username, password)
        raw_info
        hash = auth_hash
        hash[:provider] = "campus"
        self.env['omniauth.auth'] = hash
        call_app!
      end

      def raw_info
        @raw_info = MultiJson.decode(@access_token.post("https://dev-onelessleg.gotpantheon.com/oauth2/user/profile").body)
      end

      protected
      def raw_info
        @raw_info = MultiJson.decode(@access_token.post("https://dev-onelessleg.gotpantheon.com/oauth2/user/profile").body)
      end

      def username
        request.params['user']['username']
        #request.env['omniauth.params']['user']['username']
        #request[:user]['username']
      end

      def password
        request.params['user']['password']
        #request.env['omniauth.params']['user']['password']
        #request[:user]['password']
      end

      def prune!(hash)
        hash.delete_if do |_, value|
          prune!(value) if value.is_a?(Hash)
          value.nil? || (value.respond_to?(:empty?) && value.empty?)
        end
      end
    end
  end
end
