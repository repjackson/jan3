if Meteor.isClient
    Template.tasks.onCreated ->
        @autorun => Meteor.subscribe 'top_todos'

    Template.tasks.helpers
        todos: ->
            Docs.find {
                type:'task'
                assigned_ids: $in: [Meteor.userId()]
            }, limit:5

        item_class: ->
            delta = Docs.findOne type:'delta'
            if delta.viewing_detail and delta.detail_id is @_id then 'active' else ''

    Template.tasks.events
        'click .todo': ->
            delta = Docs.findOne type:'delta'
            Docs.update delta._id,
                $set:
                    viewing_detail: true
                    viewing_rightbar: false
                    detail_id: @_id
                    expand_id: @_id

if Meteor.isServer
    Meteor.publish 'top_todos', ->
        Docs.find {
            type:'task'
            assigned_ids: $in: [Meteor.userId()]
        }, limit: 5