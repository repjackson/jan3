FlowRouter.route '/offices', action: ->
    BlazeLayout.render 'layout', main: 'offices'

FlowRouter.route '/office/:doc_id/incidents', 
    name: 'office_incidents'
    action: -> BlazeLayout.render 'layout', main: 'office_incidents'

FlowRouter.route '/office/:doc_id/employees', 
    name: 'office_employees'
    action: -> BlazeLayout.render 'layout', main: 'office_employees'

FlowRouter.route '/office/:doc_id/franchisees', 
    name: 'office_franchisees'
    action: -> BlazeLayout.render 'layout', main: 'office_franchisees'

FlowRouter.route '/office/:doc_id/customers', 
    name: 'office_customers'
    action: -> BlazeLayout.render 'layout', main: 'office_customers'

FlowRouter.route '/office/:doc_id/settings', 
    name: 'office_settings'
    action: -> BlazeLayout.render 'layout', main: 'office_settings'

Template.offices.onCreated ->
    @autorun -> Meteor.subscribe 'offices', Session.get('query'), parseInt(Session.get('page_size')),Session.get('sort_key'), Session.get('sort_direction'), parseInt(Session.get('skip'))
    # @autorun -> Meteor.subscribe 'office_counter_publication'

Template.offices.helpers
    all_offices: ->
        Docs.find {
            type:'office'
            },{ sort:"#{Session.get('sort_key')}":parseInt("#{Session.get('sort_direction')}")}
            

Template.office_header.helpers
    office_doc: -> Docs.findOne FlowRouter.getParam('doc_id')
    office_map_address: ->
        page_office = Docs.findOne FlowRouter.getParam('doc_id')
        encoded_address = encodeURIComponent "#{page_office.ev.ADDR_STREET} #{page_office.ev.ADDR_STREET_2} #{page_office.ev.ADDR_CITY},#{page_office.ev.ADDR_STATE} #{page_office.ev.ADDR_POSTAL_CODE} #{page_office.ev.MASTER_COUNTRY}"
        # console.log encoded_address
        "https://www.google.com/maps/search/?api=1&query=#{encoded_address}"


Template.office_header.onCreated ->
    @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')

Template.office_customers.onCreated ->
    @autorun -> Meteor.subscribe 'office_customers', FlowRouter.getParam('doc_id'), Session.get('query'), parseInt(Session.get('page_size')), Session.get('sort_key'), Session.get('sort_direction'), parseInt(Session.get('skip'))

# Template.office_customers.events
    # 'click #refresh_ny_customers': ->
    #     Meteor.call 'sync_ny_customers', ->

Template.office_customers.helpers    
    office_customers: ->  
        page_office = Docs.findOne FlowRouter.getParam('doc_id')
        if page_office
            Docs.find {
                type: "customer"
                "ev.ACCOUNT_STATUS": 'ACTIVE'
                "ev.MASTER_LICENSEE": page_office.ev.MASTER_LICENSEE
            },{ 
                sort:
                    "#{Session.get('sort_key')}":parseInt("#{Session.get('sort_direction')}")
            }


Template.office_incidents.onCreated ->
    @autorun -> Meteor.subscribe 'office_incidents', FlowRouter.getParam('doc_id'), Session.get('query'), parseInt(Session.get('page_size')),Session.get('sort_key'), Session.get('sort_direction'), parseInt(Session.get('skip'))
    

Template.office_incidents.helpers    
    office_incidents: ->  
        page_office = Docs.findOne FlowRouter.getParam('doc_id')
        if page_office
            Docs.find {
                incident_office_name: page_office.ev.MASTER_LICENSEE
                type: "incident"
            },{ sort:"#{Session.get('sort_key')}":parseInt("#{Session.get('sort_direction')}") }

Template.office_employees.onCreated ->
    @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
    @autorun -> Meteor.subscribe 'office_employees', FlowRouter.getParam('doc_id'), Session.get('query'), parseInt(Session.get('page_size')),Session.get('sort_key'), Session.get('sort_direction'), parseInt(Session.get('skip'))

Template.office_employees.helpers    
    office_employees: ->  
        page_office = Docs.findOne FlowRouter.getParam('doc_id')
        # console.log page_office
        Meteor.users.find {
            "profile.office_name": page_office.ev.MASTER_LICENSEE
        },{ 
            sort:
                "#{Session.get('sort_key')}":parseInt("#{Session.get('sort_direction')}")
        }

