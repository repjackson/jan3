if Meteor.isClient
    FlowRouter.route '/automations', action: ->
        BlazeLayout.render 'layout', 
            sub_nav:'admin_nav'
            main: 'automations'
    
    Template.automations.onCreated ->
        @autorun => Meteor.subscribe 'facet', 
            selected_tags.array()
            selected_keywords.array()
            selected_author_ids.array()
            selected_location_tags.array()
            selected_timestamp_tags.array()
            type='automation'
            author_id=null
    
    Template.automations.onCreated ->
        Meteor.setTimeout ->
            $('.progress').progress()
        , 1000
        Meteor.setTimeout ->
            $('.ui.accordion').accordion()
        , 1000
    
    
    
    
    Template.automations.helpers
        automations: -> Docs.find type:'automation'
        
    Template.automations.events
        'click .save_automation': -> Session.set 'editing_id',null
        'click .edit_automation': -> Session.set 'editing_id',@_id
        'keyup .automation_text': (e,t)->
            e.preventDefault()
            val = $('.automation_text').val().toLowerCase().trim()
            if e.which is 13 #enter
                Docs.update @_id,
                    $set: text: val
                Bert.alert "Updated Text", 'success', 'growl-top-right'
    
    Template.automation_card.events
        'click #turn_on': ->
            # console.log @complete
            Docs.update {_id:@_id}, 
                $set: complete: true
    
        'click #turn_off': ->
            # console.log @complete
            Docs.update {_id:@_id}, 
                $set: complete: false


        