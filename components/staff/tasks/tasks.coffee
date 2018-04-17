if Meteor.isClient
    FlowRouter.route '/tasks', action: ->
        BlazeLayout.render 'layout', 
            sub_nav: 'staff_nav'
            main: 'tasks'
            
            
    FlowRouter.route '/task/edit/:doc_id', action: ->
        BlazeLayout.render 'layout', 
            main: 'edit_task'
    
    
    Template.task.onRendered ->
        Meteor.setTimeout (->
            $('.shape').shape()
        ), 500
    
    
    Template.tasks.onCreated ->
        @autorun -> Meteor.subscribe 'docs', selected_tags.array(), 'task'
    
    Template.tasks.onRendered ->
        # Meteor.setTimeout (->
        #     $('table').tablesort()
        #     # $('select.dropdown').dropdown()
        # ), 500



    Template.edit_task.onCreated ->
        @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
        @autorun -> Meteor.subscribe 'docs', [], 'building'
    
         
    Template.tasks.helpers
        tasks: -> Docs.find { type: 'task' }
         
    Template.edit_task.helpers
        buildings: ->
            Docs.find type: 'building'
         
        building_numbers: ->
            # console.log @
            building = Docs.findOne 
                building_code: @lock_building_code
                type: 'building'
            # console.log building
            if building then building.building_numbers
    
    
    Template.tasks.events
        'click #add_task': ->
            # alert 'hi'
            id = Docs.insert type:'task'
            FlowRouter.go "/task/edit/#{id}"
    
    Template.task.events
        'click .flip_shape': (e,t)->
            $(e.currentTarget).closest('.shape').shape('flip over');
            # console.log $(e.currentTarget).closest('.shape').shape('flip up')
            # $('.shape').shape('flip up')

    
    Template.edit_task.helpers
        task: -> 
            doc_id = FlowRouter.getParam('doc_id')
            # console.log doc_id
            Docs.findOne doc_id 



    Template.edit_task.events
        'click #delete_task': (e,t)->
            swal {
                title: 'Delete task?'
                text: 'Cannot be undone.'
                type: 'error'
                animation: false
                showCancelButton: true
                closeOnConfirm: true
                cancelButtonText: 'Cancel'
                confirmButtonText: 'Delete'
                confirmButtonColor: '#da5347'
            }, ->
                Docs.remove FlowRouter.getParam('doc_id'), ->
                    FlowRouter.go "/tasks"

        'blur #description': (e,t)->
            description = $(e.currentTarget).closest('#description').val()
            Docs.update @_id,
                $set: description: description

        'blur #complete_date': (e,t)->
            complete_date = $(e.currentTarget).closest('#complete_date').val()
            Docs.update @_id,
                $set: complete_date: complete_date

        'blur #location': (e,t)->
            location = $(e.currentTarget).closest('#location').val()
            Docs.update @_id,
                $set: location: location
