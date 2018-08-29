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


    
Template.notifications.onRendered ->
    $('.indicating.progress').progress();
    

Template.notification_segment.onCreated ->
    # @autorun => Meteor.subscribe 'type', 'notification'
    # @autorun => Meteor.subscribe 'notification', @data._id

    
Template.notification_edit.onCreated ->
    # @autorun => Meteor.subscribe 'type', 'notification'
    @autorun => Meteor.subscribe 'notification', @data._id

    
Template.notification_view.onCreated ->
    # @autorun => Meteor.subscribe 'type', 'notification'
    @autorun => Meteor.subscribe 'notification', @data._id

    
    
Template.notifications.helpers
    notifications: ->  Docs.find { type:'notification'}

Template.notification_edit.helpers
    notification: -> Doc.findOne FlowRouter.getParam('doc_id')
    
Template.notification_edit.events
    'click #delete': ->
        template = Template.currentData()
        swal {
            title: 'Delete notification?'
            # text: 'Confirm delete?'
            type: 'error'
            animation: false
            showCancelButton: true
            closeOnConfirm: true
            cancelButtonText: 'Cancel'
            confirmButtonText: 'Delete'
            confirmButtonColor: '#da5347'
        }, =>
            doc = Docs.findOne FlowRouter.getParam('doc_id')
            # console.log doc
            Docs.remove doc._id, ->
                FlowRouter.go "/notifications"



