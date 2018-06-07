# if Meteor.isClient
#     Template.customer_view.onCreated ->
#         current_customer = FlowRouter.getParam('customer')
#         @autorun => Meteor.subscribe 'has_key_value', 'CUSTOMER', current_customer

#     Template.customer_view.helpers
#         current_customer: -> FlowRouter.getParam('customer')
#         customer_cards: ->  Docs.find {}

    
#     FlowRouter.route '/customers', action: ->
#         BlazeLayout.render 'layout', main: 'customers'
    
#     FlowRouter.route '/customer/:customer', action: ->
#         BlazeLayout.render 'layout', 
#             main: 'customer_view'

    
#     Template.customers.onCreated ->
#         @autorun => Meteor.subscribe 'has_key', 'CUSTOMER' 
        
#         # @autorun => Meteor.subscribe 'facet', 
#         #     selected_tags.array()
#         #     selected_keywords.array()
#         #     selected_author_ids.array()
#         #     selected_location_tags.array()
#         #     selected_timestamp_tags.array()
#         #     type='customer'
#         #     author_id=null
        
        
#     Template.customers.helpers
#         customers: ->  Docs.find {}
#         # customers: ->  Docs.find 'FRANCH_NAME':$exists:true


#     Template.customer_edit.onCreated ->
#         @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
    
#     Template.customer_edit.helpers
#         customer: -> Doc.findOne FlowRouter.getParam('doc_id')
        
#     Template.customer_edit.events
#         'click #delete': ->
#             template = Template.currentData()
#             swal {
#                 title: 'Delete customer?'
#                 # text: 'Confirm delete?'
#                 type: 'error'
#                 animation: false
#                 showCancelButton: true
#                 closeOnConfirm: true
#                 cancelButtonText: 'Cancel'
#                 confirmButtonText: 'Delete'
#                 confirmButtonColor: '#da5347'
#             }, =>
#                 doc = Docs.findOne FlowRouter.getParam('doc_id')
#                 # console.log doc
#                 Docs.remove doc._id, ->
#                     FlowRouter.go "/customers"


