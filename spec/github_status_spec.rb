require 'spec_helper'

RSpec.describe "GitHub Status app" do
  before do
    allow(Net::HTTP).to receive(:post)
  end


  context "when GitHub status changes from no issues to major issue" do
    it "sends a message with the current status" do
    def github_api_fake_response_major_issue
      {
        "status" => {
          "indicator" => "major",
          "description" => "Partial System Outage"
        }
      }.to_json
    end
    p github_api_fake_response_major_issue

      stub_request(:get, 'https://kctbh9vrtdwd.statuspage.io/api/v2/status.json').
        to_return(body: github_api_fake_response_major_issue, headers: {})

      expect(Net::HTTP).to receive(:post).with(URI("www.example.com"),
          {text: "GitHub is experiencing major issues at the moment (Partial System Outage). For further info, visit https://www.githubstatus.com"}.to_json,
          "Content-Type" => "application/json")
    end
  end
end
