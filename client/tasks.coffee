FlowRouter.route '/tasks', action: ->
    BlazeLayout.render 'layout', 
        sub_nav: 'admin_nav'
        main: 'tasks'


Template.tasks.onCreated ->
    # @autorun => Meteor.subscribe 'type', 'task'
    @autorun => Meteor.subscribe 'count', 'task'
    @autorun => Meteor.subscribe 'incomplete_task_count'
    @autorun => Meteor.subscribe 'facet', 
        selected_tags.array()
        selected_author_ids.array()
        selected_location_tags.array()
        selected_timestamp_tags.array()
        type='task'
        author_id=null


    
Template.tasks.onRendered ->
    $('.indicating.progress').progress();
    

Template.task_segment.onCreated ->
    # @autorun => Meteor.subscribe 'type', 'task'
    # @autorun => Meteor.subscribe 'task', @data._id

    
Template.task_edit.onCreated ->
    # @autorun => Meteor.subscribe 'type', 'task'
    @autorun => Meteor.subscribe 'task', @data._id

    
Template.task_view.onCreated ->
    # @autorun => Meteor.subscribe 'type', 'task'
    @autorun => Meteor.subscribe 'task', @data._id

    
    
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


