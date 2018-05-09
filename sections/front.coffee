if Meteor.isClient
    FlowRouter.route '/front', action: ->
        BlazeLayout.render 'layout', 
            main: 'front'
    
    Template.front.onCreated ->
        @autorun => Meteor.subscribe 'facet', 
            selected_tags.array()
            selected_keywords.array()
            selected_author_ids.array()
            selected_location_tags.array()
            selected_timestamp_tags.array()
            type='feature'
            author_id=null
    
    Template.front.onRendered ->
        Meteor.setTimeout ->
            $('.ui.accordion').accordion()
        , 400

        Meteor.setTimeout ->
        #     $('.masthead').visibility
        #         once: false
        #         # onBottomPassed: ->
        #         #     $('.fixed.menu').transition 'fade in'
        #         #     console.log 'bottom passed'
        #         # onBottomPassedReverse: ->
        #         #     $('.fixed.menu').transition 'fade out'
        #         #     console.log 'bottom passed'
        # , 400

    
    Template.front.helpers
        features: -> Docs.find {type:'feature'}
        