resource "aws_cognito_user_pool" "app-pool" {
  name = "app-pool"

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }
  auto_verified_attributes = ["email"]
  username_attributes      = ["email"]
  username_configuration {
    case_sensitive = true
  }

  password_policy {
    minimum_length    = 6
    require_lowercase = false
    require_numbers   = false
    require_symbols   = false
    require_uppercase = false
  }
}

resource "aws_cognito_user_pool_domain" "pool-domain" {
  domain       = var.cogdomain
  user_pool_id = aws_cognito_user_pool.app-pool.id
}

resource "aws_cognito_user_pool_client" "pool-client" {
  name                                 = "testowankomega"
  user_pool_id                         = aws_cognito_user_pool.app-pool.id
  supported_identity_providers         = ["COGNITO"]
  callback_urls                        = ["https://${var.greeting}/login.html"]
  logout_urls                          = ["https://${var.greeting}/logout.html"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["openid", "email", "profile"]
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH", "ALLOW_USER_PASSWORD_AUTH"]
  generate_secret                      = false
  prevent_user_existence_errors        = "LEGACY"
  refresh_token_validity               = 1
  access_token_validity                = 1
  id_token_validity                    = 1
  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "hours"
  }
}