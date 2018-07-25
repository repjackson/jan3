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
            
        
Template.register_customer.helpers
    user_found: -> Session.get 'username_found'
    
    passwords_match: ->
        password_one = Session.get 'password_one'
        password_two = Session.get 'password_two'
        if password_one.length and password_one is password_two then true else false
        
    can_submit: ->
        login = $('.username').val()
        email = $('.email').val()
        customer_jpid = $('.customer_jpid').val()
        password_one = Session.get 'password_one'
        password_two = Session.get 'password_two'
        if login and password and customer_jpid and password_one and password_two then true else false
    
Template.register_customer.events
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
    
    'keyup .username': (e,t)->
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
            #     # console.log comment
            
    'blur .username': (e,t)->
        # comment = $('#register_comment').val().trim()
        username = $('.username').val()
        console.log username   
    
    'keyup .username': (e,t)->
        e.preventDefault()
        # comment = $('#register_comment').val().trim()
        username = $('.username').val()
        Meteor.call 'check_username', username, (err, res)->
            if err then console.error err
            else 
                if res
                    Session.set 'username_found', res
                else
                    Session.set 'username_found', null
                
    'keyup .email': (e,t)->
        e.preventDefault()
        # comment = $('#register_comment').val().trim()
        email = $('.email').val()
        console.log email
        Meteor.call 'check_email', email, (err, res)->
            if err then console.error err
            else 
                if res
                    Session.set 'email_found', res
                else
                    Session.set 'email_found', null
                
    'keyup .password_one': (e,t)->
        e.preventDefault()
        # comment = $('#register_comment').val().trim()
        password_one = $('.password_one').val()
        Session.set 'password_one', password_one
        console.log password_one
                
    'keyup .password_two': (e,t)->
        e.preventDefault()
        # comment = $('#register_comment').val().trim()
        password_two = $('.password_two').val()
        Session.set 'password_two', password_two
        console.log password_two
        # Meteor.call 'check_password_two', password_two, (err, res)->
        #     if err then console.error err
        #     else 
        #         if res
        #             Session.set 'email_found', res
        #         else
        #             Session.set 'email_found', null
                
    