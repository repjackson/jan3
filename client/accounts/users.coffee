FlowRouter.route '/users', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        # sub_nav: 'admin_nav'
        main: 'users'


Template.users.onCreated ->
    @autorun -> Meteor.subscribe 'all_users'


Template.users.helpers
    all_user_objects: -> Meteor.users.find()