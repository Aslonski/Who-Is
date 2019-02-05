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



post '/slack' do 
  # puts "••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••"
   # request_data = JSON.parse(request.body.read)
   # p request_data
   # text_data = JSON.pretty_generate(request_data)["text"]
   # p text_data
   # p "hi"
   # if request_data['event']['type'] == "app_mention"
    # $currently_on_call = "Currently on-call: #{request_data['event']['text']}"

   # end
  # status 200
  return get_real_user
end

def get_real_user
  response = HTTParty.post("https://slack.com/api/users.profile.get",
    query: {token: ENV['SLACK-OAUTH'], user: "U328BLX88", pretty: 1})
    $real_name = response['profile']['real_name']
   $real_name
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

    $intercom.messages.create(
  :from => {
    :type => "user",
    :id => "5879561d297e35032e336f16"
  },
  :body => "#{$currently_on_call}, #{$real_name}"
)

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

	text = "{\"content\":{\"components\":[{\"id\":\"ab1c31592d25779a24e25b2e97b4\",\"type\":\"text\",\"text\":\"CSE on call: #{$real_name}\n#{$response}\",\"style\":\"header\",\"align\":\"left\",\"bottom_margin\":false}]}}"
 	text.to_json
	text
end
 