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
                console.log res
        # if e.which is 13 #enter
        #     # console.log comment