FlowRouter.route '/', action: ->
    BlazeLayout.render 'layout', 
        main: 'dashboard'


Template.my_office_contacts.helpers
    crew: -> Meteor.users.find {_id:$ne:Meteor.userId()}, limit:4

Template.dashboard.helpers
    office_contacts: -> Meteor.users.find( _id:$ne:Meteor.userId() )
    customer_incidents: -> Docs.find type:'incident'
    my_special_services: ->
        Docs.find
            type:'special_service'