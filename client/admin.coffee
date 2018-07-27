FlowRouter.route '/admin', 
    action: -> BlazeLayout.render 'layout', main: 'admin'
FlowRouter.route '/bugs', 
    action: -> BlazeLayout.render 'layout', main: 'bugs'
            
Template.bugs.onCreated ->
    @autorun -> Meteor.subscribe 'type', 'bug'
            
Template.bugs.helpers
    bugs: -> Docs.find type:'bug'
            
Template.bug_edit.events
    'click #delete_bug': ->
        if confirm 'delete bug?'
            Docs.remove @_id
            # console.log @_id
            