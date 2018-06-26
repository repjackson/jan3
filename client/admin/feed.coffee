if Meteor.isClient
    FlowRouter.route '/feed', 
        action: ->
            BlazeLayout.render 'layout', 
                main: 'feed'

    Template.feed.onCreated ->
        @autorun => Meteor.subscribe 'docs', [], 'event' 
    Template.feed.helpers
        feed_events: -> Docs.find {type:'event'}, sort:timestamp:-1


    Template.feed_event.onCreated ->
        @autorun => Meteor.subscribe 'parent_doc', @data._id
    Template.feed_event.events
        'click .remove_event': -> 
            if confirm 'Delete Event?'
                Docs.remove @_id

                
    Template.users_feed.onCreated ->
        @autorun => Meteor.subscribe 'users_feed', FlowRouter.getParam('username')

    Template.users_feed.helpers
        feed_events: -> Docs.find {type:'event'}, sort:timestamp:-1
    Template.users_feed_event.events
        'click .remove_event': -> 
            if confirm 'Delete User Event?'
                Docs.remove @_id

                
        