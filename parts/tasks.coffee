if Meteor.isClient
    FlowRouter.route '/admin/tasks', action: ->
        BlazeLayout.render 'layout', 
            sub_nav:'admin_menu'
            main: 'tasks'
    
    Template.tasks.onCreated ->
        @autorun => Meteor.subscribe 'facet', 
            selected_tags.array()
            selected_keywords.array()
            selected_author_ids.array()
            selected_location_tags.array()
            selected_timestamp_tags.array()
            type='task'
            author_id=null
    
    Template.tasks.onCreated ->
        Meteor.setTimeout ->
            $('.progress').progress()
        , 1000
        Meteor.setTimeout ->
            $('.ui.accordion').accordion()
        , 1000
    
    
    
    
    Template.tasks.helpers
        tasks: -> Docs.find type:'task'
        editing_this_task: -> Session.equals 'editing_id', @_id
        
    Template.tasks.events
        'click .save_task': -> Session.set 'editing_id',null
        'click .edit_task': -> Session.set 'editing_id',@_id
        'keyup .task_text': (e,t)->
            e.preventDefault()
            val = $('.task_text').val().toLowerCase().trim()
            if e.which is 13 #enter
                Docs.update @_id,
                    $set: text: val
                Bert.alert "Updated Text", 'success', 'growl-top-right'
    
    Template.task_card.events
        'click #turn_on': ->
            # console.log @complete
            Docs.update {_id:@_id}, 
                $set: complete: true
    
        'click #turn_off': ->
            # console.log @complete
            Docs.update {_id:@_id}, 
                $set: complete: false


        