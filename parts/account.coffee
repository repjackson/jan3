        
        
if Meteor.isClient
    Template.account_settings.onCreated ->
        @autorun -> Meteor.subscribe 'my_profile', FlowRouter.getParam('user_id') 
    
    # Template.account_settings.onRendered ->
    #     console.log Meteor.users.findOne(FlowRouter.getParam('user_id'))
    
    Template.account_settings.helpers
    
    Template.account_settings.events
        'click #change_username': ->
            new_username = $('#new_username').val().trim()
            user = Meteor.user()
            if new_username and user.username != new_username
                Meteor.call 'update_username', new_username, (error, result) ->
                    if error
                        # console.log 'updateUsername', error
                        Bert.alert "Error Updating Username: #{error.reason}", 'danger', 'growl-top-right'
                    else
                        Bert.alert result, 'success', 'growl-top-right'
                    return

        'keydown #new_username': (e,t)->
            if e.which is 13
                new_username = $('#new_username').val().trim()
                user = Meteor.user()
                if new_username and user.username != new_username
                    Meteor.call 'update_username', new_username, (error, result) ->
                        if error
                            # console.log 'updateUsername', error
                            Bert.alert "Error Updating Username: #{error.reason}", 'danger', 'growl-top-right'
                        else
                            Bert.alert result, 'success', 'growl-top-right'
                        return
        
        
        'click #add_email': ->
            new_email = $('#new_email').val().trim()
            user = Meteor.user()
            
            re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
            valid_email = re.test(new_email)
            
            if valid_email
                Meteor.call 'update_email', new_email, (error, result) ->
                    if error
                        # console.log 'updateUsername', error
                        Bert.alert "Error Adding Email: #{error.reason}", 'danger', 'growl-top-right'
                    else
                        Bert.alert result, 'success', 'growl-top-right'
                    return
                    
        'click .send_verification_email': (e,t)->
            Meteor.call 'verify_email', Meteor.userId(), ->
                Bert.alert 'Verification Email Sent', 'success', 'growl-top-right'
                