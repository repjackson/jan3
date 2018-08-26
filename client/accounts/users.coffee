FlowRouter.route '/users', 
    name:'users'
    action: (params) ->
        BlazeLayout.render 'layout',
            nav: 'nav'
            # sub_nav: 'admin_nav'
            main: 'users'


Template.users.onCreated ->
    @autorun -> Meteor.subscribe 'all_users', Session.get('query'), parseInt(Session.get('page_size')),Session.get('sort_key'), Session.get('sort_direction'), parseInt(Session.get('skip'))
    @autorun => Meteor.subscribe 'all_users_count'
Template.users.helpers
    all_users: -> 
        Meteor.users.find {
        },{ sort: "#{Session.get('sort_key')}":parseInt("#{Session.get('sort_direction')}") }
