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
        Meteor.call 'log_ticket', (err,res)->
            if err then console.error err
            else
                console.log 'res', res
                FlowRouter.go "/v/#{res}"


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
