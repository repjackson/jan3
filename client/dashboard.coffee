FlowRouter.route '/', action: ->
    BlazeLayout.render 'layout', 
        main: 'dashboard'


Template.my_office_contacts.helpers
    crew: -> Meteor.users.find {_id:$ne:Meteor.userId()}, limit:4

Template.dashboard.helpers
    customer_incidents: -> Docs.find type:'incident'


Template.dashboard_office_contacts_list.helpers
    office_contacts: -> Meteor.users.find( _id:$ne:Meteor.userId() )
Template.customer_special_services.helpers
    my_special_services: -> Docs.find type:'special_service'



Template.customer_incidents_widget.onCreated ->
    @autorun -> Meteor.subscribe 'my_customer_incidents'
Template.customer_incidents_widget.helpers    
    customer_incidents_widget: ->  
        page_office = Docs.findOne FlowRouter.getParam('doc_id')
        Docs.find
            customer_jpid: user.profile.customer_jpid
            type: "incident"
