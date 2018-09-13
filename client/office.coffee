# Template.office_header.onCreated ->
#     @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('jpid')
#     @autorun -> Meteor.subscribe 'office_stats', FlowRouter.getParam('jpid')

# Template.office_header.events
#     'click #calc_office_stats': ->
#         Meteor.call 'calc_office_stats', FlowRouter.getParam('jpid'), (err,res)->
#             if err then console.error err
#             else
#                 console.log res
# Template.office_header.helpers
#     # current_name: -> console.log FlowRouter.getRouteName()
#     office_doc: -> Docs.findOne "ev.ID":FlowRouter.getParam('jpid')
#     office_map_address: ->
#         page_office = Docs.findOne "ev.ID":FlowRouter.getParam('jpid')
#         encoded_address = encodeURIComponent "#{page_office.ev.ADDR_STREET} #{page_office.ev.ADDR_STREET_2} #{page_office.ev.ADDR_CITY},#{page_office.ev.ADDR_STATE} #{page_office.ev.ADDR_POSTAL_CODE} #{page_office.ev.MASTER_COUNTRY}"
#         # console.log encoded_address
#         "https://www.google.com/maps/search/?api=1&query=#{encoded_address}"

Template.office_dashboard.helpers
    office_doc: -> Docs.findOne "ev.ID":FlowRouter.getParam('jpid')


Template.office_employees.onCreated ->
    @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('jpid')
    @autorun -> Meteor.subscribe 'office_employees', FlowRouter.getParam('jpid'), Session.get('query'), parseInt(Session.get('page_size')),Session.get('sort_key'), Session.get('sort_direction'), parseInt(Session.get('skip'))
    @autorun => Meteor.subscribe 'office_employee_count', FlowRouter.getParam('jpid')
    Session.set('page_size',10)
    Session.set('skip',0)
    Session.set 'page_number', 1

Template.office_employees.onRendered ->
    Meteor.setTimeout ->
        $('img').popup()
    , 1000

Template.office_employees.helpers    
    office_employees: ->  
        page_office = Docs.findOne "ev.ID":FlowRouter.getParam('jpid')
        # console.log page_office
        if page_office
            Meteor.users.find {
                "ev.COMPANY_NAME": page_office.ev.MASTER_LICENSEE
            },{ sort:"#{Session.get('sort_key')}":parseInt("#{Session.get('sort_direction')}") }




Template.office_service_settings.onCreated ->
    @autorun -> Meteor.subscribe 'type', 'service'
    
Template.office_service_settings.helpers
    services: -> Docs.find {type:'service'}
    select_service_button_class: ->
        page_office = Docs.findOne "ev.ID":FlowRouter.getParam('jpid')
        if @slug in page_office.services then 'blue' else 'basic'
        
Template.office_service_settings.events
    'click .select_service': -> 
        page_office = Docs.findOne "ev.ID":FlowRouter.getParam('jpid')
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
    
    
    
    

Template.office_settings.onCreated ->
    @autorun -> Meteor.subscribe 'type', 'rule'
    @autorun -> Meteor.subscribe 'type', 'incident_type'
    @autorun -> Meteor.subscribe 'static_office_employees', FlowRouter.getParam('jpid')
    @autorun -> Meteor.subscribe 'doc_by_jpid', FlowRouter.getParam('jpid')
    Session.setDefault 'incident_type_selection', 'change_service'

Template.office_settings.events
    'click .select_incident_type': ->
        Session.set 'incident_type_selection', @slug

    
Template.office_settings.helpers
    current_office: ->
        page_office = Docs.findOne "ev.ID":FlowRouter.getParam('jpid')
        console.log page_office
        return page_office
    incident_types: -> Docs.find {type:'incident_type'}
    select_incident_type_button_class: -> if Session.equals('incident_type_selection', @slug) then 'blue' else 'basic'
    selected_incident_type: -> Session.get 'incident_type_selection'
    is_initial: -> @number is 1    
    rule_docs: -> Docs.find {type:'rule'}, sort:number:1
    incident_type_owner_key: -> 
        current_incident_type = Session.get 'incident_type_selection'
        "#{current_incident_type}_incident_owner"

    incident_type_owner_value: ->
        page_office = Docs.findOne "ev.ID":FlowRouter.getParam('jpid')
        current_incident_type = Session.get 'incident_type_selection'
        incident_type_owner_value = page_office["#{current_incident_type}_incident_owner"]
        # console.log incident_type_owner_value
        return incident_type_owner_value

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
        
        
