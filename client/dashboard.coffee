# FlowRouter.route '/', action: ->
#     BlazeLayout.render 'layout', 
#         main: 'dashboard'

# Template.office_contact_cards.helpers
#     office_contacts: -> 
#         user = Meteor.user()
#         if user and user.customer_jpid
#             customer_doc = Docs.findOne
#                 "ev.ID": user.customer_jpid
#                 type:'customer'
#                 # grandparent office
#             if customer_doc
#                 found = Meteor.users.find {
#                     published:true
#                     # "profile.office_name": customer_doc.ev.MASTER_LICENSEE
#                 }, limit:100
#                 found

Template.customer_menu.events
    'click .log_ticket': (e,t)->
        Meteor.call 'log_ticket', (err,res)->
            if err then console.error err
            else
                console.log 'res', res
                FlowRouter.go "/v/#{res}"


Template.dashboard_office_contacts_list.onCreated ->
    @autorun -> Meteor.subscribe 'my_office_contacts'
    
Template.dashboard_office_contacts_list.helpers
    office_contacts: -> 
        user = Meteor.user()
        if user and user.customer_jpid
            customer_doc = Docs.findOne
                "ev.ID": user.customer_jpid
                type:'customer'
                # grandparent office
            if customer_doc
                found = Meteor.users.find {
                    published:true
                    # "profile.office_name": customer_doc.ev.MASTER_LICENSEE
                }, limit:100
                found

    
                
                
Template.small_service_list.onCreated ->
    @autorun -> Meteor.subscribe 'type','service'
Template.small_service_list.helpers
    services_offered: -> 
        users_office = Meteor.user().users_office()
        if users_office
            Docs.find
                type:'service'
                slug: $in: users_office.services
                
                
                
                