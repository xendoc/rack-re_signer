require 'base64'
require 'json'
require 'spec_helper'

describe Rack::ReSigner do
  include Rack::Test::Methods

  def rack_app
    -> (env) { [
      200,
      { "Content-Type" => "application/json; charset=utf-8" },
      "{\"basic\": \"#{env['HTTP_AUTHORIZATION'] || ""}\",
\"params\": #{Rack::Request.new(env).params.to_json}}"
    ] }
  end

  it 'has a version number' do
    expect(Rack::ReSigner::VERSION).not_to be nil
  end

  describe "rack application, output authorization header and parameters" do
    let(:app) do
      Rack::ReSigner.new rack_app do
        re_signable_path '/'
        re_signable_client 'id' => 'secret'
      end
    end

    it 'should return 200 OK' do
      get '/'
      expect(last_response.status).to eq 200
    end

    context 'confirm using response body' do
      subject do
        r = JSON.parse(last_response.body)
        r['basic'] =~ /^Basic (.*)/m

        {
          basic: Base64::strict_decode64("#{$1}").split(':', 2)[1],
          param: r['params']['client_secret']
        }
      end

      describe 'get method' do
        it 'should add client_secret on parameter' do
          get '/', { client_id: 'id' }
          expect(subject[:param]).to eq 'secret'
        end

        it 'should add client_secret on authorization header' do
          header 'AUTHORIZATION', "Basic #{Base64::strict_encode64('id')}"
          get '/'
          expect(subject[:basic]).to eq 'secret'
        end
      end

      describe 'post method' do
        it 'should add client_secret on parameter' do
          post '/', { client_id: 'id' }
          expect(subject[:param]).to eq 'secret'
        end

        it 'should add client_secret on authorization header' do
          header 'AUTHORIZATION', "Basic #{Base64::strict_encode64('id')}"
          post '/'
          expect(subject[:basic]).to eq 'secret'
        end
      end

      describe 'not re-signed' do
        let(:secret) { '0123456789' }

        it 'not effected client' do
          get '/', { client_id: 'idid' }
          expect(subject[:param]).to be_nil
        end

        it 'not effected path' do
          get '/not-re-signed', { client_id: 'id' }
          expect(subject[:param]).to be_nil
        end

        it 'client_secret is set on parameter' do
          get '/', { client_id: 'id', client_secret: secret }
          expect(subject[:param]).to eq secret
        end

        it 'client_secret is set on authorization header' do
          header 'AUTHORIZATION', "Basic #{Base64::strict_encode64("id:#{secret}")}"
          get '/'
          expect(subject[:basic]).to eq secret
        end
      end
    end
  end
end
