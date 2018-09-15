Template.left_sidebar.events
    'click #logout': (e,t)-> 
        e.preventDefault()
        Meteor.logout()
        FlowRouter.go '/login'

    
Template.nav.helpers
    my_office_doc: ->
        user = Meteor.user()
        if user and user.office_jpid
            Docs.find
                "ev.ID": user.office_jpid
                type:'office'

    admin_nav_items: ->
        Docs.find {
            type:'page'
            admin_nav:true
        }, sort:number:1
    office_nav_items: ->
        Docs.find {
            type:'page'
            office_nav:true
        }, sort:number:1
    customer_nav_items: ->
        Docs.find {
            type:'page'
            customer_nav:true
        }, sort:number:1

Template.left_sidebar.helpers
    my_office_doc: ->
        user = Meteor.user()
        if user and user.office_jpid
            Docs.find
                "ev.ID": user.office_jpid
                type:'office'
    admin_nav_items: ->
        Docs.find {
            type:'page'
            admin_nav:true
        }, sort:number:1
    office_nav_items: ->
        Docs.find {
            type:'page'
            office_nav:true
        }, sort:number:1
    customer_nav_items: ->
        Docs.find {
            type:'page'
            customer_nav:true
        }, sort:number:1


Template.nav.events
    'click #logout': (e,t)-> 
        e.preventDefault()
        Meteor.logout()
        FlowRouter.go '/login'

    'click .log_ticket': (e,t)->
        my_customer_ob = Meteor.user().users_customer()
        user = Meteor.user()
        # console.log my_customer_ob
        if my_customer_ob
            Meteor.call 'count_current_incident_number', (err,incident_count)=>
                if err then console.error err
                else
                    # console.log incident_count
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
                    FlowRouter.go "/v/#{new_incident_id}"


    'click #toggle_dev': ->
        Session.set('dev_mode',!Session.get('dev_mode'))
    'click #toggle_editing': ->
        Session.set('editing_mode',!Session.get('editing_mode'))
    
Template.nav.onCreated ->
    @autorun -> Meteor.subscribe 'me'
    @autorun -> Meteor.subscribe 'nav_items'
    @autorun -> Meteor.subscribe 'my_customer_account'
    @autorun -> Meteor.subscribe 'my_franchisee'
    @autorun -> Meteor.subscribe 'my_office'
