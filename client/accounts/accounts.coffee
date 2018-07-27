FlowRouter.route '/login', action: ->
    BlazeLayout.render 'accounts_layout', 
        main: 'login'
FlowRouter.route '/register_officer', action: ->
    BlazeLayout.render 'accounts_layout', 
        main: 'register_officer'
FlowRouter.route '/register_customer', action: ->
    BlazeLayout.render 'accounts_layout', 
        main: 'register_customer'
FlowRouter.route '/reset_password', action: ->
    BlazeLayout.render 'accounts_layout', 
        main: 'reset_password'

Template.login.events
    'click .login': (e,t)->
        e.preventDefault()
        # comment = $('#register_comment').val().trim()
        login = $('.username').val()
        password = $('.password').val()
        Meteor.loginWithPassword login, password, (err,res)->
            if err
                console.log err
            else
                Bert.alert "Logged in #{Meteor.user().username}. Redirecting to dashboard.", 'success', 'growl-top-right'
                FlowRouter.go '/'                
        # if e.which is 13 #enter
    
    'keyup .password': (e,t)->
        if e.which is 13 #enter
            e.preventDefault()
            # comment = $('#register_comment').val().trim()
            login = $('.username').val()
            password = $('.password').val()
            Meteor.loginWithPassword login, password, (err,res)->
                if err
                    console.log err
                else
                    Bert.alert "Logged in #{Meteor.user().username}. Redirecting to dashboard.", 'success', 'growl-top-right'
                    FlowRouter.go '/'                
            
    'click #login_demo_admin': ->
        Meteor.loginWithPassword 'demo_admin', 'demoadminpassword', (err,res)->
            if err then console.error err
            else
                Bert.alert "Logged in #{Meteor.user().username}. Redirecting to dashboard.", 'success', 'growl-top-right'
                FlowRouter.go '/'                
            
    'click #login_demo_office': ->
        Meteor.loginWithPassword 'demo_office', 'demoofficepassword', (err,res)->
            if err then console.error err
            else
                Bert.alert "Logged in #{Meteor.user().username}. Redirecting to dashboard.", 'success', 'growl-top-right'
                FlowRouter.go '/'                
            
    'click #login_demo_customer': ->
        Meteor.loginWithPassword 'demo_customer', 'democustomerpassword', (err,res)->
            if err then console.error err
            else
                Bert.alert "Logged in #{Meteor.user().username}. Redirecting to dashboard.", 'success', 'growl-top-right'
                FlowRouter.go '/'                
            
        
        
Template.register_customer.onRendered ->
    Session.setDefault 'customer_jpid', null
        
        
Template.register_customer.helpers
    user_found: -> Session.get 'username_found'
    
    session_customer_jpid: -> Session.get 'customer_jpid'
    
    passwords_match: ->
        password_one = Session.get 'password_one'
        password_two = Session.get 'password_two'
        if password_one.length and password_one is password_two then true else false
        
    can_submit: ->
        # password_two = Session.get 'password_two'
        session_customer_jpid = Session.get 'customer_jpid'
        if Session.get('session_username') and Session.get('session_password_one') and Session.get('session_email') and Session.get('session_customer_jpid') then true else false
    
Template.register_customer.events
    # 'click #register': (e,t)->
    #     login = $('.username').val()
    #     password = $('.password').val()
    #     Meteor.createUser login, password, (err,res)->
    #         if err
    #             console.log err
    #         else
    #             Bert.alert "Logged in #{Meteor.user().username}. Redirecting to dashboard.", 'success', 'growl-top-right'
    #             FlowRouter.go '/'                
    
    'keyup #username': (e,t)->
        username = $('#username').val()
        Session.set 'session_username', username
        Meteor.call 'check_username', username, (err, res)->
            if err then console.error err
            else 
                if res
                    Session.set 'username_found', true
                else
                    Session.set 'username_found', false
        if e.which is 13 #enter
            password = $('#password').val()
            if username.length > 0 and password.length > 0
                Meteor.loginWithPassword login, password, (err,res)->
                    if err
                        console.log err
                    else
                        Bert.alert "Logged in #{Meteor.user().username}. Redirecting to dashboard.", 'success', 'growl-top-right'
                        FlowRouter.go '/'                
            
                
    'keyup #email': (e,t)->
        email = $('#email').val()
        if email.length > 0
            Session.set 'session_email', email
        Meteor.call 'check_email', email, (err, res)->
            if err then console.error err
            else 
                if res
                    Session.set 'email_found', res
                else
                    Session.set 'email_found', null
                
    'keyup #password_one': (e,t)->
        password_one = $('#password_one').val()
        Session.set 'session_password_one', password_one
        console.log password_one
                
    'keyup #password_two': (e,t)->
        password_two = $('#password_two').val()
        Session.set 'session_password_two', password_one
        console.log password_two
                
    'keyup #customer_jpid': (e,t)->
        customer_jpid = $('#customer_jpid').val()
        Session.set 'session_customer_jpid', customer_jpid
        # Meteor.call 'check_password_two', password_two, (err, res)->
        #     if err then console.error err
        #     else 
        #         if res
        #             Session.set 'email_found', res
        #         else
        #             Session.set 'email_found', null
                
    