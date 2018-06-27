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
                Bert.alert "Redirecting to Dashboard.", 'info', 'growl-top-right'
                Bert.alert "Logged in #{Meteor.user().username}.", 'success', 'growl-top-right'
                
                FlowRouter.go '/'                
        # if e.which is 13 #enter
        #     # console.log comment