Template.office_franchisees.onCreated ->
    @autorun -> Meteor.subscribe 'office_franchisees', FlowRouter.getParam('doc_id'), Session.get('query'), parseInt(Session.get('page_size')),Session.get('sort_key'), Session.get('sort_direction'), parseInt(Session.get('skip'))
    

Template.office_franchisees.helpers  
    office_franchisees: ->
        page_office = Docs.findOne FlowRouter.getParam('doc_id')
        if page_office
            Docs.find {
                type: "franchisee"
                "ev.MASTER_LICENSEE": page_office.ev.MASTER_LICENSEE
            },{ 
                sort:
                    "#{Session.get('sort_key')}":parseInt("#{Session.get('sort_direction')}")
            }


Template.office_settings.onCreated ->
    @autorun -> Meteor.subscribe 'type', 'rule'
    @autorun -> Meteor.subscribe 'type', 'incident_type'
    @autorun -> Meteor.subscribe 'office_employees', FlowRouter.getParam('doc_id'), Session.get('query'), parseInt(Session.get('page_size')),Session.get('sort_key'), Session.get('sort_direction'), parseInt(Session.get('skip'))

Template.office_service_settings.onCreated ->
    @autorun -> Meteor.subscribe 'type', 'service'
    
# Template.office_settings.onRendered ->
#     Meteor.setTimeout =>
#         console.log '1'
#         $('.office_tab_menu .item').tab()
#         console.log '2'
#     , 1000
#     console.log '3'
    
    
Template.office_settings.events
    'click .select_incident_type': ->
        Session.set 'incident_type_selection', @slug


Template.office_service_settings.helpers
    services: -> Docs.find {type:'service'}
    select_service_button_class: ->
        page_office = Docs.findOne FlowRouter.getParam('doc_id')
        if @slug in page_office.services then 'blue' else 'basic'
        
Template.office_service_settings.events
    'click .select_service': -> 
        page_office = Docs.findOne FlowRouter.getParam('doc_id')
        if page_office 
            if page_office.services
                if @slug in page_office.services
                    Docs.update page_office._id,
                        $pull: services: @slug
                else
                    Docs.update page_office._id,
                        $addToSet: services: @slug
            else    
                Docs.update page_office._id,
                    $set: services: [@slug]
    
Template.office_settings.helpers
    current_office: ->
        page_office = Docs.findOne FlowRouter.getParam('doc_id')
        # console.log page_office
        return page_office
    incident_types: -> Docs.find {type:'incident_type'}
    select_incident_type_button_class: -> if Session.equals('incident_type_selection', @slug) then 'blue' else 'basic'
    selected_incident_type: -> Session.get 'incident_type_selection'
    is_initial: -> @number is 1    
    rule_docs: -> Docs.find {type:'rule'}, sort:number:1
    hours_key: -> 
        current_incident_type = Session.get 'incident_type_selection'
        "escalation_#{@number}_#{current_incident_type}_hours"
    franchisee_toggle_key: -> 
        current_incident_type = Session.get 'incident_type_selection'
        "escalation_#{@number}_#{current_incident_type}_contact_franchisee"
    customer_toggle_key: -> 
        current_incident_type = Session.get 'incident_type_selection'
        "escalation_#{@number}_#{current_incident_type}_contact_customer"
    primary_contact_key: -> 
        current_incident_type = Session.get 'incident_type_selection'
        # console.log "escalation_#{@number}_primary_contact"
        "escalation_#{@number}_#{current_incident_type}_primary_contact"
    primary_email_key: -> 
        current_incident_type = Session.get 'incident_type_selection'
        # console.log "escalation_#{@number}_primary_contact"
        "escalation_#{@number}_#{current_incident_type}_primary_email_option"
    primary_sms_key: -> 
        current_incident_type = Session.get 'incident_type_selection'
        # console.log "escalation_#{@number}_primary_contact"
        "escalation_#{@number}_#{current_incident_type}_primary_sms_option"
    secondary_contact_key: -> 
        current_incident_type = Session.get 'incident_type_selection'
        "escalation_#{@number}_#{current_incident_type}_secondary_contact"
    secondary_email_key: -> 
        current_incident_type = Session.get 'incident_type_selection'
        # console.log "escalation_#{@number}_secondary_contact"
        "escalation_#{@number}_#{current_incident_type}_secondary_email_option"
    secondary_sms_key: -> 
        current_incident_type = Session.get 'incident_type_selection'
        # console.log "escalation_#{@number}_secondary_contact"
        "escalation_#{@number}_#{current_incident_type}_secondary_sms_option"