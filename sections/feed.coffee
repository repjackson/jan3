if Meteor.isClient
    FlowRouter.route '/feed', 
        action: ->
            selected_timestamp_tags.clear()
            selected_keywords.clear()
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
        feed: -> Docs.find type:'event'
                