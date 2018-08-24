if Meteor.isClient
    FlowRouter.route '/invoices', action: ->
        BlazeLayout.render 'layout', 
            sub_nav: 'admin_nav'
            main: 'invoices'
    
    
    Template.invoices.onCreated ->
        @autorun => Meteor.subscribe 'type', 'invoice'
    Template.invoices.helpers
        invoices: ->  Docs.find { type:'invoice'}


    Template.invoice_card.onCreated ->

    Template.invoice_card.helpers
        
    
    Template.invoice_edit.onCreated ->
        # @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
    
    Template.invoice_edit.helpers
        invoice: -> Doc.findOne FlowRouter.getParam('doc_id')
        
    Template.invoice_edit.events
        'click #delete': ->
            template = Template.currentData()
            swal {
                title: 'Delete invoice?'
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
                    FlowRouter.go "/invoices"

