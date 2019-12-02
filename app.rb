require 'json'
require 'sinatra'
require 'net/http'
require 'intercom'
require 'dotenv/load'
require 'httparty'

def intercom_client
  intercom_client ||= Intercom::Client.new(token: ENV['UNSTABLE-TOKEN'])
end


post '/slack' do 
  request_data = JSON.parse(request.body.read)
  channel_topic = "#{request_data['event']['text']}"
  # set_on_call_people_in_intercom(channel_topic)
  # sleep(2)
  get_currently_on_call_people
  # status 200
  # extract_names_from_topic(channel_topic)
  # pull a segment of on-call users from Intercom -> "On Call Team" segment_id: 5d92336e9925897dd683c683
  # compare the segment against the data from the extracted names 
  # make a method to update the on-call data in Intercom based on the above
  # Need to do this because I can't use global variables in the internal integrations repo.
# # –––––––––
# 

end

def set_on_call_people_in_intercom(people)
  hash_of_names = find_people_in_intercom(extract_names_from_topic(people))
  # intercom_client.users.create(id: hash_of_names[@cse_name[0]], custom_attributes:{"on_call_currently": true})
  # intercom_client.users.create(id: hash_of_names[@css_name[0]], custom_attributes:{"on_call_currently": true})
  # intercom_client.users.create(id: hash_of_names[@bs_name[0]], custom_attributes:{"on_call_currently": true})
   # get_currently_on_call_people
end


def extract_names_from_topic(topic)
  @cse_name = topic.match(%r{CSE\*\: (\w+)}m)
  @css_name = topic.match(%r{CSS\*\: (\w+)}m)
  @bs_name  = topic.match(%r{Billing Specialist\*\: (\w+)}m)
  @cse_name = @cse_name ? @cse_name.captures : ["No CSE on call at the moment"]
  @css_name = @css_name ? @css_name.captures : ["No CSS on call at the moment"]
  @bs_name  = @bs_name  ? @bs_name.captures  : ["No Billing Specialist on call at the moment"]
  return @cse_name + @css_name + @bs_name
end

post '/' do
	text = "{\"canvas\":{\"content_url\":\"https://evening-fortress-32801.herokuapp.com/live_canvas\"}}"
	text
end

