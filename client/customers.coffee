FlowRouter.route '/customers', 
    action: -> BlazeLayout.render 'layout', main: 'customers'
    
Template.customers.onCreated ->
    @autorun => Meteor.subscribe 'type', 'customer'
Template.customers.helpers
    customer_docs: ->  
        Docs.find 
            type: "customer"
    
Template.customers.events
    'click .sync_customers': ->
        Meteor.call 'sync_customers',(err,res)->
            if err then console.error err


Template.related_customers.helpers
    selector: ->  
        page_doc = Docs.findOne FlowRouter.getParam('doc_id')
        return {
            type: "customer"
            franchisee: page_doc.franchisee
        }
            
Template.customers_franchisee.helpers
    customers_franchisee_doc: ->  
        page_doc = Docs.findOne FlowRouter.getParam('doc_id')
        found = Docs.findOne
            franchisee: page_doc.franchisee
            # type: "franchisee"
        console.log found
        return found