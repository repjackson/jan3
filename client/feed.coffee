

Template.users_feed.onCreated ->
    @autorun => Meteor.subscribe 'users_feed', FlowRouter.getParam('username')

Template.users_feed.helpers
    user_feed_events: ->
        Docs.find {type:'event'}, sort:timestamp:-1
Template.users_feed_event.events
    'click .remove_event': ->
        if confirm 'Delete User Event?'
            Docs.remove @_id


Template.feed.onCreated ->
    @autorun => Meteor.subscribe 'type', 'event', 10

Template.feed.helpers
    feed_events: ->
        context = Template.currentData()
        # Docs.find {type:'event', doc_type:context.doc_type}, sort:timestamp:-1
        Docs.find {type:'event'}, sort:timestamp:-1


Template.feed.events
    'click .remove_event': ->
        if confirm 'Delete Event?'
            Docs.remove @_id




Template.small_doc_history.onCreated ->
    @autorun =>  Meteor.subscribe 'child_docs', @data._id, 1
Template.small_doc_history.helpers
    doc_history_events: ->
        cursor =
            Docs.find {
                parent_id: Template.currentData()._id
                type:'event'
            },
                sort:timestamp:-1
                limit: 1



Template.full_doc_history.onCreated ->
    @autorun =>  Meteor.subscribe 'child_docs', @data._id
    @autorun =>  Meteor.subscribe 'type', 'event_type'


Template.doc_history_event.onCreated ->
    @autorun =>  Meteor.subscribe 'user_profile', @data.author_id
Template.full_doc_history.helpers
    doc_history_events: ->
        Docs.find {
            parent_id: Template.currentData()._id
            type:'event'
        }, sort:timestamp:-1




Template.doc_history_event.events
    'click .remove_event': ->
        Docs.remove @_id

Template.doc_history_event.helpers
    is_escalation: -> @event_type is 'escalate'


# Template.full_doc_history.events
#     'click #clear_events':
#         doc_id = FlowRouter.getQueryParam('doc_id')
#         if confirm 'Clear all events? Irriversible.'
#             Meteor.call 'clear_ticket_events', doc_id
