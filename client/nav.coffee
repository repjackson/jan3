Template.left_sidebar.events
    'click #logout': -> AccountsTemplates.logout()
    
Template.nav.onCreated ->
    @autorun -> Meteor.subscribe 'me'
    
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
    
    
    
Template.nav.helpers



