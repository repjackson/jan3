if Meteor.isClient
    FlowRouter.route '/profile/:user_id', action: (params) ->
        BlazeLayout.render 'layout',
            main: 'view_profile'
    
    
    Template.view_profile.onCreated ->
        @autorun -> Meteor.subscribe('user_profile', FlowRouter.getParam('user_id'))
        
    
    Template.view_profile.helpers
        person: -> 
            Meteor.users.findOne FlowRouter.getParam('user_id') 
        
        can_edit_profile: -> Meteor.userId() is FlowRouter.getParam('user_id') or Roles.userIsInRole(Meteor.userId(),'dev')
    
    Template.view_profile.events
