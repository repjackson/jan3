FlowRouter.route '/special_services', action: ->
    BlazeLayout.render 'layout', main: 'special_services'

Template.special_services.onCreated () ->
    @autorun => Meteor.subscribe 'type', 'special_service', Session.get('query'), parseInt(Session.get('page_size')),Session.get('sort_key'), Session.get('sort_direction'), parseInt(Session.get('skip'))
Template.special_services.helpers
    fields: -> [
        { key: 'ID', label: 'JPID', sortable:true, ev_subset:true }
        { key: 'CUSTOMER', label: 'Customer', sortable:true, ev_subset:true }
        { key: 'CUST_OPS_MANAGER', label: 'Operations Manager', sortable:true, ev_subset:true }
        { key: 'FRANCHISEE', label: 'Franchisee', sortable:true, ev_subset:true }
        { key: 'SERV_TYPE', label: 'Type', sortable:true, ev_subset:true }
        { key: 'EXTRA_SERV_DESC', label: 'Description', sortable:true, ev_subset:true }
        { key: 'DATE_CREATED', label: 'Date Created', sortable:true, ev_subset:true }
        { key: 'EXTRA_PRICE', label: 'Extra Price', sortable:true, ev_subset:true }
    ]

Template.special_services.events
    'click .sync_services': ->
        Meteor.call 'sync_services', ->
            
    
    
        
Template.customers_by_special_service.helpers
    selector: ->  
        page_service = Docs.findOne FlowRouter.getParam('doc_id')
        return {
            type: "customer"
            master_licensee: page_service.service_name
            }
    
    
Template.users_by_special_service.helpers
    selector: ->  
        page_service = Docs.findOne FlowRouter.getParam('doc_id')
        return {
            "profile.service_name": page_service.service_name
            }
    
    
    
    
Template.special_service_edit.events
    'click #delete': ->
        template = Template.currentData()
        swal {
            title: 'Delete service?'
            # text: 'Confirm delete?'
            type: 'error'
            animation: false
            showCancelButton: true
            closeOnConfirm: true
            cancelButtonText: 'Cancel'
            confirmButtonText: 'Delete'
            confirmButtonColor: '#da5347'
        }, =>
            doc = Docs.findOne FlowRouter.getParam('doc_id')
            # console.log doc
            Docs.remove doc._id, ->
                FlowRouter.go "/services"

