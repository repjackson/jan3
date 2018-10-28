if Meteor.isClient
    FlowRouter.route '/tasks',
        name:'tasks'
        action: ->
            BlazeLayout.render 'layout',
                main: 'tasks'



    Template.tasks.onCreated ->
        @autorun -> Meteor.subscribe 'incomplete_tasks'
        @autorun -> Meteor.subscribe 'tasks_to_me'
        @autorun -> Meteor.subscribe 'tasks_by_me'
        @editing_id = new ReactiveVar null
        @viewing_id = new ReactiveVar null
        Session.setDefault 'viewing_task_id',null
        Session.setDefault 'editing',false
        Session.setDefault 'view_incomplete',true
        Session.setDefault 'view_complete',false
        Session.setDefault 'view_to_me',true
        Session.setDefault 'view_by_me',false

    Template.task_card.helpers
        task_card_class: ->
            if Session.equals('viewing_task_id',@_id) then 'raised blue' else 'secondary'


    Template.tasks.helpers
        editing: -> Session.get 'editing'
        viewing_task_id: -> Session.get 'viewing_task_id'
        viewing_task: ->
            Docs.findOne Session.get('viewing_task_id')

        incomplete_class: -> if Session.get('view_incomplete') then 'blue' else ''
        complete_class: -> if Session.get('view_complete') then 'blue' else ''
        by_me_class: -> if Session.get('view_by_me') then 'blue' else ''
        to_me_class: -> if Session.get('view_to_me') then 'blue' else ''


        task_docs: ->
            query = {type:'task'}
            if Session.get 'view_incomplete'
                query.complete = $ne:true
            else if Session.get 'view_complete'
                query.complete = true
            if Session.get 'view_by_me'
                query.assigned_by = Meteor.user().username
            if Session.get 'view_to_me'
                query.assigned_to = Meteor.user().username
            Docs.find query


    Template.tasks.onRendered ->
        # Meteor.setTimeout ->
        #     $('.ui.accordion').accordion()
        # , 400
    Template.task_card.events
        'click .task_card': ->
            Session.set 'viewing_task_id', @_id

    Template.tasks.events
        'click #new_task': (e,t)->
            new_id = Docs.insert
                type:'task'
            Session.set('editing_task', true)
            Session.set('viewing_task_id',new_id)

        'click .toggle_incomplete': -> Session.set('view_incomplete', !Session.get('view_incomplete'))
        'click .toggle_complete': -> Session.set('view_complete', !Session.get('view_complete'))
        'click .toggle_to_me': -> Session.set('view_to_me', !Session.get('view_to_me'))
        'click .toggle_by_me': -> Session.set('view_by_me', !Session.get('view_by_me'))

        'click .mark_complete': ->
            Docs.update @_id,
                $set: complete: true

        'click .mark_incomplete': ->
            Docs.update @_id,
                $set: complete: false


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


    Meteor.publish 'tasks_by_me',  ->
        if Meteor.user()
            Docs.find
                type:'task'
                assigned_by:Meteor.user().username


