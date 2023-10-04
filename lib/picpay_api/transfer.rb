# typed: strict
# frozen_string_literal: true

require 'logger'

module PicPayApi
  class Transfer

    extend T::Sig

    sig { returns(Logger) }
    attr_accessor :logger

    sig { returns(URI::Generic) }
    attr_accessor :url

    sig { returns(T.proc.returns(PicPayApi::Entities::Authorization)) }
    attr_accessor :access_token_generator

    sig { returns(String) }
    attr_accessor :reference_id

    sig do
      params(
        base_url: String,
        access_token_generator: T.proc.returns(PicPayApi::Entities::Authorization),
        reference_id: String,
        logger: Logger
      ).void
    end
    # @param [String] base_url Picpay API base URL.
    # @param [T.proc.returns(PicPayApi::Entities::Authorization)] access_token_generator Proc that generates an Authorization Entity when called
    # @param [String] reference_id REFERENCE_ID sent by Picpay
    def initialize(
      base_url:,
      access_token_generator:,
      reference_id:,
      logger: Logger.new(STDOUT)
    )
      @logger = logger
      @url = T.let(URI.join(base_url, '/b2p/v2/transfer/reference_id/' + reference_id), URI::Generic)
      @access_token_generator = access_token_generator
      @reference_id = reference_id
    end

    sig { returns(PicPayApi::Entities::Transfer) }
    # Resource made available by consulting a Reference ID Transfer
    def get
      body = PicPayApi::HTTP::Client.get(uri: @url, authorization: @access_token_generator.call)
      PicPayApi::Entities::Transfer.from_h(body)
    end
  end
end
