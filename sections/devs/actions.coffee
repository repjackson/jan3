if Meteor.isClient
    FlowRouter.route '/actions', action: ->
        BlazeLayout.render 'layout', 
            sub_nav:'dev_nav'
            main: 'actions'
    
    Template.actions.onCreated ->
        @autorun => Meteor.subscribe 'facet', 
            selected_tags.array()
            selected_keywords.array()
            selected_author_ids.array()
            selected_location_tags.array()
            selected_timestamp_tags.array()
            type='action'
            author_id=null
    
    Template.actions.onCreated ->
        Meteor.setTimeout ->
            $('.progress').progress()
        , 1000
        Meteor.setTimeout ->
            $('.ui.accordion').accordion()
        , 1000
    
    
    
    
    Template.actions.helpers
        actions: -> Docs.find type:'action'
        
    Template.actions.events
        'click .action': -> Session.set 'editing_id',null
        'click .action': -> Session.set 'editing_id',@_id
        'keyup .action_text': (e,t)->
            e.preventDefault()
            val = $('.action_text').val().toLowerCase().trim()
            if e.which is 13 #enter
                Docs.update @_id,
                    $set: text: val
                Bert.alert "Updated Text", 'success', 'growl-top-right'
    
    Template.action_card.events
        'click #turn_on': ->
            # console.log @complete
            Docs.update {_id:@_id}, 
                $set: complete: true
    
        'click #turn_off': ->
            # console.log @complete
            Docs.update {_id:@_id}, 
                $set: complete: false


        