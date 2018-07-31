FlowRouter.route '/login',
    name: 'login'
    action: ->
        BlazeLayout.render 'accounts_layout', main: 'login'
FlowRouter.route '/register',
    name: 'register'
    action: ->
        BlazeLayout.render 'accounts_layout', main: 'register'
FlowRouter.route '/reset_password',
    name: 'reset_password'
    action: ->
        BlazeLayout.render 'accounts_layout', main: 'reset_password'
    
    
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
            
        
        
Template.register.onRendered ->
    Session.setDefault 'customer_jpid', null
    Session.setDefault 'office_jpid', null
    Session.setDefault 'account_selected', false
    Session.setDefault 'user_type_selection', 'customer'    
        
Template.register.helpers
    user_found: -> Session.get 'username_found'
    
    session_customer_jpid: -> Session.get 'customer_jpid'
    session_office_jpid: -> Session.get 'office_jpid'
    jpid_lookup_status: -> Session.get 'jpid_lookup_status'
    
    current_user_type_selection: -> Session.get 'user_type_selection'
    
    customer_button_class: -> if Session.equals('user_type_selection', 'customer') then 'blue' else ''
    office_button_class: -> if Session.equals('user_type_selection', 'office') then 'blue' else ''
    
    customer_selected: -> if Session.equals('user_type_selection', 'customer') then true else false
    office_selected: -> if Session.equals('user_type_selection', 'office') then true else false
    
    # account_selected: -> Session.get('account_selected')
    account_selected:  -> true
    
    passwords_match: ->
        password_one = Session.get 'password_one'
        password_two = Session.get 'password_two'
        if password_one.length and password_one is password_two then true else false
        
    can_submit: ->
        true
        # # password_two = Session.get 'password_two'
        # session_customer_jpid = Session.get 'customer_jpid'
        # if Session.get('session_username') and Session.get('session_password_one') and Session.get('session_email') and Session.get('session_customer_jpid') then true else false
    
Template.register.events
    'click #register': (e,t)->
        username = $('#username').val()
        password = $('#password').val()
        email = $('#email').val()
        office_id = $('#office_id').val()
        customer_jpid = $('#customer_jpid').val()
        
        current_role = Session.get 'user_type_selection'
        
        
        console.log username
        console.log password
        console.log email
        console.log customer_jpid

        
        options = {
            username:username
            password:password
            email:email
            customer_jpid:customer_jpid
            roles: [current_role]
        }
            
        
        Accounts.createUser(options, (err,res)->
            if err
                Bert.alert "Error Registering in #{username}: #{err.reason}", 'info', 'growl-top-right'
            else
                Bert.alert "Registered #{username}. Redirecting to dashboard.", 'success', 'growl-top-right'
                FlowRouter.go '/'                
        )
    
    'click #select_customer': -> Session.set 'user_type_selection', 'customer'
    'click #select_office': -> Session.set 'user_type_selection', 'office'
    
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
        Meteor.call 'find_customer_by_jpid', customer_jpid, (err,res)->
            if err 
                Session.set 'jpid_lookup_status', err.error
            else
                Session.set 'account_selected', true
                Session.set 'customer_jpid', res.ev.ID
                console.log Session.get 'customer_jpid'
                Session.set 'jpid_lookup_status', "Found JPID #{customer_jpid}."
                
        found_customer_doc = 
            Docs.findOne 
                type:'customer'
                "ev.ID": customer_jpid
            
        # if found_customer_doc
        #     console.log 'account selected'
        # else 
        #     Session.set 'account_selected', false
        #     console.log 'no account selected'
    
    'keyup #office_jpid': (e,t)->
        office_jpid = $('#office_jpid').val()
        Session.set 'office_jpid', office_jpid
        found_office_doc = 
            Docs.findOne 
                type:'office'
                "ev.ID": office_jpid
            
        if found_office_doc
            Session.set 'account_selected', true
            console.log 'account selected'
        else 
            Session.set 'account_selected', false
            console.log 'no account selected'
        # Meteor.call 'check_password_two', password_two, (err, res)->
        #     if err then console.error err
        #     else 
        #         if res
        #             Session.set 'email_found', res
        #         else
        #             Session.set 'email_found', null
                
    