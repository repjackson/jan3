FlowRouter.route '/', action: ->
    BlazeLayout.render 'layout', 
        main: 'dashboard'


Template.my_office_contacts.helpers
    crew: -> Meteor.users.find {_id:$ne:Meteor.userId()}, limit:4

Template.dashboard.helpers


Template.dashboard_office_contacts_list.onCreated ->
    @autorun -> Meteor.subscribe 'my_office_contacts'
Template.dashboard_office_contacts_list.helpers
    office_contacts: -> Meteor.users.find( _id:$ne:Meteor.userId() )


Template.customer_special_services.onCreated ->
    @autorun -> Meteor.subscribe 'my_special_services'
Template.customer_special_services.helpers
    my_special_services: -> Docs.find type:'special_service'



Template.customer_incidents_widget.onCreated ->
    @autorun -> Meteor.subscribe 'my_customer_incidents'
Template.customer_incidents_widget.helpers    
    customer_incidents: ->  
        user = Meteor.user()
        if user and user.profile and user.profile.customer_jpid
            # customer_doc = Docs.findOne "ev.ID":user.profile.customer_jpid
            Docs.find {
                customer_jpid: user.profile.customer_jpid
                type: "incident"
            }, limit:20
