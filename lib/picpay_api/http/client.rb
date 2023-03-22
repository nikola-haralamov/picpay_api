# typed: strict
# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

module PicPayApi
  module HTTP
    class Client
      class << self

        extend T::Sig

        sig do
          params(
            uri:           URI::Generic,
            payload:       T.nilable(T::Hash[Symbol, T.untyped]),
            authorization: T.nilable(PicPayApi::Entities::Authorization),
            logger: T.untyped
          ).returns(T::Hash[Symbol, T.untyped])
        end
        def get(uri:, payload: nil, authorization: nil, logger: nil)
          request!(
            uri: uri,
            request: Net::HTTP::Get.new(uri),
            payload: payload,
            authorization: authorization,
            logger: logger
          )
        end

        sig do
          params(
            uri:           URI::Generic,
            payload:       T.nilable(T::Hash[Symbol, T.untyped]),
            authorization: T.nilable(PicPayApi::Entities::Authorization),
            logger: T.untyped
          ).returns(T::Hash[Symbol, T.untyped])
        end
        def post(uri:, payload: nil, authorization: nil, logger: nil)
          request!(
            uri: uri,
            request: Net::HTTP::Post.new(uri),
            payload: payload,
            authorization: authorization,
            logger: logger
          )
        end

        sig do
          params(
            uri:           URI::Generic,
            payload:       T::Hash[Symbol, T.untyped],
            authorization: T.nilable(PicPayApi::Entities::Authorization),
            logger: T.untyped
          ).returns(T::Hash[Symbol, T.untyped])
        end
        def put(uri:, payload:, authorization: nil, logger: nil)
          request!(
            uri: uri,
            request: Net::HTTP::Put.new(uri),
            payload: payload,
            authorization: authorization,
            logger: logger
          )
        end

        private

        sig do
          params(
            uri:           URI::Generic,
            request:       Net::HTTPGenericRequest,
            payload:       T.nilable(T::Hash[Symbol, T.untyped]),
            authorization: T.nilable(PicPayApi::Entities::Authorization),
            logger: T.untyped
          ).returns(T::Hash[Symbol, T.untyped])
        end
        def request!(uri:, request:, payload: nil, authorization: nil, logger: nil)
          http = Net::HTTP.new(uri.hostname, uri.port)
          http.use_ssl = true
          http.set_debug_output(logger) if logger

          request.body             = payload.to_json unless payload.nil?
          request['accept']        = 'application/json'
          request['content-type']  = 'application/json'
          request['authorization'] = authorization.to_s unless authorization.nil?

          response = http.request(request)

          response.value

          T.let(JSON.parse(response.body, symbolize_names: true), T::Hash[Symbol, T.untyped])
        end
      end
    end
  end
end
