if Meteor.isClient
    FlowRouter.route '/conditions', action: ->
        BlazeLayout.render 'layout', 
            sub_nav:'dev_nav'
            main: 'conditions'
    
    Template.conditions.onCreated ->
        @autorun => Meteor.subscribe 'facet', 
            selected_tags.array()
            selected_keywords.array()
            selected_author_ids.array()
            selected_location_tags.array()
            selected_timestamp_tags.array()
            type='condition'
            author_id=null
    
    Template.conditions.onCreated ->
        Meteor.setTimeout ->
            $('.progress').progress()
        , 1000
        Meteor.setTimeout ->
            $('.ui.accordion').accordion()
        , 1000
    
    
    
    
    Template.conditions.helpers
        conditions: -> Docs.find type:'condition'
        
    Template.conditions.events
        'click .condition': -> Session.set 'editing_id',null
        'click .condition': -> Session.set 'editing_id',@_id
        'keyup .condition_text': (e,t)->
            e.preventDefault()
            val = $('.condition_text').val().toLowerCase().trim()
            if e.which is 13 #enter
                Docs.update @_id,
                    $set: text: val
                Bert.alert "Updated Text", 'success', 'growl-top-right'
    
    Template.condition_card.events
        'click #turn_on': ->
            # console.log @complete
            Docs.update {_id:@_id}, 
                $set: complete: true
    
        'click #turn_off': ->
            # console.log @complete
            Docs.update {_id:@_id}, 
                $set: complete: false


        