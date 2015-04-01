# Rack::ReSigner

[![Circle CI](https://circleci.com/gh/xendoc/rack-re_signer.svg?style=svg)](https://circleci.com/gh/xendoc/rack-re_signer)
[![Code Climate](https://codeclimate.com/github/xendoc/omniauth-miil/badges/gpa.svg)](https://codeclimate.com/github/xendoc/rack-re_signer)

Rack::ReSigner is `client_secret` re-sign proxy.
`client_secret` parameter will be automatically added for OAuth2 ResourceOwnerPasswordCredential and RefreshToken.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rack-re_signer', github: 'xendoc/rack-re_signer'
```

And then execute:

```sh
$ bundle install
```

## Usage

Rack::ReSigner add `client_secret` to Request.

### For Rackup files

```ruby
use Rack::ReSigner do
  re_signable_path '/oauth/token'
  re_signable_client 'client_id' => 'client_secret'
end
```

### For Rails apps

In config/application.rb
```ruby
config.middleware.use Rack::ReSigner do
  re_signable_path '/oauth/token'
  re_signable_client 'client_id' => 'client_secret'
end
```

### re_signalbe_path

Request to the passed paths in arguments(Array) will be affected.

e.g.
```ruby
  re_signable_path '/', '/foo'
  re_signable_client 'bar' => 'baz'
```

affect

* GET /?client_id=bar
* GET /foo?client_id=bar

not affected

* GET /qux?client_id=bar

### re_signable_client

Clients passed in arguments(Hash) is affected. However, it will not be affected if it contains `client_secret` in a request.

e.g.
```ruby
  re_signable_path '/'
  re_signable_client 'foo' => 'bar', 'baz' => 'qux'
```

affect

* GET /?client_id=foo
* GET /?client_id=baz

not affected

* GET /?client_id=foobar
* GET /?client_id=foo&client_secret=12345

### Authorization Header

`password` is not required.

before:
```
Authorization: "Basic #{Base64::strict_encode64 'client_id'}"
```

after:
```
Authorization: "Basic #{Base64::strict_encode64 'client_id:client_secret'}"
```

### License

Rack ReSigner is available under the MIT license.
