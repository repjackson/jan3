FlowRouter.route '/profile/:username', action: (params) ->
    BlazeLayout.render 'layout',
        sub_nav: 'user_nav'
        main: 'view_profile'


Template.view_profile.onCreated ->
    @autorun -> Meteor.subscribe('user_profile', FlowRouter.getParam('username'))
    

Template.user_nav.helpers
    person: -> Meteor.users.findOne username:FlowRouter.getParam('username') 
Template.view_profile.helpers
    person: -> Meteor.users.findOne username:FlowRouter.getParam('username') 
    
    can_edit_profile: -> Meteor.userId() is FlowRouter.getParam('username') or Roles.userIsInRole(Meteor.userId(),'dev')

Template.view_profile.events
