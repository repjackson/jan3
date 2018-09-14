Template.comments.onCreated ->
    @autorun -> Meteor.subscribe 'comments', FlowRouter.getParam('doc_id')

Template.comments.helpers
    comments: -> Docs.find { parent_id:FlowRouter.getParam('doc_id'), type:'comment'}


Template.comments.onRendered ->
    # Meteor.setTimeout ->
    #     $('.ui.accordion').accordion()
    # , 400

Template.comments.events
    'keyup #new_comment': (e,t)->
        e.preventDefault()
        comment = $('#new_comment').val().trim()
        if e.which is 13 #enter
            $('#new_comment').val ''
            new_comment_id = 
                Docs.insert
                    type:'comment'
                    text:comment
                    parent_id: @_id
            Meteor.call 'create_alert', 'comment', @_id, new_comment_id, (err,res)->
                if err then console.error err
                else
    'click .delete_comment': ->
        if confirm 'delete comment?'
            Docs.remove @_id
            