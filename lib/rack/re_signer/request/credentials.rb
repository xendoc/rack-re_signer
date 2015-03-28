module Rack
  class ReSigner
    module Request
      def self.re_sign!(request, credentials)
        if credentials.method == :from_basic
          bin = Base64::strict_encode64(
            "#{credentials.client_id}:#{credentials.client_secret}"
          )
          request.env["HTTP_AUTHORIZATION"] = "Basic #{bin}"
        else
          request.update_param('client_secret', credentials.client_secret)
        end
      end

      module Methods
        def from_basic(request)
          if request.env.has_key?('HTTP_AUTHORIZATION') &&
          request.env['HTTP_AUTHORIZATION'] =~ /^Basic (.*)/m
            Base64::strict_decode64($1).split(':', 2)
          end
        end

        def from_params(request)
          request.params.values_at('client_id', 'client_secret')
        end
      end

      class Credentials < Struct.new(:client_id, :client_secret, :method)
        extend Methods

        def self.from_request(request)
          Rack::ReSigner::Request::Methods::instance_methods.inject(nil) do |credentials, method|
            client_id, client_secret = *self.method(method).call(request)
            credentials = Credentials.new(client_id, client_secret, method)
            break credentials if credentials.re_signable?
          end
        end

        def re_signable?
          client_id && (client_secret.nil? || client_secret.empty?)
        end
      end
    end
  end
end
