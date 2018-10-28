FlowRouter.route '/tasks', action: ->
    BlazeLayout.render 'layout',
        main: 'tasks'



Template.tasks.onCreated ->
    @autorun -> Meteor.subscribe 'type', 'task', 100

Template.tasks.helpers
    tasks: -> Docs.find type:'task'
    my_tasks: -> Docs.find type:'task'


Template.tasks.onRendered ->
    # Meteor.setTimeout ->
    #     $('.ui.accordion').accordion()
    # , 400

Template.tasks.events
    'click #new_task': (e,t)->
        Docs.insert
            type:'task'

    'click .delete_comment': ->
        if confirm 'delete comment?'
            Docs.remove @_id
