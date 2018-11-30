if Meteor.isClient
    Template.users.onCreated ->
        @autorun => Meteor.subscribe 'users' 

    Template.users.helpers
        users: ->   
            Meteor.users.find()


    Template.users.onRendered ->
        # Meteor.setTimeout ->
        #     $('.ui.accordion').accordion()
        # , 400

    Template.users.events
        'keyup #new_comment': (e,t)->
            delta = Docs.findOne type:'delta'
            if delta
                if e.which is 13
                    text = $('#new_comment').val().trim()
                    e.preventDefault()
                    $('#new_comment').val ''
                    new_comment_id =
                        Docs.insert
                            type:'comment'
                            text:text
                            parent_id: delta.detail_id
                    Docs.insert
                        type:'event'
                        text:"#{Meteor.user().username} commented: #{text}"
                        parent_id: delta.detail_id
                        event_type:'comment'


        'click .delete_comment': ->
            if confirm 'delete comment?'
                Docs.remove @_id

if Meteor.isServer
    Meteor.publish 'users', ()->
        Meteor.users.find {},
            limit:10
