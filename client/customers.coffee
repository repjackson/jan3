FlowRouter.route '/customers', 
    action: -> BlazeLayout.render 'layout', main: 'customers'
    
Template.customers.onCreated ->
    Session.setDefault('query',null)
    @autorun -> Meteor.subscribe 'active_customers', Session.get('query'),parseInt(Session.get('page_size')),Session.get('sort_key'), Session.get('sort_direction'), parseInt(Session.get('skip'))
    @autorun => Meteor.subscribe 'count', 'customer'

Template.customers.helpers
    all_customers: -> 
        Docs.find { type:'customer'
        },{ sort: "#{Session.get('sort_key')}":parseInt("#{Session.get('sort_direction')}") }


Template.customers.events
    # 'click .sync_customers': ->
    #     Meteor.call 'sync_customers',(err,res)->
    #         if err then console.error err

Template.customers_franchisee.onCreated ->
    @autorun => Meteor.subscribe 'customers_franchisee', FlowRouter.getParam('doc_id')


Template.customers_franchisee.helpers
    customers_franchisee_doc: ->  
        customer_doc = Docs.findOne FlowRouter.getParam('doc_id')
        found = Docs.findOne
            "ev.FRANCHISEE": customer_doc.ev.FRANCHISEE
            type: "franchisee"
        return found
        
        
