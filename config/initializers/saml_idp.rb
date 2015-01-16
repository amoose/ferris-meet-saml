def fingerprint_cert(cert_pem)
  return nil unless cert_pem
  cert = OpenSSL::X509::Certificate.new(cert_pem)
  OpenSSL::Digest::SHA256.new(cert.to_der).hexdigest
end


SamlIdp.configure do |config|
  base = ENV['NGROK_DOMAIN']

  config.x509_certificate     = Rails.application.secrets.saml_cert
  config.secret_key           = Rails.application.secrets.saml_private_key

  config.entity_id                = 'uscisprodidp'

  # config.password = "secret_key_password"
  config.algorithm = :sha256
  # config.organization_name = "Your Organization"
  # config.organization_url = "http://example.com"
  config.base_saml_location = "#{base}/saml"
  # config.reference_id_generator                   # Default: -> { UUID.generate }
  # config.attribute_service_location = "#{base}/saml/attributes"
  config.single_service_post_location = "#{base}/saml/auth"
  # config.single_logout_service_post_location = "#{base}/saml/sso"


  config.organization_name = "MOCK Internal ICAM"

  # config.x509_certificate = Rails.application.secrets.saml_cert
  # config.secret_key = OpenSSL::PKey::RSA.new(
  #   File.read(Rails.root + 'config/saml.key.enc'), 
  #   Rails.application.secrets.saml_passphrase).to_pem


  # config.algorithm = :sha256


  # config.signature_alg = 'rsa-sha256'
  # config.digest_alg = 'sha256'
  
  # Principal is passed in when you `encode_response`
  #
  # config.name_id_formats = {
  #     email_address: -> (principal) { principal.email },
  #     transient: -> (principal) { principal.id },
  #     persistent: -> (p) { p.id }
  #   }
  #   OR
  #
  #   {
  #     "1.1" => {
  #       email_address: -> (principal) { principal.email_address },
  #     },
  #     "2.0" => {
  #       transient: -> (principal) { principal.email_address },
  #       persistent: -> (p) { p.id },
  #     },
  #   }

  # config.attributes # =>
  #   {
  #     <friendly_name> => {                                                  # required (ex "eduPersonAffiliation")
  #       "name" => <attrname>                                                # required (ex "urn:oid:1.3.6.1.4.1.5923.1.1.1.1")
  #       "name_format" => "urn:oasis:names:tc:SAML:2.0:attrname-format:uri", # not required
  #       "getter" => ->(principal) {                                         # not required
  #         principal.get_eduPersonAffiliation                                # If no "getter" defined, will try
  #       }                                                                   # `principal.eduPersonAffiliation`, or no values will
  #    }                                                                      # be output
  #
  ## EXAMPLE ##
  # config.attributes = {
  #   GivenName: {
  #     getter: :first_name,
  #   },
  #   SurName: {
  #     getter: :last_name,
  #   },
  # }
  config.attributes = {
    :emailAddress => {
      :getter => :email
    },
    :cisUUID => {
      :getter => :uuid
    },
    :groups => {
      :getter => :groups
    },
    :sn => {
      :getter => :first_name
    },
    :givenName => {
      :getter => :last_name
    }

  }
  ## EXAMPLE ##

  # config.technical_contact.company = "Example"
  # config.technical_contact.given_name = "Jonny"
  # config.technical_contact.sur_name = "Support"
  # config.technical_contact.telephone = "55555555555"
  # config.technical_contact.email_address = "example@example.com"

  service_providers = {
    "http://localhost:3000/users/auth/saml" => {
      acs_url: "http://localhost:3000/users/auth/saml/callback",
      metadata_url: "http://localhost:3000/users/auth/saml/metadata",
      cert: Rails.application.secrets.saml_cert,
      # block_encryption: 'aes256-cbc',
      # key_transport: 'rsa-oaep-mgf1p',
      fingerprint: fingerprint_cert(Rails.application.secrets.saml_cert)
    },
    "https://save-ferris-dev.18f.us/users/auth/saml" => {
      acs_url: "https://save-ferris-dev.18f.us/users/auth/saml/callback",
      metadata_url: "https://save-ferris-dev.18f.us/users/auth/saml/metadata",
      cert: Rails.application.secrets.saml_cert,
      # block_encryption: 'aes256-cbc',
      # key_transport: 'rsa-oaep-mgf1p',
      fingerprint: fingerprint_cert(Rails.application.secrets.saml_cert)
    }
  }

  # `identifier` is the entity_id or issuer of the Service Provider,
  # settings is an IncomingMetadata object which has a to_h method that needs to be persisted
  # config.service_provider.metadata_persister = ->(identifier, settings) {
  #   fname = identifier.to_s.gsub(/\/|:/,"_")
  #   `mkdir -p #{Rails.root.join("cache/saml/metadata")}`
  #   File.open Rails.root.join("cache/saml/metadata/#{fname}"), "r+b" do |f|
  #     Marshal.dump settings.to_h, f
  #   end
  # }

  # # `identifier` is the entity_id or issuer of the Service Provider,
  # # `service_provider` is a ServiceProvider object. Based on the `identifier` or the
  # # `service_provider` you should return the settings.to_h from above
  # config.service_provider.persisted_metadata_getter = ->(identifier, service_provider){
  #   fname = identifier.to_s.gsub(/\/|:/,"_")
  #   `mkdir -p #{Rails.root.join("cache/saml/metadata")}`
  #   File.open Rails.root.join("cache/saml/metadata/#{fname}"), "rb" do |f|
  #     Marshal.load f
  #   end
  # }

  # Find ServiceProvider metadata_url and fingerprint based on our settings
  config.service_provider.finder = ->(issuer_or_entity_id) do
    service_providers[issuer_or_entity_id]
  end

  config.service_provider.metadata_persister = ->(identifier, settings) do
    # SamlIdpConfig::metadata_persister(identifier, settings)
  end

  # `identifier` is the entity_id or issuer of the Service Provider,
  # `service_provider` is a ServiceProvider object. Based on the `identifier` or the
  # `service_provider` you should return the settings.to_h from above
  config.service_provider.persisted_metadata_getter = ->(identifier, service_provider) do
    service_provider
  end

  # Find ServiceProvider metadata_url and fingerprint based on our settings
  config.service_provider.finder = ->(issuer_or_entity_id) do
    Rails.logger.info("Looking up SAML SP #{issuer_or_entity_id}")
    service_providers[issuer_or_entity_id] # or raise "Unknown service provider", issuer_or_entity_id
  end
end

