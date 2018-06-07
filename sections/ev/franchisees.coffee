# if Meteor.isClient
#     Template.franchisee_view.onCreated ->
#         current_franchisee = FlowRouter.getParam('franchisee')
#         @autorun => Meteor.subscribe 'has_key_value', 'FRANCHISEE', current_franchisee
    
#     Template.franchisee_view.helpers
#         current_franchisee: -> FlowRouter.getParam('franchisee')
#         franchisee_cards: ->  Docs.find {}
        
    
#     FlowRouter.route '/franchisees', action: ->
#         BlazeLayout.render 'layout', main: 'franchisees'
    
#     FlowRouter.route '/franchisee/:franchisee', action: ->
#         BlazeLayout.render 'layout', 
#             main: 'franchisee_view'
    
    
#     Template.franchisees.onCreated ->
#         @autorun => Meteor.subscribe 'has_key', 'FRANCHISEE'
        
#         # @autorun => Meteor.subscribe 'facet', 
#         #     selected_tags.array()
#         #     selected_keywords.array()
#         #     selected_author_ids.array()
#         #     selected_location_tags.array()
#         #     selected_timestamp_tags.array()
#         #     type='franchise'
#         #     author_id=null
        
        
#     Template.franchisees.helpers
#         franchisees: ->  Docs.find {}, limit:100


    
#     Template.franchisee_edit.onCreated ->
#         @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
    
#     Template.franchisee_edit.helpers
#         franchise: -> Doc.findOne FlowRouter.getParam('doc_id')
        
#     Template.franchisee_edit.events
#         'click #delete': ->
#             template = Template.currentData()
#             swal {
#                 title: 'Delete franchise?'
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
#                     FlowRouter.go "/franchisees"


