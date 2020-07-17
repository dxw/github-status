desc "This task is called by the Heroku scheduler add-on"
task :status => :environment do
  ruby "github_status.rb"
end
