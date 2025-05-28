require 'openssl'
require 'base64'

class Signer
  class << self
    def private_key
      @private_key ||= begin
        key_path = Rails.root.join('config', 'privateKey.pem')
        File.read(key_path)
      rescue => e
        Rails.logger.error "Failed to load private key: #{e}"
        raise "Failed to initialize Signer"
      end
    end

    def sign(data)
      begin
        digest = OpenSSL::Digest::SHA1.new
        signer = OpenSSL::PKey::RSA.new(private_key)
        signature = signer.sign(digest, data)
        base64_signature = Base64.strict_encode64(signature)

        "--rbxsig%#{base64_signature}%#{data}"
      rescue => e
        Rails.logger.error "Failed to sign data: #{e}"
        raise "Failed to sign data"
      end
    end
  end
end
