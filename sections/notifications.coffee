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
    

Meteor.methods
    # add_notification: (subject_id, predicate, object_id) ->
    #     new_id = Docs.insert
    #         type: 'notification'
    #         subject_id: subject_id
    #         predicate: predicate
    #         object_id: object_id
    #     return new_id


if Meteor.isClient
    Template.notifications.onCreated ->
        @autorun => Meteor.subscribe 'notifications', Meteor.userId()
        # @autorun => 
        #     Meteor.subscribe('facet', 
        #         selected_theme_tags.array()
        #         selected_author_ids.array()
        #         selected_location_tags.array()
        #         selected_intention_tags.array()
        #         selected_timestamp_tags.array()
        #         type = 'notification'
        #         author_id = null
        #         parent_id = null
        #         tag_limit = 20
        #         doc_limit = 10
        #         view_published = null
        #         view_read = Session.get('view_read')
        #         view_bookmarked = null
        #         view_resonates = null
        #         view_complete = null
        #         view_images = null
        #         view_lightbank_type = null
    
        #         )

    Template.notifications.helpers
        notifications: -> 
            Docs.find {
                type: 'notification'
                }, 
                sort: timestamp: -1
        
        
        # notifications_allowed: ->
        #     # console.log notification.permission
        #     if notification.permission is 'denied' or 'default' 
        #         # console.log 'notifications are denied'
        #         # return false
        #     if notification.permission is 'granted'
        #         # console.log 'yes granted'
        #         # return true
            
            
    Template.notifications.events
        'click #allow_notifications': ->
            notification.requestPermission()
        
        'click #mark_all_read': ->
            if confirm 'Mark all notifications read?'
                Docs.update {},
                    $addToSet: read_by: Meteor.userId()
                    
    Template.notification.helpers
        product_segment_class: -> if Meteor.userId() in @read_by then 'basic' else ''
        
        subject_name: -> if @subject_id is Meteor.userId() then 'You' else @subject().name()
        object_name: -> if @object_id is Meteor.userId() then 'you' else @object().name()


if Meteor.isServer
    publishComposite 'received_notifications', ->
        {
            find: ->
                Docs.find
                    type: 'notification'
                    recipient_id: Meteor.userId()
            children: [
                { find: (notification) ->
                    Meteor.users.find 
                        _id: notification.author_id
                    }
                ]    
        }
        
    publishComposite 'all_notifications', ->
        {
            find: ->
                Docs.find type: 'notification'
            children: [
                { find: (notification) ->
                    Meteor.users.find 
                        _id: notification.subject_id
                    }
                { find: (notification) ->
                    Meteor.users.find 
                        _id: notification.object_id
                    }
                ]    
        }
        
        
    publishComposite 'unread_notifications', ->
        {
            find: ->
                Docs.find
                    type: 'notification'
                    recipient_id: Meteor.userId()
                    read: false
            children: [
                { find: (notification) ->
                    Meteor.users.find 
                        _id: notification.author_id
                    }
                ]    
        }
        
        
    Meteor.publish 'notification_subjects', (selected_subjects)->
        self = @
        match = {}
        
        if selected_tags.length > 0 then match.tags = $all: selected_tags
        match.type = 'notification'

        cloud = Docs.aggregate [
            { $match: match }
            { $project: subject_id: 1 }
            { $group: _id: '$subject_id', count: $sum: 1 }
            { $match: _id: $nin: selected_subjects }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # console.log 'cloud, ', cloud
        cloud.forEach (notification_subject, i) ->
            self.added 'notification_subjects', Random.id(),
                name: notification_subject.name
                count: notification_subject.count
                index: i
    
        self.ready()
            
    
    # Meteor.publish 'usernames', (selectedTags, selectedUsernames, pinnedUsernames, viewMode)->
# Meteor.publish 'usernames', (selectedTags)->
    # self = @

    # match = {}
    # if selectedTags.length > 0 then match.tags = $all: selectedTags
    # # if selectedUsernames.length > 0 then match.username = $in: selectedUsernames

    # cloud = Docs.aggregate [
    #     { $match: match }
    #     { $project: username: 1 }
    #     { $group: _id: '$username', count: $sum: 1 }
    #     { $match: _id: $nin: selectedUsernames }
    #     { $sort: count: -1, _id: 1 }
    #     { $limit: 50 }
    #     { $project: _id: 0, text: '$_id', count: 1 }
    #     ]

    # cloud.forEach (username) ->
    #     self.added 'usernames', Random.id(),
    #         text: username.text
    #         count: username.count
    # self.ready()