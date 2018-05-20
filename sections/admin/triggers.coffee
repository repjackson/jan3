if Meteor.isClient
    FlowRouter.route '/triggers', action: ->
        BlazeLayout.render 'layout', 
            sub_nav:'admin_nav'
            main: 'triggers'
    
    Template.triggers.onCreated ->
        @autorun => Meteor.subscribe 'facet', 
            selected_tags.array()
            selected_keywords.array()
            selected_author_ids.array()
            selected_location_tags.array()
            selected_timestamp_tags.array()
            type='trigger'
            author_id=null
    
    Template.triggers.onCreated ->
        Meteor.setTimeout ->
            $('.progress').progress()
        , 1000
        Meteor.setTimeout ->
            $('.ui.accordion').accordion()
        , 1000
    
    
    
    
    Template.triggers.helpers
        triggers: -> Docs.find type:'trigger'
        
    Template.triggers.events
        'click .save_trigger': -> Session.set 'editing_id',null
        'click .edit_trigger': -> Session.set 'editing_id',@_id
        'keyup .trigger_text': (e,t)->
            e.preventDefault()
            val = $('.trigger_text').val().toLowerCase().trim()
            if e.which is 13 #enter
                Docs.update @_id,
                    $set: text: val
                Bert.alert "Updated Text", 'success', 'growl-top-right'
    
    Template.trigger_card.events
        'click #turn_on': ->
            # console.log @complete
            Docs.update {_id:@_id}, 
                $set: complete: true
    
        'click #turn_off': ->
            # console.log @complete
            Docs.update {_id:@_id}, 
                $set: complete: false


        