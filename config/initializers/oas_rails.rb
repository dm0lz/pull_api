# config/initializers/oas_rails.rb
OasRails.configure do |config|
  # Basic Information about the API
  config.info.title = "API Documentation"
  config.info.version = "1.0.0"
  config.info.summary = "OasRails: Automatic Interactive API Documentation for Rails"
  config.info.description = <<~HEREDOC
    # PullAPI

    This API provides endpoints for retrieving and analyzing data.

    ## Authentication

    All API endpoints require Bearer token authentication.

    ## Available Resources

    - GET Search engine results : Get search engine results
    - GET Hugging Face inference : Perform Hugging Face model inference
    - POST Scrap domain : Scrap a domain
    - POST Scrap web page : Scrap a web page
    - POST Scrap web pages : Scrap multiple web pages
    - POST Analyze search engine results : Analyze search engine results using a custom prompt
    - POST Analyze web page : Scrap and analyze a web page using a custom prompt
    - GET Domain from company : Get the domain of a company
    - GET Emails from domain : Get the emails of a domain
    - GET Hugging Face models : Get the available Hugging Face models

    ## Rate Limiting

    API requests are limited to 5 requests per minute per API token.

    For more information, contact contact@pullapi.com

  HEREDOC
  # config.info.contact.name = "a-chacon"
  # config.info.contact.email = "andres.ch@proton.me"
  # config.info.contact.url = "https://a-chacon.com"

  # Servers Information. For more details follow: https://spec.openapis.org/oas/latest.html#server-object
  config.servers = [
    { url: "https://www.pullapi.com", description: "Production" },
    { url: "http://localhost:3000", description: "Local" }
  ]

  # Tag Information. For more details follow: https://spec.openapis.org/oas/latest.html#tag-object
  config.tags = [ { name: "Users", description: "Manage the `amazing` Users table." } ]

  # Optional Settings (Uncomment to use)

  # Extract default tags of operations from namespace or controller. Can be set to :namespace or :controller
  # config.default_tags_from = :api

  # Automatically detect request bodies for create/update methods
  # Default: true
  # config.autodiscover_request_body = false

  # Automatically detect responses from controller renders
  # Default: true
  # config.autodiscover_responses = false

  # API path configuration if your API is under a different namespace
  config.api_path = "/api"

  # Apply your custom layout. Should be the name of your layout file
  # Example: "application" if file named application.html.erb
  # Default: false
  # config.layout = "application"

  # Excluding custom controlers or controlers#action
  # Example: ["projects", "users#new"]
  # config.ignored_actions = []

  # #######################
  # Authentication Settings
  # #######################

  # Whether to authenticate all routes by default
  # Default is true; set to false if you don't want all routes to include secutrity schemas by default
  # config.authenticate_all_routes_by_default = true

  # Default security schema used for authentication
  # Choose a predefined security schema
  # [:api_key_cookie, :api_key_header, :api_key_query, :basic, :bearer, :bearer_jwt, :mutual_tls]
  config.security_schema = :bearer

  # Custom security schemas
  # You can uncomment and modify to use custom security schemas
  # Please follow the documentation: https://spec.openapis.org/oas/latest.html#security-scheme-object
  #
  # config.security_schemas = {
  #  bearer:{
  #   "type": "apiKey",
  #   "name": "api_key",
  #   "in": "header"
  #  }
  # }

  # ###########################
  # Default Responses (Errors)
  # ###########################

  # The default responses errors are setted only if the action allow it.
  # Example, if you add forbidden then it will be added only if the endpoint requires authentication.
  # Example: not_found will be setted to the endpoint only if the operation is a show/update/destroy action.
  # config.set_default_responses = true
  # config.possible_default_responses = [:not_found, :unauthorized, :forbidden]
  # config.response_body_of_default = { message: String }
end
