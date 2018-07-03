FlowRouter.route '/offices', action: ->
    BlazeLayout.render 'layout', main: 'offices'

Template.offices.onCreated ->
    @autorun => Meteor.subscribe 'type', 'office'
    @autorun -> Meteor.subscribe 'office_counter_publication'

Template.offices.helpers
    current_office_counter: -> Counts.get 'office_counter'
    office_docs: -> Docs.find type: "office"

Template.office_admin_section.onRendered ->
    Meteor.setTimeout ->
        $('.ui.tabular.menu .item').tab()
    , 500
    # Meteor.setTimeout ->
    #     $('.checkbox').checkbox()
    # , 500

    
Template.office_view.onCreated ->
    @autorun -> Meteor.subscribe 'office', FlowRouter.getParam('doc_id')

    
Template.office_admin_section.helpers
    current_office: ->
        page_office = Docs.findOne FlowRouter.getParam('doc_id')
        # console.log page_office
        return page_office
        
    
    related_franchisees: ->  
        page_office = Docs.findOne FlowRouter.getParam('doc_id')
        Docs.find
            type: "franchisee"
            "ev.MASTER_LICENSEE": page_office.office_name
    
    
    
    
Template.office_customers.onCreated ->
    @autorun -> Meteor.subscribe 'office_customers', FlowRouter.getParam('doc_id')
Template.office_customers.helpers    
    office_customers: ->  
        page_office = Docs.findOne FlowRouter.getParam('doc_id')
        Docs.find
            type: "customer"
            "ev.MASTER_LICENSEE": page_office.ev.MASTER_LICENSEE


Template.office_incidents.onCreated ->
    @autorun -> Meteor.subscribe 'office_incidents', FlowRouter.getParam('doc_id')
Template.office_incidents.helpers    
    office_incidents: ->  
        page_office = Docs.findOne FlowRouter.getParam('doc_id')
        Docs.find
            incident_office_name: page_office.ev.MASTER_LICENSEE
            type: "incident"



Template.office_employees.onCreated ->
    @autorun -> Meteor.subscribe 'office_employees', FlowRouter.getParam('doc_id')
Template.office_employees.helpers    
    office_employee_obs: ->  
        page_office = Docs.findOne FlowRouter.getParam('doc_id')
        console.log page_office
        Meteor.users.find
            "profile.office_name": page_office.ev.MASTER_LICENSEE
