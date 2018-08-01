FlowRouter.route '/user/:username', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'user_view'


Template.user_view.onCreated ->
    @autorun -> Meteor.subscribe 'user', FlowRouter.getParam('username')

Template.users_docs.onCreated ->
    @autorun -> Meteor.subscribe 'users_docs', FlowRouter.getParam('username')
Template.user_events.onCreated ->
    @autorun -> Meteor.subscribe 'user_events', FlowRouter.getParam('username')
    
Template.users_docs.helpers
    user_docs: ->
        page_user = Meteor.users.findOne username:FlowRouter.getParam('username')
        Docs.find
            author_id: page_user._id
Template.user_events.helpers
    user_events: ->
        page_user = Meteor.users.findOne username:FlowRouter.getParam('username')
        Docs.find
            type:'event'
            author_id: page_user._id

Template.user_view.helpers
    user: -> Meteor.users.findOne username:FlowRouter.getParam('username') 
    
    is_user: -> 
        if Meteor.user()
            FlowRouter.getParam('username') is Meteor.user().username
    

Template.user_view.events


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
    'click #refresh_user_jpids': ->
        Meteor.call 'refresh_user_jpids', FlowRouter.getParam('username'), (err,res)->
            if err 
                Bert.alert "#{err.reason}", 'danger', 'growl-top-right'
            # else
                # console.dir res
        