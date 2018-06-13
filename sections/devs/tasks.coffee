# if Meteor.isClient
#     FlowRouter.route '/tasks', action: ->
#         BlazeLayout.render 'layout', 
#             sub_nav:'dev_nav'
#             main: 'tasks'
    
#     Template.tasks.onCreated ->
#         @autorun => Meteor.subscribe 'facet', 
#             selected_tags.array()
#             selected_keywords.array()
#             selected_author_ids.array()
#             selected_location_tags.array()
#             selected_timestamp_tags.array()
#             type='task'
#             author_id=null
    
#     Template.tasks.onCreated ->
#         Meteor.setTimeout ->
#             $('.progress').progress()
#         , 1000
#         Meteor.setTimeout ->
#             $('.ui.accordion').accordion()
#         , 1000
    
    
    
    
#     Template.tasks.helpers
#         tasks: -> 
#             # Docs.find type:'task'
#             if Session.equals('view_complete', true)
#                 Docs.find 
#                     type:'task'
#                     complete:true
#             if Session.equals('view_complete', false)
#                 Docs.find 
#                     type:'task'
#                     complete:false
#             else
#                 Docs.find 
#                     type:'task'
        
        
        
#     Template.tasks.events
    
#     Template.task_view.events
#         'click #turn_on': ->
#             # console.log @complete
#             if confirm 'Mark Complete?'
#                 doc_id = FlowRouter.getParam('doc_id')
#                 Docs.update {_id:FlowRouter.getParam('doc_id')}, 
#                     $set: complete: true
#                 Meteor.call 'create_event', doc_id, 'mark_complete', 'marked complete'
    
#         'click #turn_off': ->
#             # console.log @complete
#             if confirm 'Mark Incomplete?'
#                 doc_id = FlowRouter.getParam('doc_id')
#                 Docs.update {_id:doc_id}, 
#                     $set: complete: false
#                 Meteor.call 'create_event', doc_id, 'mark_incomplete', 'marked incomplete'

#     Template.task_card.events
#         'click #turn_on': ->
#             # console.log @complete
#             Docs.update {_id:@_id}, 
#                 $set: complete: true

    
#         'click #turn_off': ->
#             # console.log @complete
#             Docs.update {_id:@_id}, 
#                 $set: complete: false


