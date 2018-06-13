if Meteor.isClient
    FlowRouter.route '/users', action: (params) ->
        BlazeLayout.render 'layout',
            nav: 'nav'
            # sub_nav: 'admin_nav'
            main: 'users'
