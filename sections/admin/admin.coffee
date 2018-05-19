
FlowRouter.route '/admin', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        sub_nav: 'admin_nav'
        main: 'admin'
 
 
if Meteor.isClient
    Template.user_table.onCreated ->
        @autorun ->  Meteor.subscribe 'users'
    
    
    Template.user_table.helpers
        users: -> Meteor.users.find {}
        is_admin: -> Roles.userIsInRole(@_id, 'admin')
    
    
    Template.admin_nav.onRendered ->
        Meteor.setTimeout ->
            $('.item').popup()
        , 400
        

    
    