# Lay out necessary attribute/variable setups in method-by-method style!
private def on_call_images_hash
  @on_call_images_hash ||= {
    # APAC
    "Amy":        "https://downloads.intercomcdn.com/i/o/152233512/c06c7ac8e899e829ccb89b43/image.png",
    "Andie":      "https://downloads.intercomcdn.com/i/o/152235086/6395a05f52c17e218b844eb8/image.png",
    "Anusha":     "https://downloads.intercomcdn.com/i/o/152235464/7a6016d3407e2e24ff7c87aa/image.png",
    "Dorian":     "https://downloads.intercomcdn.com/i/o/152237342/f1ded691d993c2309411406f/image.png",
    "Jon":        "https://downloads.intercomcdn.com/i/o/152239685/ef4b1cbe2a3465697b2d7d73/image.png",
    "Jonno":      "https://downloads.intercomcdn.com/i/o/152241897/2905d44d611b0a7df95db1ac/image.png",
    "Samuel":     "https://downloads.intercomcdn.com/i/o/152244151/e1e727e0fc137441de6517d9/image.png",
    # EMEA
    "Andy":       "https://downloads.intercomcdn.com/i/o/152244595/1eee6164dae6ed74b409098a/image.png",
    "Aparna":     "https://downloads.intercomcdn.com/i/o/152247381/8c57d705a9d54eaea8f7f714/image.png",
    "Ciara":      "https://downloads.intercomcdn.com/i/o/152248196/53f39c18c72d3050338853de/image.png",
    "Colin":      "https://downloads.intercomcdn.com/i/o/152249146/ce7c622ba7d253ef68a7506b/image.png",
    "Dan":        "https://downloads.intercomcdn.com/i/o/152251221/50705ceb96378112ffe74858/image.png",
    "Daniel":     "https://downloads.intercomcdn.com/i/o/152252759/2d2408660cff77b2d01229fa/image.png",
    "Donal":      "https://downloads.intercomcdn.com/i/o/152253111/6b8ef1bda577f7bd356f850d/image.png",
    "Joseph":     "https://downloads.intercomcdn.com/i/o/152254766/62f191b00e4e4491918217c5/image.png",
    "Kunal":      "https://downloads.intercomcdn.com/i/o/152255566/b0b508993afdfef82faca206/image.png",
    "Laura":      "https://downloads.intercomcdn.com/i/o/152255883/12709c5a1c65eff8dde8a187/image.png",
    "Lizzie":     "https://downloads.intercomcdn.com/i/o/152256296/767edd06d611ddf63fcddced/image.png",
    "Matt":       "https://downloads.intercomcdn.com/i/o/152256588/4ea5737d0f04fb9efa4f289f/image.png",
    "Omar":       "https://downloads.intercomcdn.com/i/o/152256897/5cb1631f1ab91d5cca08876f/image.png",
    "SeanM":      "https://downloads.intercomcdn.com/i/o/152257191/169becaed5b07fb6da2bb110/image.png",
    "Shannen":    "https://downloads.intercomcdn.com/i/o/152257651/e766b41514b2be3c9c1add75/image.png",
    "Sorin":      "https://downloads.intercomcdn.com/i/o/152257896/7870dfae38cf6e09ea65ab1a/image.png",
    #NORAM
    "Adam":       "https://downloads.intercomcdn.com/i/o/152258166/0e410ff5a8a4b6fefb2d0635/image.png",
    "Amanda":     "https://downloads.intercomcdn.com/i/o/152258617/ffe3c53b651278d4f3cac51d/image.png",
    "Andrew":     "https://downloads.intercomcdn.com/i/o/152258923/00ce50cbdcc99c538d07bcf9/image.png",
    "Andrey":     "https://downloads.intercomcdn.com/i/o/152259309/1f160668f3715af492ef68be/image.png",
    "Annie":      "https://downloads.intercomcdn.com/i/o/152259543/8fcf5cc56ae8e209797e3dfb/image.png",
    "Delilah":    "https://downloads.intercomcdn.com/i/o/152259922/97312ab58a29d4ae50be18b4/image.png",
    "Gabriel":    "https://downloads.intercomcdn.com/i/o/152260603/a7f04c2faa4399a6b031619d/image.png",
    "Janelle":    "https://downloads.intercomcdn.com/i/o/152261412/9145aaa32d9e8d821d7058d9/image.png",
    "Josh":       "https://downloads.intercomcdn.com/i/o/152261643/60d8ae93269c85cf6b739bfe/image.png",
    "Kayvan":     "https://downloads.intercomcdn.com/i/o/152262054/bf23e11f6ff7e769e6937f0a/image.png",
    "Russell":    "https://downloads.intercomcdn.com/i/o/151510541/354f58b68e344dd1ed02d30a/image.png",
    "Samir":      "https://downloads.intercomcdn.com/i/o/152262426/dfabd7592faf5ec60491bed3/image.png",
    "Sayam":      "https://downloads.intercomcdn.com/i/o/152262702/081fbf75c68c2309f1b5648e/image.png",
    "SeanS":      "https://downloads.intercomcdn.com/i/o/152263104/352bf438b2824b895705e7c3/image.png",
    "Tove":       "https://downloads.intercomcdn.com/i/o/152263374/cc0c7d56d51c3b95c3575a42/image.png",
    "travolta": "https://downloads.intercomcdn.com/i/o/155646832/cf835e0b5c86d3c6d0e7fb43/giphy.gif"
  }
end

private def get_conversation_count
  all_convos = intercom_client.counts.for_type(type: 'conversation').conversation["open"]
  my_response = "Current ongoing conversations: *#{all_convos}*"
  
  if all_convos == 0
    my_response = "Woot woot! On-call inbox is empty! 🥳"
  end

  if all_convos >= 10
    my_response = "Current ongoing conversations: *#{all_convos}*
    Response time might be a bit longer 😅"
  end
end

private def updated_at
  @updated_at ||= get_updated_at
end

private def get_updated_at
  zone = Time.now.getlocal.zone
  time = Time.now.strftime("%H:%M")
  "Updated at: *#{time}* *#{zone}*"
