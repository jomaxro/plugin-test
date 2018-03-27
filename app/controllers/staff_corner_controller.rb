class StaffcornerController < ::ApplicationController
        skip_before_action :check_xhr, :redirect_to_login_if_required
        skip_before_action :require_login
    def mark_read
        pulseUserId = params[:pulseUserId]
        topicId = params[:topicId]
        sso_record = SingleSignOnRecord.where(external_id: pulseUserId).first
        #wsUrl = SiteSetting.pulse_ws_url
        # No record yet, so create it
        if (!sso_record)
            # Load Pulse roles
            #wsUrl = SiteSetting.pulse_ws_url
            res = Net::HTTP.post_form(URI('http://webservices.idtech.com/StaffCorner.asmx/GetUserInfoByUserID'), {'Authenticate' => '{REDACTED}', 'companyID' => '1', 'userID' => pulseUserId})
            data = XmlSimple.xml_in(res.body)
            userData = data['diffgram'][0]['Result'][0]['User'][0]
            email = userData['Email'][0]
            username = email
            name = userData['FirstName'][0]
#            user = User.create({email: email, name: User.suggest_name(name || username || email), username: UserNameSuggester.suggest(email || username || name)})
#            user.save
            user = User.where(:email => email).first
        end
        user = user || sso_record.user
        topic = Topic.find(topicId)
        if (!topic)
                render :json => {success: false, message: "Unknown topic"}
                return
        end
        topicUser = TopicUser.where(:user_id => user.id, :topic_id => topic.id).first
        if (!topicUser)
                topicUser = TopicUser.create(:user => user, :topic => topic, :last_read_post_number => topic.posts.last)
        end
        topicUser.last_read_post_number = topic.posts.last.id
        topicUser.save
        render :json => {success: true}
    end
    def test
        render text: "test"
    end
end
