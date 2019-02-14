require 'json'
require 'sinatra'
require 'net/http'
require 'intercom'
require 'dotenv/load'
require 'httparty'

$intercom = Intercom::Client.new(token: ENV['TOKEN'])
$zone = Time.now.getlocal.zone

get '/' do
end

post '/slack' do 
  request_data = JSON.parse(request.body.read)
  $channel_topic = "CSE on-call: #{request_data['event']['text']}"
  puts "#{request_data['event']['text']}"
  status 200
  # extract_slack_ids
  get_real_user(extract_slack_ids)
end

def get_real_user(*array_of_ids)
  cse = HTTParty.post("https://slack.com/api/users.profile.get",
    query: {token: ENV['SLACK-OAUTH'], user: array_of_ids[0][0], pretty: 1})
  csr = HTTParty.post("https://slack.com/api/users.profile.get",
    query: {token: ENV['SLACK-OAUTH'], user: array_of_ids[0][1], pretty: 1})
  puts "CSE #{cse}"
  puts "CSE PARSED RESPONSE #{cse.parsed_response}"
  if cse.parsed_response['error']
    $cse_name = "N/A"
    $cse_img = "https://downloads.intercomcdn.com/i/o/102767128/61befae4699e11c05edf1661/shrug.png"
  else
    $cse_name = cse['profile']['real_name']
    $cse_img = cse['profile']['image_192']
  end
  if csr.parsed_response['error']
    $csr_name = "N/A"
    $csr_img = "https://downloads.intercomcdn.com/i/o/102767128/61befae4699e11c05edf1661/shrug.png"
  else
    $csr_name = csr['profile']['real_name']
    $csr_img = csr['profile']['image_192']
  end 
end

def extract_slack_ids
  regex = $channel_topic.match(%r{CSE on call: <@(\w+).+<@(\w+)}m)
    puts " REGEX CAPTURES: #{regex.captures}"
    return regex.captures rescue[]
  
end

post '/' do
	text = "{\"canvas\":{\"content_url\":\"https://evening-fortress-32801.herokuapp.com/live_canvas\"}}"
 	text.to_json
	text
end

post '/live_canvas' do
  content_type 'application/json'
	$time = Time.now.strftime("%H:%M")
  $updated_at = "Updated at: *#{$time}* *#{$zone}*"
  $all_convos = $intercom.counts.for_type(type: 'conversation').conversation["open"]
	$response = "Current ongoing conversations: *#{$all_convos}*"
  
  if $all_convos == 0
  	$response = "Woot woot! On-call inbox is empty! 🥳"
  end

  if $all_convos >= 10
  	$response = "Current ongoing conversations: *#{$all_convos}*
  	Response time might be a bit longer 😅"
  end

text = "{\"content\":{\"components\":[{\"id\":\"ab1c31592d\",\"type\":\"text\",\"text\":\"#{$response}\",\"style\":\"header\",\"align\":\"left\",\"bottom_margin\":false},{\"id\":\"ab1c31\",\"type\":\"text\",\"text\":\"#{$updated_at}\",\"style\":\"header\",\"align\":\"left\",\"bottom_margin\":false},{\"type\":\"divider\"},{\"type\":\"list\",\"disabled\":false,\"items\":[{\"type\":\"item\",\"id\":\"on-call-list\",\"title\":\"CSE on call:\",\"subtitle\":\"#{$cse_name}\",\"image\":\"#{$cse_img}\",\"image_width\":48,\"image_height\":48,\"rounded_image\":true},{\"type\":\"item\",\"id\":\"on-call-list2\",\"title\":\"CSR on call:\",\"subtitle\":\"#{$csr_name}\",\"image\":\"#{$csr_img}\",\"image_width\":48,\"image_height\":48,\"rounded_image\":true}]}]}}"
text.to_json
text

end

#