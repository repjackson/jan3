if Meteor.isClient
    FlowRouter.route '/tasks',
        name:'tasks'
        action: ->
            BlazeLayout.render 'layout',
                main: 'tasks'



    Template.tasks.onCreated ->
        @autorun -> Meteor.subscribe 'incomplete_tasks'
        @autorun -> Meteor.subscribe 'tasks_to_me'
        @autorun -> Meteor.subscribe 'tasks_from_me'
        @editing_id = new ReactiveVar null
        @viewing_id = new ReactiveVar null
        Session.setDefault 'viewing_task_id',null
        Session.setDefault 'editing',false

    Template.task_segment.helpers
        task_segment_class: ->
            if Session.equals('viewing_task_id',@_id) then 'raised' else 'secondary'


    Template.tasks.helpers
        editing: -> Session.get 'editing'
        viewing_task_id: -> Session.get 'viewing_task_id'
        viewing_task: ->
            Docs.findOne Session.get('viewing_task_id')
        incomplete_tasks: ->
            if Meteor.user()
                Docs.find
                    type:'task'
                    complete:$ne:true
                    assigned_to:Meteor.user().username

        tasks_to_me: ->
            if Meteor.user()
                Docs.find
                    type:'task'
                    assigned_to:Meteor.user().username

        tasks_from_me: ->
            if Meteor.user()
                Docs.find
                    type:'task'
                    assigned_from:Meteor.user().username


    Template.tasks.onRendered ->
        # Meteor.setTimeout ->
        #     $('.ui.accordion').accordion()
        # , 400
    Template.task_segment.events
        'click .task_segment': ->
            Session.set 'viewing_task_id', @_id

    Template.tasks.events
        'click #new_task': (e,t)->
            new_id = Docs.insert
                type:'task'
            t.editing_id.set new_id
            t.viewing_id.set new_id

        'click .delete_comment': ->
            if confirm 'delete comment?'
                Docs.remove @_id

        'click .close_pane': ->
            Session.set 'viewing_task_id', null

if Meteor.isServer
    Meteor.publish 'incomplete_tasks',  ->
        if Meteor.user()
            Docs.find
                type:'task'
                complete:$ne:true
                assigned_to:Meteor.user().username

    Meteor.publish 'tasks_to_me',  ->
        if Meteor.user()
            Docs.find
                type:'task'
                assigned_to:Meteor.user().username


    Meteor.publish 'tasks_from_me',  ->
        if Meteor.user()
            Docs.find
                type:'task'
                assigned_by:Meteor.user().username


