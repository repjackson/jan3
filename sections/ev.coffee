if Meteor.isClient
    FlowRouter.route '/ev', 
        action: ->
            selected_timestamp_tags.clear()
            BlazeLayout.render 'layout', 
                main: 'ev'

    Template.ev.onCreated ->
        @autorun => Meteor.subscribe 'facet', 
            selected_tags.array()
            selected_keywords.array()
            selected_author_ids.array()
            selected_location_tags.array()
            selected_timestamp_tags.array()
            type='ev'
            author_id=null

    Template.ev.helpers
        # ev: -> Docs.find type:'ev'

    Template.ev.events
        'click .call_ev': ->
            Meteor.call 'call_ev', (err,res)->
                if err then console.error err
                else
                    console.log res
