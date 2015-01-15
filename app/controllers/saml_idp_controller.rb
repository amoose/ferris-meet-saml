require 'saml_idp'

class SamlIdpController < SamlIdp::IdpController
  skip_before_action :verify_authenticity_token

  def idp_authenticate(email, password)
    if signin_params[:sign_up]
      user = User.new(signin_params.except(:sign_up))
      return user if user.save
    elsif user = User.where(email: email).first
      return user if user.match_password( password )
    end
  end
  private :idp_authenticate


  def idp_make_saml_response(found_user)
    encode_response found_user
  end
  private :idp_make_saml_response

  # def sso
  #   # Create LogoutRequest.
  #   signature_opts = {
  #     cert: Rails.application.secrets.saml_client_cert,
  #     key: Rails.application.secrets.saml_client_private_key,
  #     signature_alg: 'rsa-sha256',
  #     digest_alg: 'sha256',
  #   }

  #   logout_request_builder = SamlIdp::LogoutRequestBuilder.new(
  #     "_#{UUID.generate}", # response_id
  #     saml_settings.issuer,
  #     saml_settings.idp_slo_target_url,
  #     UUID.generate,       # name_id
  #     "bogus_fuzzy_lambs", # name_qualifier
  #     UUID.generate,       # session_index
  #     signature_opts)

  #   render template: "saml_idp/shared/saml_post_binding.html.slim",
  #     locals: {
  #       action_url: "/api/saml/logout",
  #       message: Base64.encode64(logout_request_builder.build.to_xml),
  #       type: :SAMLRequest },
  #     layout: false
  # end
  def signin_params
    params.permit(:email, :password, :password_confirmation, :groups, :first_name, :last_name, :sign_up)
  end
end
