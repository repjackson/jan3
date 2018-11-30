
if Meteor.isClient
    Template.chat.onCreated ->
        @autorun -> Meteor.subscribe 'type', 'chat'
    

    Template.chat.helpers
        chat_messages: ->
            Docs.find {
                type:'chat'
                }, sort:timestamp:1
                

    Template.chat.events
        'keyup #new_chat': (e,t)->
            if e.which is 13
                message = $('#new_chat').val()
                Docs.insert
                    type:'chat'
                    message:message
                $('#new_chat').val('')



if Meteor.isServer
    Meteor.publish 'chat', ->
        Docs.find
            type:'chat'