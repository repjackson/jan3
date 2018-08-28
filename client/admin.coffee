FlowRouter.route '/admin', 
    name:'admin'
    action: -> BlazeLayout.render 'layout', main: 'admin'
            
Template.admin.onCreated ->
    @autorun -> Meteor.subscribe 'admin_total_stats'
