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
  status 200
  get_real_user(extract_slack_ids)
end

def get_real_user(*array_of_ids)
  cse = HTTParty.post("https://slack.com/api/users.profile.get",
    query: {token: ENV['SLACK-OAUTH'], user: array_of_ids[0][0], pretty: 1})
  csr = HTTParty.post("https://slack.com/api/users.profile.get",
    query: {token: ENV['SLACK-OAUTH'], user: array_of_ids[0][1], pretty: 1})
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
   return regex.captures
end


def send_message_to_intercom
    $intercom.messages.create(
  :from => {
    :type => "user",
    :id => "5879561d297e35032e336f16"
  },
  :body => "#{$currently_on_call} #{$real_name} #{$text_data}"
)
  end

post '/' do
	text = "{\"canvas\":{\"content_url\":\"https://evening-fortress-32801.herokuapp.com/live_canvas\"}}"
 	text.to_json
	text
end

post '/live_canvas' do
  content_type 'application/json'
	$time = Time.now.strftime("%H:%M")
  $all_convos = $intercom.counts.for_type(type: 'conversation').conversation["open"]
	$response = "Current ongoing conversations: *#{$all_convos}*\\n
	Updated at: *#{$time}* *#{$zone}*"
  
  if $all_convos == 0
  	$response = "Woot woot! On-call inbox is empty!  \\n
  	Updated at: *#{$time}* *#{$zone}*"
  end
  if $all_convos >= 10
  	$response = "Current ongoing conversations: *#{$all_convos}*\\n
  	Response time might be a bit longer \\n
	Updated at: *#{$time}* *#{$zone}*"
  end
text = "{\"content\":{\"components\":[{\"id\":\"ab1c31592d\",\"type\":\"text\",\"text\":\"#{$response}\",\"style\":\"header\",\"align\":\"left\",\"bottom_margin\":false},{\"type\":\"divider\"},{\"type\":\"list\",\"disabled\":false,\"items\":[{\"type\":\"item\",\"id\":\"on-call-list\",\"title\":\"CSE on call:\",\"subtitle\":\"#{$cse_name}\",\"image\":\"#{$cse_img}\",\"image_width\":48,\"image_height\":48,\"rounded_image\":true},{\"type\":\"item\",\"id\":\"on-call-list2\",\"title\":\"CSR on call:\",\"subtitle\":\"#{$csr_name}\",\"image\":\"#{$csr_img}\",\"image_width\":48,\"image_height\":48,\"rounded_image\":true}]}]}}"
text.to_json
text


# "{\"content\":{\"components\":[{\"type\":\"list\",\"disabled\":true,\"items\":[{\"type\":\"item\",\"id\":\"list-of-oncall\",\"title\":\"CSE on call\",\"subtitle\":\"#{cse_name}\",\"image\":\"#{cse_img}\",\"image_width\":48,\"image_height\":48,\"roundedImage\":true}]}]}}"


	# text = "{\"content\":{\"components\":[{\"id\":\"ab1c31592d25779a24e25b2e97b4\",\"type\":\"text\",\"text\":\"CSE on call: #{$cse_name}\",\"style\":\"header\",\"align\":\"left\",\"bottom_margin\":false},{\"id\":\"slack-image\",\"type\":\"image\",\"url\":\"#{$cse_img}\",\"align\":\"right\",\"width\":48,\"height\":48,\"rounded\":true},{\"id\":\"ab1c31592d\",\"type\":\"text\",\"text\":\"#{$response}\",\"style\":\"header\",\"align\":\"left\",\"bottom_margin\":false},{\"type\":\"divider\"}]}}"
 # 	text.to_json
 #  text
# list_text.to_json
#   list_text
  # \"width\":130,\"height\":130,
end

#