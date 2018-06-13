# if Meteor.isClient
#     FlowRouter.route '/work', action: ->
#         BlazeLayout.render 'layout', 
#             sub_nav:'dev_nav'
#             main: 'work'
    
#     Template.work.onCreated ->
#         @autorun => Meteor.subscribe 'facet', 
#             selected_tags.array()
#             selected_keywords.array()
#             selected_author_ids.array()
#             selected_location_tags.array()
#             selected_timestamp_tags.array()
#             type='work'
#             author_id=null
    
#     Template.work.onCreated ->
#         Meteor.setTimeout ->
#             $('.progress').progress()
#         , 1000
#         Meteor.setTimeout ->
#             $('.ui.accordion').accordion()
#         , 1000
    
    
    
    
#     Template.work.helpers
#         work: -> 
#             Docs.find({type:'work'},{sort:{start_time:-1}})
        