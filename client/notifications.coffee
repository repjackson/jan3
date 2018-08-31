FlowRouter.route '/notifications', 
    name:'notifications'
    action: ->
        BlazeLayout.render 'layout', 
            main: 'notifications'


Template.notifications.onCreated ->
    # @autorun => Meteor.subscribe 'type', 'notification'
    @autorun => Meteor.subscribe 'count', 'notification'
    @autorun => Meteor.subscribe 'incomplete_notification_count'
    @autorun => Meteor.subscribe 'facet', 
        selected_tags.array()
        selected_author_ids.array()
        selected_location_tags.array()
        selected_timestamp_tags.array()
        type='notification'
        author_id=null


    
    

Template.notification_segment.onCreated ->
    # @autorun => Meteor.subscribe 'type', 'notification'
    # @autorun => Meteor.subscribe 'notification', @data._id


    
    
Template.notifications.helpers
    notifications: ->  Docs.find { type:'notification'}
