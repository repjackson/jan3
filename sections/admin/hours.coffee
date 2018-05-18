if Meteor.isClient
    FlowRouter.route '/hours', action: ->
        BlazeLayout.render 'layout', 
            sub_nav:'admin_nav'
            main: 'hours'
    
    Template.hours.onCreated ->
        @autorun => Meteor.subscribe 'facet', 
            selected_tags.array()
            selected_keywords.array()
            selected_author_ids.array()
            selected_location_tags.array()
            selected_timestamp_tags.array()
            type='hour'
            author_id=null
    
    Template.hours.onCreated ->
        Meteor.setTimeout ->
            $('.progress').progress()
        , 1000
        Meteor.setTimeout ->
            $('.ui.accordion').accordion()
        , 1000
    
    
    
    
    Template.hours.helpers
        hours: -> Docs.find type:'hour'
        
    Template.hours.events
        'click .save_hour': -> Session.set 'editing_id',null
        'click .edit_hour': -> Session.set 'editing_id',@_id
        'keyup .hour_text': (e,t)->
            e.preventDefault()
            val = $('.hour_text').val().toLowerCase().trim()
            if e.which is 13 #enter
                Docs.update @_id,
                    $set: text: val
                Bert.alert "Updated Text", 'success', 'growl-top-right'
    
    Template.hour_card.events
        'click #turn_on': ->
            # console.log @complete
            Docs.update {_id:@_id}, 
                $set: complete: true
    
        'click #turn_off': ->
            # console.log @complete
            Docs.update {_id:@_id}, 
                $set: complete: false


        