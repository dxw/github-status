require 'json'
require 'yaml/store'
require 'yaml'
require 'net/http'
require 'dotenv/load'

url = 'https://kctbh9vrtdwd.statuspage.io/api/v2/status.json'

response = Net::HTTP.get_response URI(url)

return unless response.code.to_i == 200

github_status = JSON.parse(response.body)

previous_file = YAML.load_file('github_status.yml')
previous_indicator = previous_file['indicator']

current_indicator = github_status['status']['indicator']
current_description = github_status['status']['description']

if current_indicator != previous_indicator
  new_status = YAML.dump(github_status['status'])
  File.open('github_status.yml', 'w') {|f| f.write new_status }

  if current_indicator == "none"
    message = "GitHub incident has now been resolved. For further info, visit https://www.githubstatus.com"
  elsif previous_indicator == "none"
    message = "GitHub is experiencing #{current_indicator} issues at the moment. For further info, visit https://www.githubstatus.com"
  else
    message = "GitHub status has changed, from #{previous_indicator} issues to #{current_indicator} issues. For further info, visit https://www.githubstatus.com"
  end

  Net::HTTP.post URI(ENV["SLACK_WEBHOOK_URL"]),
   { text: message }.to_json,
   "Content-Type" => "application/json"
end