end


# Lay out (method by method) what we need to update when Slack topic gets updated
private def update_oncall_people_status
  # received a post from Slack topic change
  # Compare that post from slack with the currently oncall people
  current = get_currently_on_call_people
  # loop through and compare "current" with "slack_post" to find out who changed
  # resulting_different_array of people to set "false" needs to be processed
  # slack_post array of new oncall_people needs to be set to "true" 
end


private def query_name_inserter(name)
  {
    field: "name",
    operator: "~",
    value: name
  }
end

def find_people_in_intercom(names)
teammates = HTTParty.post("https://api.intercom.io/customers/search", 
   headers: { "Content-Type": "application/json",
              "Accept": "application/json",
              "Authorization": "Bearer #{ENV['UNSTABLE-TOKEN']}"
            },
   query: {
      "query": {
        "operator": "AND",
        "value": [
          { 
            "operator": "OR",
            "value": names.map{|name| query_name_inserter(name)}
          },
          "operator": "AND",
          "value": [
            {
              "field": "segment_id",
              "operator": "=",
              "value": "5d92336e9925897dd683c683"
            }
          ]
        ]
      },
   }
  )
  @names_hash = {}
  teammates.parsed_response["customers"].each{ |user|  @names_hash[user["name"].split()[0]] = user["id"] }
  return @names_hash

end

def get_currently_on_call_people
  # returns an array of people that have is_currently_on_call: true
  currently_on_call = HTTParty.post("https://api.intercom.io/customers/search", 
    headers: { "Content-Type": "application/json",
              "Accept": "application/json",
              "Authorization": "Bearer #{ENV['UNSTABLE-TOKEN']}"
            },
    query: {
      "query": {
        "field": "custom_attributes.on_call_currently",
        "operator": "=",
        "value": true
      }
    }
  ) 
  @currently_on_call_hash = {}
  currently_on_call.parsed_response["customers"].each{ |user|  @currently_on_call_hash[user["name"].split()[0]] = user["id"] }
  p @currently_on_call_hash
end

private def update_an_oncall_person_in_intercom()

end

# Lay out (method by method) what we need to build and send back when a messenger opens.
private def get_oncall_people_from_intercom()

end

private def build_oncall_app_response_canvas()

end



post '/live_canvas' do
  content_type 'application/json'
  my_response = get_conversation_count
  # make method to pull the cuurently on-call folks
  # change the logic the canvas/card uses to update the info based on aboved NOT based on slack topic becaue I can't use global variables. Unstable API version allows me to search by name, and by on-call role attribute directly.
 # find_people_in_intercom(extract_names_from_topic)


  cse_img = on_call_images_hash[extract_names_from_topic[0].to_sym] || on_call_images_hash["travolta".to_sym]
  css_img = on_call_images_hash[extract_names_from_topic[1].to_sym] || on_call_images_hash["travolta".to_sym]  
  bs_img = on_call_images_hash[extract_names_from_topic[2].to_sym] || on_call_images_hash["travolta".to_sym]

  text = "{\"content\":{\"components\":[{\"id\":\"ab1c31592d\",\"type\":\"text\",\"text\":\"#{my_response}\",\"style\":\"header\",\"align\":\"left\",\"bottom_margin\":false},{\"id\":\"ab1c31\",\"type\":\"text\",\"text\":\"#{updated_at}\",\"style\":\"header\",\"align\":\"left\",\"bottom_margin\":false},{\"type\":\"divider\"},{\"type\":\"list\",\"disabled\":false,\"items\":[{\"type\":\"item\",\"id\":\"on-call-list\",\"title\":\"CSE on call:\",\"subtitle\":\"#{extract_names_from_topic[0]}\",\"image\":\"#{cse_img}\",\"image_width\":48,\"image_height\":48,\"rounded_image\":true},{\"type\":\"item\",\"id\":\"on-call-list2\",\"title\":\"CSS on call:\",\"subtitle\":\"#{extract_names_from_topic[1]}\",\"image\":\"#{css_img}\",\"image_width\":48,\"image_height\":48,\"rounded_image\":true},{\"type\":\"item\",\"id\":\"on-call-list3\",\"title\":\"BS on call:\",\"subtitle\":\"#{extract_names_from_topic[2]}\",\"image\":\"#{bs_img}\",\"image_width\":48,\"image_height\":48,\"rounded_image\":true}]}]}}"
