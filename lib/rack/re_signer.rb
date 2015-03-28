require 'base64'
require "rack/re_signer/request"
require "rack/re_signer/version"

module Rack
  class ReSigner
    def initialize(app, &block)
      @app = app
      instance_eval(&block) if block_given?
    end

    def call(env)
      return @app.call(env) unless @re_signable_paths.include?(env['PATH_INFO'])

      request = Rack::Request.new(env)
      re_signable_credentials = Rack::ReSigner::Request::Credentials.from_request(request)
      if re_signable_credentials && @re_signable_clients.has_key?(re_signable_credentials.client_id)
        request.env["X_HTTP_AUTHORIZATION_RE_SIGNER"] = "#{re_signable_credentials.method}"
        re_signable_credentials.client_secret = @re_signable_clients[re_signable_credentials.client_id]
        Rack::ReSigner::Request::re_sign! request, re_signable_credentials
      end
      @app.call(env)
    end

    private

    def re_signable_path(*path)
      @re_signable_paths ||= []
      @re_signable_paths.push(path).flatten!.uniq!
    end

    def re_signable_client(client)
      @re_signable_clients ||= { }
      @re_signable_clients.merge! client
    end
  end
end
