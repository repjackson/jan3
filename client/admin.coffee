FlowRouter.route '/admin', 
    name:'admin'
    action: -> BlazeLayout.render 'layout', main: 'admin'
FlowRouter.route '/bugs', 
    name:'bugs'
    action: -> BlazeLayout.render 'layout', main: 'bugs'
            
Template.admin.onCreated ->
    @autorun -> Meteor.subscribe 'admin_total_stats'
Template.bugs.onCreated ->
    @autorun -> Meteor.subscribe 'type', 'bug'
            
Template.bugs.helpers
    bugs: -> Docs.find type:'bug'
            
Template.bug_edit.events
    'click #delete_bug': ->
        if confirm 'delete bug?'
            Docs.remove @_id
            FlowRouter.go '/bugs'
            