FlowRouter.route '/admin', 
    action: -> BlazeLayout.render 'layout', main: 'admin'
FlowRouter.route '/bugs', 
    action: -> BlazeLayout.render 'layout', main: 'bugs'
            
Template.bugs.onCreated ->
    @autorun -> Meteor.subscribe 'type', 'bug'
            
Template.bugs.helpers
    bugs: -> Docs.find type:'bug'
            