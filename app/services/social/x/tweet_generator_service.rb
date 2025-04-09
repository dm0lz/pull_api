class Social::X::TweetGeneratorService < BaseService
  def initialize(topic)
    @topic = topic
  end

  def call
    response = Ai::Openai::ChatService.new.call(user_prompt, response_schema)
    response["tweet"]
  end

  private
  def user_prompt
    <<-TXT
      Generate a tweet about the following topic (max 280 characters) : #{@topic}
      Include a link to my app : https://www.pullapi.com
    TXT
  end

  def response_schema
    {
      "strict": true,
      "name": "Tweet Generator",
      "description": "Generate a Tweet",
      "schema": {
        "type": "object",
        "properties": {
          "tweet": {
            "type": "string",
            "description": "tweet content"
          }
        },
        "additionalProperties": false,
        "required": [ "tweet" ]
      }
    }
  end
end