end



# OLD LOGIC
# ------------------


# $intercom = Intercom::Client.new(token: ENV['TOKEN'])
# $zone = Time.now.getlocal.zone

# get '/' do
# end

# post '/slack' do 
#   request_data = JSON.parse(request.body.read)
#   $channel_topic = "CSE on-call: #{request_data['event']['text']}"
#   status 200
#   get_real_user(extract_slack_ids)
# end

# def get_real_user(array_of_ids)
#   cse = HTTParty.post("https://slack.com/api/users.profile.get",
#     query: {token: ENV['SLACK-OAUTH'], user: array_of_ids[0], pretty: 1})
#   csr = HTTParty.post("https://slack.com/api/users.profile.get",
#     query: {token: ENV['SLACK-OAUTH'], user: array_of_ids[1], pretty: 1})
#   if cse.parsed_response['error']
#     $cse_name = "N/A"
#     $cse_img = "https://downloads.intercomcdn.com/i/o/102767128/61befae4699e11c05edf1661/shrug.png"
#   else
#     $cse_name = cse['profile']['real_name']
#     $cse_img = cse['profile']['image_192']
#   end
#   if csr.parsed_response['error']
#     $csr_name = "N/A"
#     $csr_img = "https://downloads.intercomcdn.com/i/o/102767128/61befae4699e11c05edf1661/shrug.png"
#   else
#     $csr_name = csr['profile']['real_name']
#     $csr_img = csr['profile']['image_192']
#   end 
# end

# def extract_slack_ids
#   cse_regex = $channel_topic.match(%r{CSE on call: <@(\w+)}m)
#   csr_regex = $channel_topic.match(%r{CSR on call: <@(\w+)}m)
#   cse_regex = cse_regex ? cse_regex.captures : ["fakeid"]
#   csr_regex = csr_regex ? csr_regex.captures : ["fakeid"]
#   return cse_regex + csr_regex
# end

# # Need to match this format: "*CSE*:  Tové | *CSS*: Ashlie | *Billing Specialist*: Ashlie"

# post '/' do
#   text = "{\"canvas\":{\"content_url\":\"https://evening-fortress-32801.herokuapp.com/live_canvas\"}}"
#   text
# end

# post '/live_canvas' do
#   content_type 'application/json'
#   $time = Time.now.strftime("%H:%M")
#   $updated_at = "Updated at: *#{$time}* *#{$zone}*"
#   $all_convos = $intercom.counts.for_type(type: 'conversation').conversation["open"]
#   $response = "Current ongoing conversations: *#{$all_convos}*"
  
#   if $all_convos == 0
#     $response = "Woot woot! On-call inbox is empty! 🥳"
#   end

#   if $all_convos >= 10
#     $response = "Current ongoing conversations: *#{$all_convos}*
#     Response time might be a bit longer 😅"
#   end

#   text = "{\"content\":{\"components\":[{\"id\":\"ab1c31592d\",\"type\":\"text\",\"text\":\"#{$response}\",\"style\":\"header\",\"align\":\"left\",\"bottom_margin\":false},{\"id\":\"ab1c31\",\"type\":\"text\",\"text\":\"#{$updated_at}\",\"style\":\"header\",\"align\":\"left\",\"bottom_margin\":false},{\"type\":\"divider\"},{\"type\":\"list\",\"disabled\":false,\"items\":[{\"type\":\"item\",\"id\":\"on-call-list\",\"title\":\"CSE on call:\",\"subtitle\":\"#{$cse_name}\",\"image\":\"#{$cse_img}\",\"image_width\":48,\"image_height\":48,\"rounded_image\":true},{\"type\":\"item\",\"id\":\"on-call-list2\",\"title\":\"CSR on call:\",\"subtitle\":\"#{$csr_name}\",\"image\":\"#{$csr_img}\",\"image_width\":48,\"image_height\":48,\"rounded_image\":true}]}]}}"
#   text
# end
