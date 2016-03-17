require 'json'
require 'net/http'
require 'yaml'

config = YAML.load_file("./jobs/frontapp.settings.yaml")
front_app_id = config["front"]["front_app_id"]
front_api_secret = config["front"]["front_api_secret"]

support_prev = 0
contact_prev = 0
noc_prev = 0
ml_prev = 0
sc_prev = 0

SCHEDULER.every '5m', :first_in => 0 do |job|
  begin
    uri = URI("https://api.frontapp.com/companies/#{front_app_id}/inboxes/e31")
    Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https', :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
      req = Net::HTTP::Get.new uri
      req.basic_auth front_app_id,front_api_secret
  
      response = http.request req 
      parsed = JSON.parse(response.body)
      send_event('support_queue', current: parsed["num_unassigned"], last: support_prev)
      support_prev = parsed["num_unassigned"]
    end

    uri = URI("https://api.frontapp.com/companies/#{front_app_id}/inboxes/e2w")
    Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https', :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
      req = Net::HTTP::Get.new uri
      req.basic_auth front_app_id,front_api_secret
  
      response = http.request req 
      parsed = JSON.parse(response.body)
      send_event('contact_queue', current: parsed["num_unassigned"], last: contact_prev)
      contact_prev = parsed["num_unassigned"]
    end

    uri = URI("https://api.frontapp.com/companies/#{front_app_id}/inboxes/ebb")
    Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https', :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
      req = Net::HTTP::Get.new uri
      req.basic_auth front_app_id,front_api_secret
  
      response = http.request req 
      parsed = JSON.parse(response.body)
      send_event('noc_queue', current: parsed["num_unassigned"], last: noc_prev)
      noc_prev = parsed["num_unassigned"]
    end

    uri = URI("https://api.frontapp.com/companies/#{front_app_id}/team/fwg")
    Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https', :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
      req = Net::HTTP::Get.new uri
      req.basic_auth 'shrd','53ec2a7e6496d7ca3785e6313d356c2b'

      response = http.request req
      parsed = JSON.parse(response.body)
      send_event('ml_queue', value: parsed["num_assigned_received"])
      ml_prev = parsed["num_assigned_received"]
    end

    uri = URI("https://api.frontapp.com/companies/#{front_app_id}/team/fwi")
    Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https', :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
      req = Net::HTTP::Get.new uri
      req.basic_auth 'shrd','53ec2a7e6496d7ca3785e6313d356c2b'

      response = http.request req
      parsed = JSON.parse(response.body)
      send_event('sc_queue', value: parsed["num_assigned_received"])
      sc_prev = parsed["num_assigned_received"]
    end
    
  end
end


