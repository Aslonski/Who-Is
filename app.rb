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
  $channel_topic = "#{request_data['event']['text']}"
  status 200
end



def extract_names_from_topic
  cse_name = $channel_topic.match(%r{CSE\*\: (\w+)}m)
  css_name = $channel_topic.match(%r{CSS\*\: (\w+)}m)
  bs_name = $channel_topic.match(%r{Billing Specialist\*\: (\w+)}m)
  cse_name = cse_name ? cse_name.captures : ["fakeid"]
  css_name = css_name ? css_name.captures : ["fakeid"]
  bs_name = bs_name ? bs_name.captures : ["fakeid"]
  return cse_name + css_name + bs_name
end


post '/' do
	text = "{\"canvas\":{\"content_url\":\"https://evening-fortress-32801.herokuapp.com/live_canvas\"}}"
	
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

  $text = "{\"content\":{\"components\":[{\"id\":\"ab1c31592d\",\"type\":\"text\",\"text\":\"#{$response}\",\"style\":\"header\",\"align\":\"left\",\"bottom_margin\":false},{\"id\":\"ab1c31\",\"type\":\"text\",\"text\":\"#{$updated_at}\",\"style\":\"header\",\"align\":\"left\",\"bottom_margin\":false},{\"type\":\"divider\"},{\"type\":\"list\",\"disabled\":false,\"items\":[{\"type\":\"item\",\"id\":\"on-call-list\",\"title\":\"CSE on call:\",\"subtitle\":\"#{extract_names_from_topic[0]}\",\"image\":\"#{$cse_img}\",\"image_width\":48,\"image_height\":48,\"rounded_image\":true},{\"type\":\"item\",\"id\":\"on-call-list2\",\"title\":\"CSS on call:\",\"subtitle\":\"#{extract_names_from_topic[1]}\",\"image\":\"#{$csr_img}\",\"image_width\":48,\"image_height\":48,\"rounded_image\":true}]}]}}"
end

# ,{\"type\":\"item\",\"id\":\"on-call-list3\",\"title\":\"BS on call:\",\"subtitle\":\"#{extract_names_from_topic[2]}\",\"image\":\"#{$cse_img}\",\"image_width\":48,\"image_height\":48,\"rounded_image\":true}

