if Meteor.isClient
    FlowRouter.route '/feed', 
        action: ->
            selected_timestamp_tags.clear()
            BlazeLayout.render 'layout', 
                main: 'feed'

    Template.feed.onCreated ->
        @autorun => Meteor.subscribe 'facet', 
            selected_tags.array()
            selected_keywords.array()
            selected_author_ids.array()
            selected_location_tags.array()
            selected_timestamp_tags.array()
            type='event'
            author_id=null
    Template.feed.helpers
        feed_events: -> Docs.find type:'event'


    Template.feed_event.onCreated ->
        @autorun => Meteor.subscribe 'parent_doc', @data._id
    Template.feed_event.events
        'click .remove_event': -> 
            if confirm 'Delete Event?'
                Docs.remove @_id

                
                
                
                
                