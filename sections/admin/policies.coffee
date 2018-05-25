if Meteor.isClient
    FlowRouter.route '/policies`', action: ->
        BlazeLayout.render 'layout', 
            sub_nav:'admin_nav'
            main: 'policies'
    
    Template.policies.onCreated ->
        @autorun => Meteor.subscribe 'facet', 
            selected_tags.array()
            selected_keywords.array()
            selected_author_ids.array()
            selected_location_tags.array()
            selected_timestamp_tags.array()
            type='policy'
            author_id=null
    
    Template.policies.onCreated ->
        Meteor.setTimeout ->
            $('.progress').progress()
        , 1000
        Meteor.setTimeout ->
            $('.ui.accordion').accordion()
        , 1000
    
    
    
    
    Template.policies.helpers
        policies: -> Docs.find type:'policy'
        
    Template.policies.events
        'keyup .policy_text': (e,t)->
            e.preventDefault()
            val = $('.policy_text').val().toLowerCase().trim()
            if e.which is 13 #enter
                Docs.update @_id,
                    $set: text: val
                Bert.alert "Updated Text", 'success', 'growl-top-right'
    
    Template.policy_card.events
        'click #turn_on': ->
            # console.log @complete
            Docs.update {_id:@_id}, 
                $set: complete: true
    
        'click #turn_off': ->
            # console.log @complete
            Docs.update {_id:@_id}, 
                $set: complete: false


        