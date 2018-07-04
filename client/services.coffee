FlowRouter.route '/services', action: ->
    BlazeLayout.render 'layout', main: 'services'

Template.services.onCreated () ->
Template.services.helpers
    settings: ->
        collection: 'special_services'
        rowsPerPage: 20
        showFilter: true
        showRowCount: true
        # showColumnToggles: true
        fields: [
            { key: 'ev.ID', label: 'JPID' }
            { key: 'ev.CUSTOMER', label: 'Customer' }
            { key: 'ev.CUST_OPS_MANAGER', label: 'Operations Manager' }
            { key: 'ev.FRANCHISEE', label: 'Franchisee' }
            { key: 'ev.SERV_TYPE', label: 'Extra Service Description' }
            { key: 'ev.EXTRA_SERV_DESC', label: 'Date Created' }
            { key: 'ev.DATE_CREATED', label: 'Extra Price' }
            { key: 'ev.EXTRA_PRICE', label: 'Extra Price' }
            { key: '', label: 'View', tmpl:Template.view_button }
        ]

Template.services.events
    'click .sync_services': ->
        Meteor.call 'sync_services', ->
            
    
    
        
Template.customers_by_service.helpers
    selector: ->  
        page_service = Docs.findOne FlowRouter.getParam('doc_id')
        return {
            type: "customer"
            master_licensee: page_service.service_name
            }
    
    
Template.users_by_service.helpers
    selector: ->  
        page_service = Docs.findOne FlowRouter.getParam('doc_id')
        return {
            "profile.service_name": page_service.service_name
            }
    
    
    
    
Template.service_edit.events
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


