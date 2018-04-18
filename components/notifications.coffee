@Notifications = new Meteor.Collection 'notifications'


FlowRouter.route '/notifications', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'notifications'

if Meteor.isClient
    Template.notifications.onCreated -> 
        @autorun -> Meteor.subscribe('notifications')

    Template.notifications.helpers
        notifications: -> 
            Notifications.find { }
    
    Template.notification.events
        'click .edit': -> FlowRouter.go("/notification/edit/#{@_id}")

    Template.notifications.events
        # 'click #add_module': ->
        #     id = notifications.insert({})
        #     FlowRouter.go "/edit_module/#{id}"
    
    


if Meteor.isServer
    Notifications.allow
        insert: (userId, doc) -> Roles.userIsInRole(userId, 'admin')
        update: (userId, doc) -> Roles.userIsInRole(userId, 'admin')
        remove: (userId, doc) -> Roles.userIsInRole(userId, 'admin')
    
    
    
    
    Meteor.publish 'notifications', ()->
    
        self = @
        match = {}
        # selected_tags.push current_herd
        # match.tags = $all: selected_tags
        # if selected_tags.length > 0 then match.tags = $all: selected_tags

        

        Notifications.find match
    
    Meteor.publish 'notification', (id)->
        Notifications.find id
    
