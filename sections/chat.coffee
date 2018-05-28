if Meteor.isClient
    FlowRouter.route '/chat', action: ->
        BlazeLayout.render 'layout', main: 'chat'
    
    Template.chat.onCreated ->
        @autorun => Meteor.subscribe 'facet', 
            selected_tags.array()
            selected_keywords.array()
            selected_author_ids.array()
            selected_location_tags.array()
            selected_timestamp_tags.array()
            type='chat'
            author_id=null
    
    Template.chat.helpers
        chats: ->
            Docs.find   
                type:'chat'
    
    Template.chat.onCreated ->
        @autorun => Meteor.subscribe 'child_docs', FlowRouter.getParam('doc_id')
    Template.chat_view.onCreated ->
        @autorun => Meteor.subscribe 'child_docs', FlowRouter.getParam('doc_id')

    Template.chat_pane.helpers
        messages: ->
            Docs.find
                type:'message'
    
    
    Template.chat_pane.events
        'keydown #add_message': (e,t)->
            if e.which is 13
                add_message = $('#add_message').val().trim()
                if add_message.length > 0
                    Docs.insert 
                        parent_id: FlowRouter.getParam('doc_id')
                        text: add_message
                        type:'message'
                    $('#add_message').val('')

    Template.message.events
        'click .delete_comment': ->
            if confirm 'Delete comment?'
                Docs.remove @_id

