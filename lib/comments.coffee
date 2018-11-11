if Meteor.isClient
    Template.comments.onCreated ->
        @autorun => Meteor.subscribe 'comments', @data._id

    Template.comments.helpers
        comments: ->
            delta = Docs.findOne type:'delta'
            # if delta
            Docs.find
                parent_id:delta.detail_id,
                type:'comment'


    Template.comments.onRendered ->
        # Meteor.setTimeout ->
        #     $('.ui.accordion').accordion()
        # , 400

    Template.comments.events
        'keyup #new_comment': (e,t)->
            e.preventDefault()
            delta = Docs.findOne type:'delta'
            if delta
                text = $('#new_comment').val().trim()
                if e.which is 13 #enter
                    $('#new_comment').val ''
                    new_comment_id =
                        Docs.insert
                            type:'comment'
                            text:text
                            parent_id: delta.detail_id


        'click .delete_comment': ->
            if confirm 'delete comment?'
                Docs.remove @_id

if Meteor.isServer
    Meteor.publish 'comments', (doc_id)->
        Docs.find
            parent_id: doc_id
            type:'comment'

