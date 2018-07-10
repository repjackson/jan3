FlowRouter.route '/', action: ->
    BlazeLayout.render 'layout', 
        main: 'dashboard'


Template.my_office_contacts.helpers
    crew: -> 
        Meteor.users.find {
            published:true
        }, limit:4

Template.dashboard.events
    'click .log_ticket': (e,t)->
        my_customer_ob = Meteor.user().users_customer()
        console.log my_customer_ob
        if my_customer_ob
            new_incident_id = 
                Docs.insert
                    type: 'incident'
                    customer_jpid: my_customer_ob.ev.ID
                    customer_name: my_customer_ob.ev.CUST_NAME
                    incident_office_name: my_customer_ob.ev.MASTER_LICENSEE
                    level: 1
                    open: true
                    submitted: false
            FlowRouter.go "/view/#{new_incident_id}"



Template.dashboard_office_contacts_list.onCreated ->
    @autorun -> Meteor.subscribe 'my_office_contacts'
    
Template.dashboard_office_contacts_list.helpers
    office_contacts: -> 
        user = Meteor.user()
        # console.log 'franch_doc', franch_doc
        if user and user.profile and user.profile.customer_jpid
            customer_doc = Docs.findOne
                "ev.ID": user.profile.customer_jpid
                type:'customer'
                # grandparent office
            console.log 'ss cust doc', customer_doc
            if customer_doc
                found = Meteor.users.find {
                    published:true
                    # "profile.office_name": customer_doc.ev.MASTER_LICENSEE
                }, limit:100
                console.log found.fetch()
                found


Template.customer_special_services.onCreated ->
    @autorun -> Meteor.subscribe 'my_special_services'
Template.customer_special_services.helpers
    my_special_services: -> Docs.find type:'special_service'



Template.customer_incidents_widget.onCreated ->
    @autorun -> Meteor.subscribe 'my_customer_incidents'
Template.customer_incidents_widget.helpers    
    customer_incidents: ->  
        user = Meteor.user()
        if user and user.profile and user.profile.customer_jpid
            # customer_doc = Docs.findOne "ev.ID":user.profile.customer_jpid
            Docs.find {
                customer_jpid: user.profile.customer_jpid
                type: "incident"
            }, limit:20
