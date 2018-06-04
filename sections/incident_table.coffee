# if Meteor.isClient
#     Template.table.onCreated ->
#         @autorun => Meteor.subscribe 'facet', 
#             selected_tags.array()
#             selected_keywords.array()
#             selected_author_ids.array()
#             selected_location_tags.array()
#             selected_timestamp_tags.array()
#             type='incident'
#             author_id=null

#     Template.table.onRendered ->

#         Meteor.setTimeout (->
#             $('.ui.dropdown').dropdown(
#                 useLabels: true,
#                 maxSelections: 6
#             ).dropdown('set selected', ['id', 'date'])	
#         ), 500    



#     Template.table.helpers
#         docs: -> Docs.find {}, sort:timestamp:-1

#         current_doc: -> Session.get 'current_doc'

#     Template.table.events
#         # 'click .filter_column': (e,t)->
#         #     # console.log @
#         #     # Session.set 'filter_column', @
#         #     console.log e

#         'click .launch_modal': (e,t)->
#             $('.ui.modal').modal('show')
#             # console.log @
#             Session.set 'current_doc', @

#         'click .tagify': (e,t)->
#             # console.log @
#             Meteor.call 'tagify_timestamp', @_id


# if Meteor.isServer
#     Meteor.publish 'table',(type)->
#         Docs.find
#             type:type