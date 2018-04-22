FlowRouter.route '/user/add', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        main: 'add_user'
 
 
if Meteor.isClient
    Template.add_user.onCreated ->
        # @autorun ->  Meteor.subscribe 'users'
    
    
    Template.add_user.helpers
        # users: -> Meteor.users.find {}
        unassigned_roles: ->
            role_list = [
                'admin'
                'desk'
                'staff'
                'resident'
                'owner'
                'board'
                ]
            _.difference role_list, @roles
            
    
    
    Template.add_user.events
        'click #add_person': ->
            username = $('#username').val().trim()
            first_name = $('#first_name').val().trim()
            last_name = $('#last_name').val().trim()
            email = $('#email').val().trim()
            Meteor.call 'create_user', username, first_name, last_name, email, (err,new_id)->
                console.log new_id
                FlowRouter.go "/profile/#{new_id}"
            
            
if Meteor.isServer
    Meteor.methods
        create_user: (username, first_name, last_name, email)->
            new_id = Accounts.createUser
                username: username
                profile:
                    first_name: first_name
                    last_name: last_name
                email: email
            return new_id