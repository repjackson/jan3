# if Meteor.isClient
#     Template.comments_big.onCreated ->
#         @autorun => Meteor.subscribe 'comments', @_id

#     Template.comments_big.helpers
#         comments: ->
#             delta = Docs.findOne type:'delta'
#             # if delta
#             Docs.find
#                 parent_id:delta.doc_id,
#                 type:'comment'


#     Template.comments_big.onRendered ->
#         # Meteor.setTimeout ->
#         #     $('.ui.accordion').accordion()
#         # , 400

#     Template.comments_big.events
#         'keyup #new_comment': (e,t)->
#             delta = Docs.findOne type:'delta'
#             if delta
#                 if e.which is 13
#                     text = $('#new_comment').val().trim()
#                     e.preventDefault()
#                     $('#new_comment').val ''
#                     new_comment_id =
#                         Docs.insert
#                             type:'comment'
#                             text:text
#                             parent_id: delta.doc_id
#                     Docs.insert
#                         type:'event'
#                         text:"#{Meteor.user().username} commented: #{text}"
#                         parent_id: delta.doc_id
#                         event_type:'comment'


#         'click .delete_comment': ->
#             if confirm 'delete comment?'
#                 Docs.remove @_id

# if Meteor.isServer
#     Meteor.publish 'comments', (doc_id)->
#         Docs.find
#             parent_id: doc_id
#             type:'comment'

