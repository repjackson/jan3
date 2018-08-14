FlowRouter.route '/', action: ->
    BlazeLayout.render 'layout', 
        main: 'dashboard'

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

Template.dashboard.events
    'click .log_ticket': (e,t)->
        my_customer_ob = Meteor.user().users_customer()
        user = Meteor.user()
        console.log my_customer_ob
        if my_customer_ob
            Meteor.call 'count_current_incident_number', (err,incident_count)=>
                if err then console.error err
                else
                    console.log incident_count
                    next_incident_number = incident_count + 1
                    new_incident_id = 
                        Docs.insert
                            type: 'incident'
                            incident_number: next_incident_number
                            franchisee_jpid: user.franchisee_jpid
                            office_jpid: user.office_jpid
                            customer_jpid: user.customer_jpid
                            customer_name: my_customer_ob.ev.CUST_NAME
                            incident_office_name: my_customer_ob.ev.MASTER_LICENSEE
                            incident_franchisee: my_customer_ob.ev.FRANCHISEE
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

Template.customer_special_services.onCreated ->
    @autorun -> Meteor.subscribe 'my_special_services'
Template.customer_special_services.helpers
    my_special_services: -> Docs.find type:'special_service'

    customer_days_service_formatted: ->
        split_days = @ev.CUST_DAYS_SERVICE.split(/\|/)
        # console.log split_days
        result_list = []
        for abbrev_day in split_days
            switch abbrev_day
                when 'Mon' then result_list.push 'Monday'
                when 'Th' then result_list.push 'Thursday'
                when 'T' then result_list.push 'Tuesday'
                when 'Fri' then result_list.push 'Friday'
                when 'Sat' then result_list.push 'Saturday'
        return result_list
    
Template.customer_incidents_widget.onCreated ->
    @autorun -> Meteor.subscribe 'my_customer_incidents', Session.get('query'), 3, Session.get('sort_key'), Session.get('sort_direction'), parseInt(Session.get('skip'))
    @autorun => Meteor.subscribe 'my_incident_count'

Template.customer_incidents_widget.events
    'click .set_page_number': -> 
        Session.set 'current_page_number', @number
        int_page_size = 3
        skip_amount = @number*int_page_size-int_page_size
        Session.set 'skip', skip_amount


Template.customer_incidents_widget.helpers
    customer_incidents: -> Docs.find {type:'incident'}, sort:timestamp:-1
    
    skip_amount: -> Session.get 'skip'

    pagination_item_class: ->
        if Session.equals('current_page_number', @number) then 'active' else ''
        
    count_amount: ->
        count_stat = Stats.findOne()
        if count_stat
            count_stat.amount
            
    pages: ->
        stat_doc = Stats.findOne()
        if stat_doc
            count_amount = stat_doc.amount
            current_page_size = 3
            number_of_pages = Math.ceil(count_amount/current_page_size)
            pages = []
            page = 0
            if number_of_pages>10
                number_of_pages = 10
            while page<number_of_pages
                pages.push {number:page+1}
                page++
            return pages
    
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
                
                