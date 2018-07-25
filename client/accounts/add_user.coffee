FlowRouter.route '/user/add', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        main: 'add_user'
Template.add_user.onCreated ->
    # @autorun ->  Meteor.subscribe 'users'


Template.add_user.helpers
    # users: -> Meteor.users.find {}
    unassigned_roles: ->
        role_list = [
            'admin'
            'office'
            'customer'
            ]
        _.difference role_list, @roles
        


Template.add_user.events
    'click #add_person': ->
        options = {}
        
        options.username = $('#username').val().trim()
        options.first_name = $('#first_name').val().trim()
        options.last_name = $('#last_name').val().trim()
        options.password = $('#password').val().trim()
        options.email = $('#email').val().trim()
        
        
        Accounts.createUser options, (err,res)=>
            if err
                Bert.alert "Error creating user: #{error.reason}", 'danger', 'growl-top-right'
            else
                Bert.alert "Logged in #{options.username}. Redirecting to profile page.", 'success', 'growl-top-right'
                FlowRouter.go "/user/#{options.username}"                
        