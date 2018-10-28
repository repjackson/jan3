FlowRouter.route '/messaging',
    name:'messaging'
    action: ->
        BlazeLayout.render 'layout',
            main: 'messaging'



Template.inbox.onCreated ->
    @autorun -> Meteor.subscribe 'inbox'
Template.outbox.onCreated ->
    @autorun -> Meteor.subscribe 'outbox'

Template.inbox.helpers
    inbox_messages: ->
        Docs.find
            type:'message'
            to:Meteor.user().username

Template.outbox.helpers
    outbox_messages: ->
        Docs.find
            type:'message'
            author_username:Meteor.user().username


Template.wall.helpers
    wall_posts: -> Docs.find type:'wall_post'

Template.messaging.onRendered ->
    # Meteor.setTimeout ->
    #     $('.ui.accordion').accordion()
    # , 400

Template.messaging.events
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
