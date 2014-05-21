class Auth::SamlAuthenticator < Auth::Authenticator

  def name
    "saml"
  end

  def after_authenticate(auth_token)
    result = Auth::Result.new
    Rails.logger.info result
    saml_email = result.name_id

    user_info = SamlUserInfo.where(saml_email: saml_email).first

    if user_info
      user = user_info.user
    elsif user = User.find_by_email(email)
      user_info = SamlUserInfo.create(
          user_id: user.id,
          email: saml_email
      )
    end

    result
  end

  def after_create_account(user, auth)
    # data = auth[:extra_data]
    # SamlUserInfo.create(
    #   user_id: user.id,
    #   screen_name: data[:github_screen_name],
    #   github_user_id: data[:github_user_id]
    # )
  end

  def register_middleware(omniauth)
    omniauth.provider :saml,
           :setup => lambda { |env|
              strategy = env["omniauth.strategy"]
              strategy.options[:assertion_consumer_service_url] = SiteSetting.saml_assertion_consumer_service_url
              strategy.options[:issuer] = SiteSetting.saml_issuer
              strategy.options[:idp_sso_target_url] = SiteSetting.saml_idp_sso_target_url
              # strategy.options[:idp_sso_target_url_runtime_params] = SiteSetting.saml_idp_sso_target_url_runtime_params
              # strategy.options[:idp_cert] = SiteSetting.saml_idp_cert
              strategy.options[:idp_cert_fingerprint] = SiteSetting.saml_idp_cert_fingerprint
              strategy.options[:name_identifier_format] = SiteSetting.saml_name_identifier_format
           }
  end
end
