Meteor.methods
    call_ev: ()->
        self = @
        
        res = HTTP.call('GET',"http://avalon.extraview.net/jan-pro-sandbox/ExtraView/ev_api.action?user_id=JPI&password=JPI&statevar=GET_REPORTS",
            headers:
                "User-Agent": "Meteor/1.0"
        #     , (err,res)->
        #         if err then console.log 'err', err
        #         else
        #             # console.log res
        #             payload = res.content
        #             return payload
        )   
        # return res.content
        split_res = res.content.split '\r\n'
        console.log split_res
