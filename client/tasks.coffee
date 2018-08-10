FlowRouter.route '/tasks', action: ->
    BlazeLayout.render 'layout', 
        sub_nav: 'admin_nav'
        main: 'tasks'


Template.tasks.onCreated ->
    @autorun => Meteor.subscribe 'type', 'task'
    @autorun => Meteor.subscribe 'count', 'task'
    @autorun => Meteor.subscribe 'incomplete_task_count'
    
Template.tasks.onRendered ->
    $('.indicating.progress').progress();
    
    
    
Template.tasks.helpers
    tasks: ->  Docs.find { type:'task'}

Template.task_edit.helpers
    task: -> Doc.findOne FlowRouter.getParam('doc_id')
    
Template.task_edit.events
    'click #delete': ->
        template = Template.currentData()
        swal {
            title: 'Delete task?'
            # text: 'Confirm delete?'
            type: 'error'
            animation: false
            showCancelButton: true
            closeOnConfirm: true
            cancelButtonText: 'Cancel'
            confirmButtonText: 'Delete'
            confirmButtonColor: '#da5347'
        }, =>
            doc = Docs.findOne FlowRouter.getParam('doc_id')
            # console.log doc
            Docs.remove doc._id, ->
                FlowRouter.go "/tasks"



Template.mark_doc_complete_button.helpers
    # complete_button_class: -> if @complete then 'blue' else ''
Template.mark_doc_complete_button.events
    'click .mark_complete': (e,t)-> 
        if @complete is true
            Docs.update @_id, 
                $set: complete: false
            Meteor.call 'create_complete_task_event', @_id, 
        else  
            Docs.update @_id, 
                $set:complete: true
            Meteor.call 'create_incomplete_task_event', @_id, 
