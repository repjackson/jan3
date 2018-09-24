Template.comments.onCreated ->
    @autorun -> Meteor.subscribe 'comments', FlowRouter.getQueryParam('doc_id')

Template.comments.helpers
    comments: -> Docs.find { parent_id:FlowRouter.getQueryParam('doc_id'), type:'comment'}


Template.comments.onRendered ->
    # Meteor.setTimeout ->
    #     $('.ui.accordion').accordion()
    # , 400

Template.comments.events
    'keyup #new_comment': (e,t)->
        e.preventDefault()
        current_doc_id = FlowRouter.getQueryParam('doc_id')
        comment = $('#new_comment').val().trim()
        if e.which is 13 #enter
            $('#new_comment').val ''
            new_comment_id =
                Docs.insert
                    type:'comment'
                    text:comment
                    parent_id: current_doc_id
    'click .delete_comment': ->
        if confirm 'delete comment?'
            Docs.remove @_id
