if Meteor.isClient
    Template.nav.events
        'click #logout': -> 
            AccountsTemplates.logout()
            
        
    Template.nav.onCreated ->
        @autorun -> 
            Meteor.subscribe 'me'
            Meteor.subscribe 'my_notifications'
        
    Template.dashboard.onRendered ->
        Meteor.setTimeout ->
            $('.ui.dropdown').dropdown()
        , 400
        
    Template.nav.onRendered ->
        Meteor.setTimeout ->
            $('.ui.dropdown').dropdown()
        , 1000
        
        
        
    Template.nav.helpers
        notifications: -> Notifications.find()



if Meteor.isServer
    Meteor.publish 'my_notifications', ->
        Notifications.find()
        
        
    Meteor.publish 'me', ->
        Meteor.users.find @userId,
            fields: 
                courses: 1
