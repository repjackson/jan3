if Meteor.isClient
    Template.right_sidebar.events
        'click #logout': -> AccountsTemplates.logout()
        
    Template.nav.onCreated ->
        @autorun -> 
            Meteor.subscribe 'me'
            Meteor.subscribe 'users'
        
    Template.dashboard.onRendered ->
        Meteor.setTimeout ->
            $('.ui.dropdown').dropdown()
        , 400
        
    Template.nav.onRendered ->
        Meteor.setTimeout ->
            $('.ui.dropdown').dropdown()
        , 1000
        # Meteor.setTimeout ->
        #     $('.item').popup()
        # , 400
        
        
        
    Template.nav.helpers



if Meteor.isServer
    Meteor.publish 'me', ->
        Meteor.users.find @userId,
            fields: 
                courses: 1
