
if Meteor.isClient
    Template.chat.onCreated ->
        @autorun -> Meteor.subscribe 'type', 'chat'
    

    Template.chat.helpers
        comment_class: ->
            if @read_ids and Meteor.userId() in @read_ids then 'secondary' else ''
        chat_messages: ->
            Docs.find {
                type:'chat'
                }, sort:timestamp:-1
                

    Template.chat.events
        'keyup #new_chat': (e,t)->
            if e.which is 13
                message = $('#new_chat').val()
                Docs.insert
                    type:'chat'
                    message:message
                $('#new_chat').val('')
        
        'click .delete': (e,t)->
            if confirm "Delete message from #{@author_username}?"
                $(e.currentTarget).closest('.segment').transition('fly left')
                Meteor.setTimeout ->
                    Docs.remove @_id
                , 500

        'click .mark_read': (e,t)->
            Docs.update @_id, 
                $addToSet: read_ids: Meteor.userId()
            $(e.currentTarget).closest('.segment').transition('pulse')

        'click .mark_unread': (e,t)->
            Docs.update @_id, 
                $pull: read_ids: Meteor.userId()
            $(e.currentTarget).closest('.segment').transition('pulse')


if Meteor.isServer
    Meteor.publish 'chat', ->
        Docs.find
            type:'chat'