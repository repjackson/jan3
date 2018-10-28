Template.left_sidebar.events
    'click #logout': (e,t)->
        e.preventDefault()
        Meteor.logout ->
            FlowRouter.go '/login'

Template.nav.onCreated ->
    @signing_out = new ReactiveVar false

Template.data.onRendered ->
    Meteor.setTimeout ->
        $('.dropdown').dropdown()
    , 500


Template.nav.helpers
    signing_out: ->
        if Template.instance().signing_out.get() is true then 'loading' else ''

    # active_route: (slug)->
    #     if Template.instance().signing_out.get() is true
    #         'disabled'
    #     else
    #         if FlowRouter.getParam('page_slug') is slug then 'active' else ''


    my_office_doc: ->
        user = Meteor.user()
        if user and user.office_jpid
            Docs.find
                jpid: user.office_jpid
                type:'office'

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
        t.signing_out.set true
        Meteor.logout ->
            FlowRouter.go '/login'
            t.signing_out.set false

    # 'click .log_ticket': (e,t)->
    #     Meteor.call 'log_ticket', (err,res)->
    #         if err then console.error err
    #         else
    #             FlowRouter.go "/p/submit_ticket?doc_id=#{res}"

    'click #toggle_editing': ->
        Session.set('editing_mode',!Session.get('editing_mode'))

Template.nav.onCreated ->
    @autorun -> Meteor.subscribe 'me'
    @autorun -> Meteor.subscribe 'nav_items'
    @autorun -> Meteor.subscribe 'my_customer_account'
    @autorun -> Meteor.subscribe 'my_franchisee'
    @autorun -> Meteor.subscribe 'my_office'


Template.nav.onRendered ->
    # Meteor.setTimeout ->
    #     $('.item').popup()
    # , 1000
