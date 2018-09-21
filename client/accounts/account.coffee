FlowRouter.route '/account/settings', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'account_settings'
Template.account_settings.onCreated ->
    @autorun -> Meteor.subscribe 'my_profile', FlowRouter.getParam('user_id') 

# Template.account_settings.onRendered ->

Template.account_settings.helpers

Template.account_settings.events
    'click #change_username': ->
        new_username = $('#new_username').val().trim()
        user = Meteor.user()
        if new_username and user.username != new_username
            Meteor.call 'update_username', new_username

    'keydown #new_username': (e,t)->
        if e.which is 13
            new_username = $('#new_username').val().trim()
            user = Meteor.user()
            if new_username and user.username != new_username
                Meteor.call 'update_username', new_username
    
    
    'click #add_email': ->
        new_email = $('#new_email').val().trim()
        user = Meteor.user()
        
        re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
        valid_email = re.test(new_email)
        
        if valid_email
            Meteor.call 'update_email', new_email
                
    'click .send_verification_email': (e,t)->
        Meteor.call 'verify_email', Meteor.userId()
            
            
            
Template.change_password_widget.events
    'click #change_password': ->
        old_password = $('#old_password').val().trim()
        new_password = $('#new_password').val().trim()
        user = Meteor.user()
        if new_password
            Accounts.changePassword old_password, new_password

    'keydown #new_password': (e,t)->
        if e.which is 13
            old_password = $('#old_password').val().trim()
            new_password = $('#new_password').val().trim()
            user = Meteor.user()
            if new_password
                Accounts.changePassword old_password, new_password
            