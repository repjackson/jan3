if Meteor.isClient
    Template.mail.onCreated ->
        @autorun -> Meteor.subscribe 'docs', [], 'message'
    Template.mail.helpers
    
    
    FlowRouter.route '/mail', action: ->
        BlazeLayout.render 'layout', main: 'mail'
    
    
