# # history
# FlowRouter.route '/history', 
#     action: -> BlazeLayout.render 'layout', main: 'history'
# Template.history.helpers
#     settings: ->
#         collection: 'search_history_docs'
#         rowsPerPage: 10
#         showFilter: true
#         showRowCount: true
#         # showColumnToggles: true
#         fields: [
#             { key: 'ev.ID', label: 'JPID' }
#             { key: 'ev.TIMESTAMP', label: 'EV Timestamp' }
            
#             { key: 'ev.FRANCHISEE', label: 'Franchisee' }
#             { key: 'ev.CUSTOMER', label: 'Customer' }
#             { key: 'ev.FRANCH_EMAIL', label: 'Email' }
#             { key: 'ev.FRANCH_NAME', label: 'Short Name' }
#             { key: 'ev.AREA', label: 'Area' }
#             { key: 'ev.MASTER_LICENSEE', label: 'Office' }
#             { key: '', label: 'View', tmpl:Template.view_button }
#         ]



# Template.history.events
#     'click .refresh_history': ->
#         Meteor.call 'get_history',(err,res)->
#             if err then console.error err
#     'click .run_timestamp_search': ->
#         Meteor.call 'search_ev',(err,res)->
#             if err then console.error err


# # jpids
# FlowRouter.route '/jpids', 
#     action: -> BlazeLayout.render 'layout', main: 'jpids'
# Template.jpids.onCreated ->
#     @autorun => Meteor.subscribe 'type', 'jpid'
# Template.jpids.helpers
#     settings: ->
#         collection: 'jpids'
#         rowsPerPage: 10
#         showFilter: true
#         showRowCount: true
#         # showColumnToggles: true
#         fields: [
#             { key: 'ev.ID', label: 'JPID' }
#             { key: 'ev.FRANCHISEE', label: 'Franchisee' }
#             { key: 'ev.CUSTOMER', label: 'Customer' }
#             { key: 'ev.FRANCH_EMAIL', label: 'Email' }
#             { key: 'ev.FRANCH_NAME', label: 'Short Name' }
#             { key: 'ev.AREA', label: 'Area' }
#             { key: 'ev.MASTER_LICENSEE', label: 'Office' }
#             { key: '', label: 'View', tmpl:Template.view_button }
#         ]
            
            
# Template.jpids.events
#     'click .get_jp_id': ->
#         Meteor.call 'get_jp_id',(err,res)->
#             if err then console.error err
#     'keyup #jp_lookup': (e,t)->
#         e.preventDefault()
#         val = $('#jp_lookup').val().trim()
#         if e.which is 13
#             unless val.length is 0
#                 Meteor.call 'get_jp_id', val.toString(), (err,res)=>
#                     if err
#                         Bert.alert "#{err.reason}", 'danger', 'growl-top-right'
#                     else
#                         Bert.alert "Added JP ID #{val}", 'success', 'growl-top-right'
#                     $('#jp_lookup').val ''

# Template.jpid_view.events
#     'click .refresh_jpid': (e,t)->
#         doc = Docs.findOne FlowRouter.getParam('doc_id')
#         Meteor.call 'get_jp_id', doc.jpid, (err,res)=>
#             if err
#                 Bert.alert "#{err.reason}", 'danger', 'growl-top-right'
#             else
#                 Bert.alert "Updated JP ID #{doc.jpid}", 'success', 'growl-top-right'

# Template.jpids.events
#     'keyup #ev_search': (e,t)->
#         e.preventDefault()
#         val = $('#ev_search').val().trim()
#         if e.which is 13
#             unless val.length is 0
#                 Meteor.call 'search_ev', val.toString(), (err,res)=>
#                     if err
#                         Bert.alert "#{err.reason}", 'danger', 'growl-top-right'
#                     else
#                         Bert.alert "Searched #{val}", 'success', 'growl-top-right'
#                     $('#ev_search').val ''
