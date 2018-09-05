FlowRouter.route '/franchisees', 
    name: 'franchisees'
    action: -> BlazeLayout.render 'layout', main: 'franchisees'


Template.franchisees.onCreated ->
    Session.set('query',null)
    Session.set('sort_direction',-1)
    Session.set('page_number',1)
    Session.set('page_size',10)
    Session.set('skip',0)


    @autorun => Meteor.subscribe 'active_franchisees_stat'
    # @autorun -> Meteor.subscribe 'type', 'franchisee', Session.get('query'), parseInt(Session.get('page_size')),Session.get('sort_key'), Session.get('sort_direction'), parseInt(Session.get('skip'))
