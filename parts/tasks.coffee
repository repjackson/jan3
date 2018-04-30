if Meteor.isClient
    FlowRouter.route '/admin/tasks', action: ->
        BlazeLayout.render 'layout', 
            sub_nav:'admin_menu'
            main: 'tasks'
    
    Template.tasks.onCreated ->
        @autorun -> Meteor.subscribe 'tasks'
    
    Template.tasks.helpers
        tasks: -> Docs.find type:'task'
        editing_this_task: -> Session.equals 'editing_id', @_id
        
    Template.tasks.events
        'click #new_task': -> Docs.insert type:'task'
        'click .save_task': -> Session.set 'editing_id',null
        'click .edit_task': -> Session.set 'editing_id',@_id
        'keyup .task_text': (e,t)->
            e.preventDefault()
            val = $('.task_text').val().toLowerCase().trim()
            if e.which is 13 #enter
                Docs.update @_id,
                    $set: text: val
                Bert.alert "Updated Text", 'success', 'growl-top-right'
    
    Template.task.events
        'click #turn_on': ->
            # console.log @complete
            Docs.update {_id:@_id}, 
                $set: complete: true
    
        'click #turn_off': ->
            # console.log @complete
            Docs.update {_id:@_id}, 
                $set: complete: false


if Meteor.isServer
    Meteor.publish 'tasks', ->
        Docs.find type:'task'
        
        
        