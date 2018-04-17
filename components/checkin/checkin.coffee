FlowRouter.route '/checkin', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'checkin'



if Meteor.isClient
    Session.setDefault 'selected_member_id', null
    
    
    Template.checkin.onCreated ->
        @autorun -> Meteor.subscribe 'users'
        @autorun -> Meteor.subscribe 'checkedin_users'
    
    Template.checkin.onCreated ->
        Session.set 'selected_member_id', null
    
    
    Template.checkin.helpers
        checked_in_users: ->
            Meteor.users.find
                "profile.checkedin": true

    
    
        member_name_settings: -> {
            position: 'bottom'
            limit: 10
            rules: [
                {
                    collection: Meteor.users
                    field: 'username'
                    matchAll: true
                    template: Template.tag_result
                }
                ]
        }
    
        submit_button_class: ->
            if Session.get 'selected_member_id' then '' else 'disabled'
    
        selection: -> Session.get 'selected_member_id'
        
        selection_image_id: ->
            if Session.get 'selected_member_id'
                Meteor.users.findOne(Session.get('selected_member_id'))?.image_id
    
    
    Template.checkin.events
        'click #check_in_member': ->
            username = $('#member_name').val()
            user = Meteor.users.findOne username: username
            # console.log user
            
            Meteor.call 'check_in_user', user._id, (err,res)->
                if err then console.error err
                else
                    swal {
                        title: "Signed In #{username}"
                        # animation: false
                        type: 'success'
                        showCancelButton: false
                        # confirmButtonColor: '#DD6B55'
                        confirmButtonText: 'Ok'
                        closeOnConfirm: true
                        }, ->
                        #     FlowRouter.go "/profile/#{user._id}"
            
        'click .sign_out_user': ->
            swal {
                title: "Sign Out #{@username}?"
                animation: false
                type: 'info'
                showCancelButton: true
                # confirmButtonColor: '#DD6B55'
                confirmButtonText: 'Sign Out'
                # closeOnConfirm: true
                }, =>
                    Meteor.call 'check_out_user', @_id, (err,res)=>
                        if err then console.error err
                        else
                            swal {
                                title: "Signed Out #{@username}"
                                animation: false
                                type: 'success'
                                showCancelButton: false
                                # confirmButtonColor: '#DD6B55'
                                confirmButtonText: 'Ok'
                                closeOnConfirm: true
                                }

            
            
        'autocompleteselect #member_name': (event, template, doc) ->
            # console.log 'selected ', doc
            Session.set 'selected_member_id', doc._id

        'click #clear_selection': ->
            $('#member_name').val('')
            Session.clear 'selected_member_id'
            
if Meteor.isServer
    Meteor.methods
        check_in_user: (user_id)->
            Meteor.users.update user_id,
                $set:"profile.checkedin": true
                
        check_out_user: (user_id)->
            Meteor.users.update user_id,
                $set:"profile.checkedin": false
                
    Meteor.publish 'checkedin_users', ->
        Meteor.users.find
            "profile.checkedin": true
                