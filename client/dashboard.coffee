FlowRouter.route '/', action: ->
    BlazeLayout.render 'layout', 
        main: 'dashboard'

Template.office_contact_cards.helpers
    office_contacts: -> 
        user = Meteor.user()
        # console.log 'franch_doc', franch_doc
        if user and user.profile and user.profile.customer_jpid
            customer_doc = Docs.findOne
                "ev.ID": user.profile.customer_jpid
                type:'customer'
                # grandparent office
            # console.log 'ss cust doc', customer_doc
            if customer_doc
                found = Meteor.users.find {
                    published:true
                    # "profile.office_name": customer_doc.ev.MASTER_LICENSEE
                }, limit:100
                found

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
            if customer_doc
                found = Meteor.users.find {
                    published:true
                    # "profile.office_name": customer_doc.ev.MASTER_LICENSEE
                }, limit:100
                found

Template.customer_special_services.onCreated ->
    @autorun -> Meteor.subscribe 'my_special_services'
Template.customer_special_services.helpers
    my_special_services: -> Docs.find type:'special_service'

Template.customer_incidents_widget.onCreated ->
    @autorun -> Meteor.subscribe 'my_customer_incidents'
Template.customer_incidents_widget.helpers    
    # customer_incidents: ->  
    #     user = Meteor.user()
    #     if user and user.profile and user.profile.customer_jpid
    #         # customer_doc = Docs.findOne "ev.ID":user.profile.customer_jpid
    #         Docs.find {
    #             customer_jpid: user.profile.customer_jpid
    #             type: "incident"
    #         }, limit:20

Template.customer_incidents_widget.helpers
    customer_incidents: -> Docs.find type:'incident'
    
    # settings: ->
    #     rowsPerPage: 5
    #     showFilter: true
    #     showRowCount: true
    #     # showColumnToggles: true
    #     fields: [
    #         { key: 'customer_name', label: 'Customer' }
    #         { key: 'incident_number', label: 'Number', sortOrder:1, sortDirection:'descending'}
    #         { key: 'incident_office_name', label: 'Office' }
    #         { key: '', label: 'Type', tmpl:Template.incident_type_label }
    #         { key: 'when', label: 'Logged' }
    #         { key: 'incident_details', label: 'Details' }
    #         { key: 'level', label: 'Level' }
    #         { key: 'status', label: 'Status', tmpl:Template.status_template}
    #         { key: 'submitted', label: 'Submitted', tmpl:Template.submitted_template}
    #         # { key: '', label: 'Assigned To', tmpl:Template.associated_users }
    #         # { key: '', label: 'Actions Taken', tmpl:Template.small_doc_history }
    #         { key: '', label: 'View', tmpl:Template.view_button }
    #     ]
        
        
Template.dashboard_services_widget.onCreated ->
    @autorun -> Meteor.subscribe 'type','service'
Template.dashboard_services_widget.helpers
    services_offered: -> 
        # console.log Meteor.user().users_office()
        users_office = Meteor.user().users_office()
        if users_office
            # console.log users_office.services
            Docs.find
                type:'service'
                slug: $in: users_office.services
                
                
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
                
                
                
Template.dashboard_consumables_widget.onCreated ->
    @autorun -> Meteor.subscribe 'type','product'
Template.dashboard_consumables_widget.helpers
    products_available: -> 
        Docs.find type:'product'
                
                