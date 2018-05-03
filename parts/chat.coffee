if Meteor.isClient
    FlowRouter.route '/chat', action: ->
        BlazeLayout.render 'layout', main: 'chat'
    
    Template.chat.onCreated ->
        @autorun -> Meteor.subscribe 'chat_messages'
    
    Template.chat.helpers
        chat_messages: ->
            Docs.find
                type:'chat_message'
    
    
    Template.chat.events
        'keydown #new_chat_message': (e,t)->
            if e.which is 13
                new_chat_message = $('#new_chat_message').val().trim()
                if new_chat_message.length > 0
                    Docs.insert 
                        text: new_chat_message
                        type:'chat_message'
                    $('#new_chat_message').val('')

    Template.chat_message.events
        'click .delete_comment': ->
            if confirm 'Delete comment?'
                Docs.remove @_id


if Meteor.isServer
    Meteor.publish 'chat_messages', ->
        Docs.find type:'chat_message'
        
        
        
        