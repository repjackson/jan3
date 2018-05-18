if Meteor.isClient
    FlowRouter.route '/rules', action: ->
        BlazeLayout.render 'layout', 
            sub_nav:'admin_nav'
            main: 'rules'
    
    Template.rules.onCreated ->
        @autorun => Meteor.subscribe 'facet', 
            selected_tags.array()
            selected_keywords.array()
            selected_author_ids.array()
            selected_location_tags.array()
            selected_timestamp_tags.array()
            type='rule'
            author_id=null
    
    Template.rules.onCreated ->
        Meteor.setTimeout ->
            $('.progress').progress()
        , 1000
        Meteor.setTimeout ->
            $('.ui.accordion').accordion()
        , 1000
    
    
    
    
    Template.rules.helpers
        rules: -> Docs.find type:'rule'
        
    Template.rules.events
        'click .save_rule': -> Session.set 'editing_id',null
        'click .edit_rule': -> Session.set 'editing_id',@_id
        'keyup .rule_text': (e,t)->
            e.preventDefault()
            val = $('.rule_text').val().toLowerCase().trim()
            if e.which is 13 #enter
                Docs.update @_id,
                    $set: text: val
                Bert.alert "Updated Text", 'success', 'growl-top-right'
    
    Template.rule_card.events
        'click #turn_on': ->
            # console.log @complete
            Docs.update {_id:@_id}, 
                $set: complete: true
    
        'click #turn_off': ->
            # console.log @complete
            Docs.update {_id:@_id}, 
                $set: complete: false


        