if Meteor.isClient
    Template.my_incidents.onCreated -> @autorun -> Meteor.subscribe('my_incidents')
    
    Template.my_incidents.helpers
        my_incidents: -> 
            Incidents.find {},
                sort: publish_date: -1
                
if Meteor.isServer
    Meteor.publish 'my_incidents', ->
        Incidents.find author_id: @userId

