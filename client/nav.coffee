Template.left_sidebar.events
    'click #logout': (e,t)-> 
        e.preventDefault()
        Meteor.logout()
        FlowRouter.go '/login'

    
Template.nav.helpers
    my_office_doc: ->
        user = Meteor.user()
        if user and user.profile and user.office_jpid
            Docs.find
                "ev.ID": user.office_jpid
                type:'office'
    # isActiveRoute: (name)->
    #     console.log name
    #     if FlowRouter.current().route.name is name then 'active' else ''




Template.nav.events
    'click #logout': (e,t)-> 
        e.preventDefault()
        Meteor.logout()
        FlowRouter.go '/login'


    'click #toggle_dev': ->
        Session.set('dev_mode',!Session.get('dev_mode'))
    'click #toggle_editing': ->
        Session.set('editing_mode',!Session.get('editing_mode'))
    
Template.nav.onCreated ->
    @autorun -> Meteor.subscribe 'my_customer_account'
    @autorun -> Meteor.subscribe 'my_franchisee'
    @autorun -> Meteor.subscribe 'my_office'
    @autorun -> Meteor.subscribe 'me'
    
Template.dashboard.onRendered ->
    # Meteor.setTimeout ->
    #     $('.ui.dropdown').dropdown()
    # , 400
    
Template.nav.onRendered ->
    # Meteor.setTimeout ->
    #     $('.ui.dropdown').dropdown()
    # , 1000
    
    Meteor.setTimeout ->
        $('.item').popup()
    , 1500
    
    
    


