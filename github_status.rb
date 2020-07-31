require "aws-sdk-s3"
require "json"
require "yaml/store"
require "yaml"
require "net/http"
require "dotenv/load"

data_file = "github_status.yml"
url = "https://kctbh9vrtdwd.statuspage.io/api/v2/status.json"

response = Net::HTTP.get_response URI(url)

return unless response.code.to_i == 200

github_status = JSON.parse(response.body)

s3 = Aws::S3::Resource.new(region: ENV["AWS_REGION"])
obj = s3.bucket(ENV["AWS_BUCKET"]).object(data_file)
resp = obj.get.body.read

previous_file = YAML.load(resp)
previous_indicator = previous_file["indicator"]

current_indicator = github_status["status"]["indicator"]
current_description = github_status["status"]["description"]

if current_indicator != previous_indicator
  new_data_file = {
    "indicator" => current_indicator,
    "description" => current_description
  }
  s3.bucket(ENV["AWS_BUCKET"]).put_object(key: data_file, body: YAML.dump(new_data_file))

  if current_indicator == "none"
    message = "GitHub incident has now been resolved. #{current_description}. For further info, visit https://www.githubstatus.com"
  elsif previous_indicator == "none"
    message = "GitHub is experiencing #{current_indicator} issues at the moment (#{current_description}). For further info, visit https://www.githubstatus.com"
  else
    message = "GitHub status has changed, from #{previous_indicator} issues to #{current_indicator} issues (#{current_description}). For further info, visit https://www.githubstatus.com"
  end
  Net::HTTP.post URI(ENV["SLACK_WEBHOOK_URL"]),
   { text: message }.to_json,
   "Content-Type" => "application/json"
end
