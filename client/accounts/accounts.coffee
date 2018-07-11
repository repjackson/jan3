FlowRouter.route '/login', action: ->
    BlazeLayout.render 'layout', 
        sub_nav: 'accounts_nav'
        main: 'login'
FlowRouter.route '/register_officer', action: ->
    BlazeLayout.render 'layout', 
        sub_nav: 'accounts_nav'
        main: 'register_officer'
FlowRouter.route '/register_customer', action: ->
    BlazeLayout.render 'layout', 
        sub_nav: 'accounts_nav'
        main: 'register_customer'
FlowRouter.route '/reset_password', action: ->
    BlazeLayout.render 'layout', 
        sub_nav: 'accounts_nav'
        main: 'reset_password'
Template.login.events
    'click .login': (e,t)->
        e.preventDefault()
        # comment = $('#register_comment').val().trim()
        login = $('.username').val();
        password = $('.password').val();
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
            login = $('.username').val();
            password = $('.password').val();
            Meteor.loginWithPassword login, password, (err,res)->
                if err
                    console.log err
                else
                    Bert.alert "Logged in #{Meteor.user().username}. Redirecting to dashboard.", 'success', 'growl-top-right'
                    FlowRouter.go '/'                
            #     # console.log comment