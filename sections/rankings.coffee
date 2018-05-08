if Meteor.isClient
    FlowRouter.route '/rankings', action: ->
        BlazeLayout.render 'layout', main: 'rankings'
    FlowRouter.route '/ideas', action: ->
        BlazeLayout.render 'layout', main: 'ideas'
    FlowRouter.route '/questions', action: ->
        BlazeLayout.render 'layout', main: 'questions'
    
    Template.rankings.onCreated ->
        # @autorun -> Meteor.subscribe 'messages'
        # @autorun -> Meteor.subscribe 'conversations'
    
    Template.rankings.helpers
        conversations: ->
            Docs.find
                type:'conversation'
    
    
    Template.rankings.events
    


        
        
        