if Meteor.isClient
    FlowRouter.route '/user/:username',
        name:'user_view'
        action: (params) ->
            BlazeLayout.render 'layout',
                main: 'user_view'


    Template.user_view.onCreated ->
        @autorun -> Meteor.subscribe 'user', FlowRouter.getQueryParam('username')


    Template.users_docs.onCreated ->
        @autorun -> Meteor.subscribe 'users_docs', FlowRouter.getQueryParam('username')
    Template.users_docs.helpers
        user_docs: ->
            page_user = Meteor.users.findOne username:FlowRouter.getQueryParam('username')
            Docs.find
                author_id: page_user._id


    Template.user_events.onCreated ->
        @autorun -> Meteor.subscribe 'user_events', FlowRouter.getQueryParam('username')
        @autorun -> Meteor.subscribe 'type', 'event_type'
    Template.user_events.helpers
        user_events: ->
            page_user = Meteor.users.findOne username:FlowRouter.getQueryParam('username')
            Docs.find
                type:'event'
                author_id: page_user._id

    Template.user_view.helpers
        user: -> Meteor.users.findOne username:FlowRouter.getQueryParam('username')
        is_user: ->
            if Meteor.user()
                FlowRouter.getQueryParam('username') is Meteor.user().username


    Template.user_view.events
        'click .get_user_info': ->
            Meteor.call 'get_user_info', FlowRouter.getQueryParam('username')
        'click #refresh_customer_jpids': ->
            Meteor.call 'refresh_customer_jpids', FlowRouter.getQueryParam('username')




    Template.user_view_comments.onCreated ->
        @autorun -> Meteor.subscribe 'user_view_comments', FlowRouter.getQueryParam('username')
    Template.user_view_comments.onRendered ->
    Template.user_view_comments.helpers
        comment_docs: ->
            user = Meteor.users.findOne username: FlowRouter.getQueryParam('username')
            Docs.find { type:'comment'}

    Template.user_view_comments.events
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










if Meteor.isServer
    Meteor.publish 'user_view_comments', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            type:'comment'
            author_id:user._id
