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
            logger: T.untyped,
            timeout: T.nilable(Integer)
          ).returns(T::Hash[Symbol, T.untyped])
        end
        def get(uri:, payload: nil, authorization: nil, logger: nil, timeout: nil)
          request!(
            uri: uri,
            request: Net::HTTP::Get.new(uri),
            payload: payload,
            authorization: authorization,
            logger: logger,
            timeout: timeout
          )
        end

        sig do
          params(
            uri:           URI::Generic,
            payload:       T.nilable(T::Hash[Symbol, T.untyped]),
            authorization: T.nilable(PicPayApi::Entities::Authorization),
            logger: T.untyped,
            timeout: T.nilable(Integer)
          ).returns(T::Hash[Symbol, T.untyped])
        end
        def post(uri:, payload: nil, authorization: nil, logger: nil, timeout: nil)
          request!(
            uri: uri,
            request: Net::HTTP::Post.new(uri),
            payload: payload,
            authorization: authorization,
            logger: logger,
            timeout: timeout
          )
        end

        sig do
          params(
            uri:           URI::Generic,
            payload:       T::Hash[Symbol, T.untyped],
            authorization: T.nilable(PicPayApi::Entities::Authorization),
            logger: T.untyped,
            timeout: T.nilable(Integer)
          ).returns(T::Hash[Symbol, T.untyped])
        end
        def put(uri:, payload:, authorization: nil, logger: nil, timeout: nil)
          request!(
            uri: uri,
            request: Net::HTTP::Put.new(uri),
            payload: payload,
            authorization: authorization,
            logger: logger,
            timeout: timeout
          )
        end

        private

        sig do
          params(
            uri:           URI::Generic,
            request:       Net::HTTPGenericRequest,
            payload:       T.nilable(T::Hash[Symbol, T.untyped]),
            authorization: T.nilable(PicPayApi::Entities::Authorization),
            logger: T.untyped,
            timeout: T.nilable(Integer)
          ).returns(T::Hash[Symbol, T.untyped])
        end
        def request!(uri:, request:, payload: nil, authorization: nil, logger: nil, timeout: nil)
          if logger
            logger.info("uri: #{uri.inspect}")
            logger.info("request: #{request.inspect}")
            logger.info("payload: #{payload.inspect}")
            logger.info("authorization: #{authorization.inspect}")
          end
          http = Net::HTTP.new(uri.hostname, uri.port)
          http.use_ssl = true
          http.set_debug_output(logger) if logger
          http.read_timeout = timeout if timeout

          request.body             = payload.to_json unless payload.nil?
          request['accept']        = 'application/json'
          request['content-type']  = 'application/json'
          request['authorization'] = authorization.to_s unless authorization.nil?

          logger.info("request.headers: #{request.each_header.to_a.inspect}") if logger

          response = http.request(request)

          if logger
            logger.info("response.code: #{response.code.inspect}")
            logger.info("response.headers: #{response.each_header.to_a.inspect}")
            logger.info("response.body: #{response.body.inspect}")
            logger.info("response: #{response.inspect}")
          end

          response.value

          T.let(JSON.parse(response.body, symbolize_names: true), T::Hash[Symbol, T.untyped])
        rescue => e
          logger.error(e) if logger

          raise e
        end
      end
    end
  end
end
