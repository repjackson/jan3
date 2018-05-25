Meteor.methods
    call_ev: ()->
        self = @
        @unblock()

        # doc = Docs.findOne doc_id
        # params =
        #     content: doc.incident_details,
        #     content_type: 'text/html',
        #     consumption_preferences: true,
        #     raw_scores: false
        # personality_insights.profile params, Meteor.bindEnvironment((err, response)->
        HTTP.call('post',"https://avalon.extraview.net/jan-pro/ExtraView/ev_api.action?user_id=zpeckham&password=jpi19&statevar=get_roles"
            , (err,res)->
                if err then console.log 'err', err
                else
                    console.log res.content
        )   
    # Meteor.startup ->
    # HTTP.call('get',"https://avalon.extraview.net/jan-pro/ExtraView/ev_api.action?user_id=zpeckham&password=jpi19&statevar=get_roles", (err,res)->
    # HTTP.call('get',"http://www.npr.org/rss/podcast.php?id=510307", (err,res)->
    #     if err then console.log 'err', err
    #     else
    #         console.log res
    # )   
    # try
    #     response = HTTP.call('get',"https://avalon.extraview.net/jan-pro/ExtraView/ev_api.action?user_id=zpeckham&password=jpi19&statevar=get_roles")
    #     # response = HTTP.get("http://www.google.com")
    #     result = xml2js.parseStringSync(response.content)
    #     console.log result
    #     # console.log(JSON.stringify(result,null,2))
    # catch error
    #     console.log error
    
    
        # HTTP.call( 'get', "https://avalon.extraview.net/jan-pro/ExtraView/ev_api.action?user_id=zpeckham&password=jpi19&statevar=get_heartbeat", {}, (err,res)->
        #     if err then console.log 'err', err
        #     else
        #         console.log res
        #         # {
        #             # user_id:'zpeckham'
        #             # password:'jpi19'
        #             # statevar:'get_heartbeat'
        #             # # id:'34245782'
        #             # # p_template_file:'file.html'
        #             # # username_display:'LAST'
        #             # # strict:'yes'
        #         # }, (err, response)->
        #         #     if err
        #         #         console.log "ERROR",err
        #         #     else
        #         #         console.log 'res',response
        #         #         # console.log(JSON.stringify(response, null, 2))
        #         )