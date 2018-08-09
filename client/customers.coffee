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


Template.franchisee_customers.helpers
    franchisee_customers_docs: ->  
        page_doc = Docs.findOne FlowRouter.getParam('doc_id')
        Docs.find type:"customer"
            # franchisee: page_doc.franchisee

    # settings: ->
    #     rowsPerPage: 10
    #     showFilter: false
    #     showRowCount: false
    #     # showColumnToggles: true
    #     showNavigation: 'auto'
    #     fields: [
    #         { key: 'ev.CUST_NAME', label: 'Customer Name' }
    #         { key: 'ev.ID', label: 'JPID' }
    #         { key: 'ev.FRANCHISEE', label: 'Franchisee' }
    #         { key: 'ev.MASTER_LICENSEE', label: 'Master Licensee' }
    #         { key: 'ev.CUST_CONT_PERSON', label: 'Contact Person' }
    #         { key: 'ev.CUST_CONTACT_EMAIL', label: 'Contact Email' }
    #         { key: 'ev.TELEPHONE', label: 'Telephone' }
    #         { key: 'ev.ADDR_STREET', label: 'Address' }
    #         { key: '', label: 'View', tmpl:Template.view_button }
    #     ]
    
Template.customers_franchisee.helpers
    customers_franchisee_doc: ->  
        page_doc = Docs.findOne FlowRouter.getParam('doc_id')
        found = Docs.findOne
            franchisee: page_doc.franchisee
            # type: "franchisee"
        return found
        
        
