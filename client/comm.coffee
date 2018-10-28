FlowRouter.route '/communication', action: ->
    BlazeLayout.render 'layout',
        main: 'communication'



Template.communication.onCreated ->
    @autorun -> Meteor.subscribe 'communication', FlowRouter.getQueryParam('doc_id')

Template.communication.helpers
    communication: -> Docs.find { parent_id:FlowRouter.getQueryParam('doc_id'), type:'comment'}


Template.communication.onRendered ->
    # Meteor.setTimeout ->
    #     $('.ui.accordion').accordion()
    # , 400

Template.communication.events
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
                    customer_jpid:Meteor.user().customer_jpid
                    office_jpid:Meteor.user().office_jpid


    'click .delete_comment': ->
        if confirm 'delete comment?'
            Docs.remove @_id
