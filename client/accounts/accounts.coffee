FlowRouter.route '/login', action: ->
    BlazeLayout.render 'layout', 
        main: 'login'
FlowRouter.route '/new_officer', action: ->
    BlazeLayout.render 'layout', 
        main: 'new_officer'
FlowRouter.route '/new_customer', action: ->
    BlazeLayout.render 'layout', 
        main: 'new_customer'
Template.login.events
    'click .login': (e,t)->
        e.preventDefault()
        # comment = $('#new_comment').val().trim()
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