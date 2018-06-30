FlowRouter.route '/user/:username', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'user_view'


Template.user_view.onCreated ->
    @autorun -> Meteor.subscribe('user', FlowRouter.getParam('username'))
    

Template.user_view.helpers
    user: -> Meteor.users.findOne username:FlowRouter.getParam('username') 
    

Template.user_view.events


# ev users
Template.users.events
    'click .sync_ev_users': ->
        Meteor.call 'sync_ev_users',(err,res)->
            if err then console.error err
Template.users.helpers
    selector: ->  type: "user"

Template.user_view.events
    'click .get_user_info': ->
        Meteor.call 'get_user_info', FlowRouter.getParam('username'), (err,res)->
            if err 
                Bert.alert "#{err.reason}", 'danger', 'growl-top-right'
            # else
                # console.dir res
