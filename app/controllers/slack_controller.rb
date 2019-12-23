class SlackController < ApplicationController
    def index
        conn = Faraday::Connection.new(:url => 'https://slack.com') do |builder|
            builder.use Faraday::Request::UrlEncoded  # リクエストパラメータを URL エンコードする
            builder.use Faraday::Response::Logger     # リクエストを標準出力に出力する
            builder.use Faraday::Adapter::NetHttp     # Net/HTTP をアダプターに使う
          end
        response = conn.get do |req|  
        req.url '/api/users.list'
        req.params[:token] = ENV['SLACK_BOT_USER_TOKEN']
        end
        info = JSON.parse(response&.body)
        members=info["members"]
        members.each do |member|
            @user=User.new(user_id:member["id"],name:member["name"],url:"https://mates-proile-web.herokuapp.com/users/#{member["name"]}")
            @user.save
        end
    end

    def create
        #p params
        @body = JSON.parse(request.body.read)
        case @body['type']
        when 'url_verification'
            render json: @body
        when 'event_callback'
            # ..
        end
        json_hash  = params[:slack]
        Body::TestService.new(json_hash).execute      
    end

    def new
        hash = JSON.parse(json_str)
        members=hash["members"]
        members.each do |member|
            @user=User.new(user_id:member["id"],name:member["name"])
            @user.save
        end
    end

end
