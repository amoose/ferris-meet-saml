require 'saml_idp'

class SamlIdpController < SamlIdp::IdpController
  def idp_authenticate(email, password) # not using params intentionally
    user = User.by_email(email).first
    user && user.valid_password?(password) ? user : nil
  end
  private :idp_authenticate

  def idp_make_saml_response(found_user) # not using params intentionally
    encode_response found_user
  end

  def sso
    # Create LogoutRequest.
    signature_opts = {
      cert: Rails.application.secrets.saml_client_cert,
      key: Rails.application.secrets.saml_client_private_key,
      signature_alg: 'rsa-sha256',
      digest_alg: 'sha256',
    }

    logout_request_builder = SamlIdp::LogoutRequestBuilder.new(
      "_#{UUID.generate}", # response_id
      saml_settings.issuer,
      saml_settings.idp_slo_target_url,
      UUID.generate,       # name_id
      "bogus_fuzzy_lambs", # name_qualifier
      UUID.generate,       # session_index
      signature_opts)

    render template: "saml_idp/shared/saml_post_binding.html.slim",
      locals: {
        action_url: "/api/saml/logout",
        message: Base64.encode64(logout_request_builder.build.to_xml),
        type: :SAMLRequest },
      layout: false
  end
  private :idp_make_saml_response
end