Template.left_sidebar.events
    'click #logout': (e,t)-> 
        e.preventDefault()
        Meteor.logout()

    
Template.nav.onCreated ->
    @autorun -> Meteor.subscribe 'my_customer_account'
    @autorun -> Meteor.subscribe 'my_franchisee'
    @autorun -> Meteor.subscribe 'me'
    @autorun -> Meteor.subscribe 'my_office'
    
Template.dashboard.onRendered ->
    # Meteor.setTimeout ->
    #     $('.ui.dropdown').dropdown()
    # , 400
    
Template.nav.onRendered ->
    # Meteor.setTimeout ->
    #     $('.ui.dropdown').dropdown()
    # , 1000
    # Meteor.setTimeout ->
    #     $('.item').popup()
    # , 400
    
    
    


