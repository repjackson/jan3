if Meteor.isClient
    FlowRouter.route '/chat', action: ->
        BlazeLayout.render 'layout', main: 'chat'
    
    Template.chat.onCreated ->
        @autorun -> Meteor.subscribe 'messages'
        @autorun -> Meteor.subscribe 'conversations'
    
    Template.chat.helpers
        conversations: ->
            Docs.find
                type:'conversation'
    
    
    Template.chat.events
        'click #new_conversation': ->
            Docs.insert
                type:'conversation'
    


if Meteor.isServer
    Meteor.publish 'messages', ->
        Docs.find type:'message'
        
    Meteor.publish 'conversations', ->
        Docs.find type:'conversation'
        
        
        