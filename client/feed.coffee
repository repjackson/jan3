FlowRouter.route '/feed', 
    action: ->
        BlazeLayout.render 'layout', 
            main: 'global_feed'

Template.global_feed.onCreated ->
Template.global_feed.helpers
    # feed_events: -> Docs.find {type:'event'}, sort:timestamp:-1
    # settings: ->
    #     collection: 'events'
    #     rowsPerPage: 10
    #     showFilter: true
    #     showRowCount: true
    #     # showColumnToggles: true
    #     fields: [
    #         { key: 'author_id', label: 'Author', tmpl:Template.author_info }
    #         { key: 'text', label: 'Text' }
    #         { key: 'action', label: 'Action' }
    #         # { key: 'parent_id', label: 'Parent Link', tmpl:Template.parent_link }
    #         { key: 'timestamp', label: 'Logged', tmpl:Template.when_template }
    #         { key: 'timestamp_tags', label: 'Time Tags' }
    #         { key: '', label: 'Mark Read', tmpl:Template.mark_read_link }
    #         { key: '', label: 'View', tmpl:Template.view_button }
    #     ]


# Template.feed_event.onCreated ->
#     @autorun => Meteor.subscribe 'parent_doc', @data._id
# Template.feed_event.events
#     'click .remove_event': -> 
#         if confirm 'Delete Event?'
#             Docs.remove @_id

            
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
    @autorun => Meteor.subscribe 'events', @data.doc_type

Template.feed.helpers
    event_docs: -> 
        context = Template.currentData()
        Docs.find {type:'event', doc_type:context.doc_type}, sort:timestamp:-1
Template.feed.events
    'click .remove_event': -> 
        if confirm 'Delete Event?'
            Docs.remove @_id

            
    