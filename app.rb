require 'json'
require 'sinatra'
require 'net/http'
require 'intercom'
require 'dotenv/load'
require 'httparty'
# require 'slack-ruby-client'


$intercom = Intercom::Client.new(token: ENV['TOKEN'])
# $zone = Time.now.getlocal.zone

get '/' do
end

# image   {\"id\":\"welcome-link\",\"type\":\"image\",\"url\":\"https://downloads.intercomcdn.com/i/o/86160844/0f0f53fbdb1c741e2f7bca83/link.jpg\",\"align\":\"right\",\"width\":130,\"height\":130,\"rounded\":true}


post '/slack' do 
  # puts "••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••"
   request_data = JSON.parse(request.body.read)
   # p request_data
   # $text_data = JSON.pretty_generate(request_data)["text"]
   # p $text_data
   # p "hi"
   # if request_data['event']['type'] == "app_mention"
    $channel_topic = "CSE on-call: #{request_data['event']['text']}"
    # p $channel_topic
    # p extract_slack_ids
   # end
  status 200
  get_real_user(extract_slack_ids)
  # p extract_slack_ids
end

def get_real_user(*array_of_ids)
  cse = HTTParty.post("https://slack.com/api/users.profile.get",
    query: {token: ENV['SLACK-OAUTH'], user: array_of_ids[0][0], pretty: 1})
  csr = HTTParty.post("https://slack.com/api/users.profile.get",
    query: {token: ENV['SLACK-OAUTH'], user: array_of_ids[0][1], pretty: 1})
  # p cse
  if cse.parsed_response['error']
    $cse_name = "N/A"
  else
    $cse_name = cse['profile']['real_name']
    $cse_img = cse['profile']['image_192']
  end
  if csr.parsed_response['error']
    $csr_name = "N/A"
  else
    $csr_name = csr['profile']['real_name']
    $csr_img = csr['profile']['image_192']
  end
     
   
 
end

def extract_slack_ids
   regex = $channel_topic.match(%r{CSE on call: <@(\w+).+<@(\w+)}m)
   return regex.captures
end

#  case request_data['type']
#        # When you enter your Events webhook URL into your app's Event Subscription settings, Slack verifies the
#        # URL's authenticity by sending a challenge token to your endpoint, expecting your app to echo it back.
#        # More info: https://api.slack.com/events/url_verification
#        when 'url_verification'
#          request_data['challenge']

#        # when 'event_callback'
#        #   # Get the Team ID and Event data from the request object
#        #   team_id = request_data['team_id']
#        #   event_data = request_data['event']

#          # Events have a "type" attribute included in their payload, allowing you to handle different
#          # Event payloads as needed.
#          case event_data['type']
#            # when 'team_join'
#            #   # Event handler for when a user joins a team
#            #   Events.user_join(team_id, event_data)
#            # when 'reaction_added'
#            #   # Event handler for when a user reacts to a message or item
#            #   Events.reaction_added(team_id, event_data)
#            #   p "REACTION!"
#            # when 'pin_added'
#            #   # Event handler for when a user pins a message
#            #   Events.pin_added(team_id, event_data)
#            when 'message'
#              # Event handler for messages, including Share Message actions
#              Events.message(team_id, event_data)
#             puts "REQUEST DATA"
#             puts JSON.pretty_generate(request_data)
#             puts "EVENT DATA"
#             puts JSON.pretty_generate(event_data)
#            else
#              # In the event we receive an event we didn't expect, we'll log it and move on.
#              puts "Unexpected event:\n"
#              puts JSON.pretty_generate(request_data)
#          end
#          # Return HTTP status code 200 so Slack knows we've received the Event
#          status 200
#      end
#    # p request_data['type']
#     # case request_data['type']
#     # when 'url_verification'
#       # When we receive a `url_verification` event, we need to
#       # return the same `challenge` value sent to us from Slack
#       # to confirm our server's authenticity.
#       # request_data['challenge']
#     # end
#     # puts "••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••"


# end
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
text = "{\"content\":{\"components\":[{\"type\":\"list\",\"disabled\":false,\"items\":[{\"type\":\"item\",\"id\":\"on-call-list\",\"title\":\"CSE on call:\",\"subtitle\":\"#{$cse_name}\",\"image\":\"#{$cse_img}\",\"image_width\":48,\"image_height\":48,\"rounded_image\":true},{\"type\":\"item\",\"id\":\"on-call-list\",\"title\":\"CSR on call:\",\"subtitle\":\"#{$csr_name}\",\"image\":\"#{$csr_img}\",\"image_width\":48,\"image_height\":48,\"rounded_image\":true}]},{\"id\":\"ab1c31592d\",\"type\":\"text\",\"text\":\"#{$response}\",\"style\":\"header\",\"align\":\"left\",\"bottom_margin\":false}]}}"
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

# {
#   type: "list",
#   disabled: "true",
#   items: [
#     {
#       type: "item",
#       id: "list-of-oncall",
#       title: "CSE on call",
#       subtitle: "#{cse_name}",
#       image: "#{cse_img}",
#       image_width: 48,
#       image_height: 48,
#       roundedImage: true,
#     }
#   ]
# }
 