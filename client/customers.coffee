FlowRouter.route '/customers', 
    action: -> BlazeLayout.render 'layout', main: 'customers'
    
Template.customers.helpers
    settings: ->
        collection: 'customers'
        rowsPerPage: 20
        showFilter: true
        showRowCount: true
        # showColumnToggles: true
        fields: [
            { key: 'ev.CUST_NAME', label: 'Customer Name' }
            { key: 'ev.ID', label: 'JPID' }
            { key: 'ev.FRANCHISEE', label: 'Franchisee' }
            { key: 'ev.MASTER_LICENSEE', label: 'Master Licensee' }
            { key: 'ev.CUST_CONT_PERSON', label: 'Contact Person' }
            { key: 'ev.CUST_CONTACT_EMAIL', label: 'Contact Email' }
            { key: 'ev.TELEPHONE', label: 'Telephone' }
            { key: 'ev.ADDR_STREET', label: 'Address' }
            { key: '', label: 'View', tmpl:Template.view_button }
        ]
    current_customer_counter: -> Counts.get 'customer_counter'

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
        
        
Template.my_customer_account_card.onCreated ->
    @autorun =>  Meteor.subscribe 'my_customer_account'
                
                
Template.my_franchisee_card.onCreated ->
    @autorun =>  Meteor.subscribe 'my_franchisee'
                
                
Template.my_office_card.onCreated ->
    @autorun =>  Meteor.subscribe 'my_office'
                
                
                