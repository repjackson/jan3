FlowRouter.route '/admin', 
    action: -> BlazeLayout.render 'layout', main: 'admin'
            

# # fields
# FlowRouter.route '/ev_fields', 
#     action: -> BlazeLayout.render 'layout', main: 'ev_fields'

# Template.ev_fields.events
#     'click .sync_ev_fields': ->
#         Meteor.call 'sync_ev_fields',(err,res)->
#             if err then console.error err
# Template.ev_fields.helpers
#     selector: ->  type: "field"
# # 
Template.franchisees.onCreated ->
    @autorun -> Meteor.subscribe 'all_users'


Template.franchisees.helpers
    all_franchisees: -> Meteor.users.find()