# FlowRouter.route '/', action: ->
#     BlazeLayout.render 'layout', 
#         main: 'dashboard'

# Template.office_contact_cards.helpers
#     office_contacts: -> 
#         user = Meteor.user()
#         # console.log 'franch_doc', franch_doc
#         if user and user.customer_jpid
#             customer_doc = Docs.findOne
#                 "ev.ID": user.customer_jpid
#                 type:'customer'
#                 # grandparent office
#             # console.log 'ss cust doc', customer_doc
#             if customer_doc
#                 found = Meteor.users.find {
#                     published:true
#                     # "profile.office_name": customer_doc.ev.MASTER_LICENSEE
#                 }, limit:100
#                 found

Template.customer_menu.events
    # 'click .log_ticket': (e,t)->
    #     my_customer_ob = Meteor.user().users_customer()
    #     user = Meteor.user()
    #     console.log my_customer_ob
    #     if my_customer_ob
    #         Meteor.call 'count_current_incident_number', (err,incident_count)=>
    #             if err then console.error err
    #             else
    #                 console.log incident_count
    #                 next_incident_number = incident_count + 1
    #                 new_incident_id = 
    #                     Docs.insert
    #                         type: 'incident'
    #                         incident_number: next_incident_number
    #                         franchisee_jpid: user.franchisee_jpid
    #                         office_jpid: user.office_jpid
    #                         customer_jpid: user.customer_jpid
    #                         customer_name: my_customer_ob.ev.CUST_NAME
    #                         incident_office_name: my_customer_ob.ev.MASTER_LICENSEE
    #                         incident_franchisee: my_customer_ob.ev.FRANCHISEE
    #                         level: 1
    #                         open: true
    #                         submitted: false
    #                 FlowRouter.go "/v/#{new_incident_id}"

Template.dashboard_office_contacts_list.onCreated ->
    @autorun -> Meteor.subscribe 'my_office_contacts'
    
Template.dashboard_office_contacts_list.helpers
    office_contacts: -> 
        user = Meteor.user()
        # console.log 'franch_doc', franch_doc
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
        # console.log Meteor.user().users_office()
        users_office = Meteor.user().users_office()
        if users_office
            # console.log users_office.services
            Docs.find
                type:'service'
                slug: $in: users_office.services
                
                
                
                