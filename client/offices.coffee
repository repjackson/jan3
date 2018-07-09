FlowRouter.route '/offices', action: ->
    BlazeLayout.render 'layout', main: 'offices'


Template.offices.helpers
    settings: ->
        collection: 'offices'
        rowsPerPage: 10
        showFilter: true
        showRowCount: true
        # showColumnToggles: true
        fields: [
            { key: 'ev.ID', label: 'JPID' }
            { key: 'ev.MASTER_LICENSEE', label: 'Name' }
            { key: 'ev.MASTER_OFFICE_MANAGER', label: 'Manager' }
            { key: 'ev.MASTER_OFFICE_OWNER', label: 'Owner' }
            { key: 'ev.ev.TELEPHONE', label: 'Phone' }
            { key: 'ev.ADDR_STREET', label: 'Address' }
            { key: '', label: 'View', tmpl:Template.view_button }
        ]


Template.office_admin_section.onRendered ->
    Meteor.setTimeout ->
        $('.ui.tabular.menu .item').tab()
    , 500
    # Meteor.setTimeout ->
    #     $('.checkbox').checkbox()
    # , 500

    
Template.office_view.onCreated ->
    @autorun -> Meteor.subscribe 'office', FlowRouter.getParam('doc_id')
Template.office_admin_section.onCreated ->
    @autorun -> Meteor.subscribe 'type', 'rule'

    
Template.office_admin_section.helpers
    current_office: ->
        page_office = Docs.findOne FlowRouter.getParam('doc_id')
        # console.log page_office
        return page_office
        
    rule_docs: -> Docs.find type:'rule'
        
    hours_key: -> "escalation_#{@number}_hours"
    
    primary_franchisee_toggle_key: -> "escalation_#{@number}_primary_contact_franchisee"
    primary_contact_key: -> "escalation_#{@number}_primary_contact"

    secondary_franchisee_toggle_key: -> "escalation_#{@number}_secondary_contact_franchisee"
    secondary_contact_key: -> "escalation_#{@number}_secondary_contact"
        
    is_primary_indivdual: ->
        page_office = Docs.findOne FlowRouter.getParam('doc_id')
        prim_ind = page_office["escalation_#{@number}_primary_contact"]
        console.log prim_ind
        prim_ind
        
        
    is_secondary_indivdual: ->
        page_office = Docs.findOne FlowRouter.getParam('doc_id')
        page_office["escalation_#{@number}_secondary_contact"]
        
    
Template.office_customers.onCreated ->
    @autorun -> Meteor.subscribe 'office_customers', FlowRouter.getParam('doc_id')
Template.office_customers.helpers    
    office_customers: ->  
        page_office = Docs.findOne FlowRouter.getParam('doc_id')
        Docs.find
            type: "customer"
            "ev.MASTER_LICENSEE": page_office.ev.MASTER_LICENSEE
    settings: ->
        rowsPerPage: 10
        showFilter: true
        showRowCount: true
        showNavigation: 'auto'
        # showColumnToggles: true
        fields: [
            { key: 'ev.CUST_NAME', label: 'Customer Name' }
            { key: 'ev.ID', label: 'JPID' }
            { key: 'ev.FRANCHISEE', label: 'Franchisee' }
            # { key: 'ev.MASTER_LICENSEE', label: 'Master Licensee' }
            { key: 'ev.CUST_CONT_PERSON', label: 'Contact Person' }
            { key: 'ev.CUST_CONTACT_EMAIL', label: 'Contact Email' }
            { key: 'ev.TELEPHONE', label: 'Telephone' }
            { key: 'ev.ADDR_STREET', label: 'Address' }
            { key: '', label: 'View', tmpl:Template.view_button }
        ]


Template.office_incidents.onCreated ->
    @autorun -> Meteor.subscribe 'office_incidents', FlowRouter.getParam('doc_id')
Template.office_incidents.helpers    
    office_incidents: ->  
        page_office = Docs.findOne FlowRouter.getParam('doc_id')
        Docs.find
            incident_office_name: page_office.ev.MASTER_LICENSEE
            type: "incident"
    settings: ->
        rowsPerPage: 10
        showFilter: true
        showRowCount: true
        showNavigation: 'auto'
        # showColumnToggles: true
        fields: [
            # { key: 'incident_office_name', label: 'Office' }
            { key: 'customer_name', label: 'Customer' }
            { key: 'when', label: 'Logged'}
            { key: '', label: 'Type', tmpl:Template.incident_type_label }
            { key: 'incident_details', label: 'Details' }
            { key: 'level', label: 'Level' }
            { key: '', label: 'Assigned To', tmpl:Template.associated_users }
            { key: '', label: 'Actions Taken', tmpl:Template.small_doc_history }
            { key: '', label: 'View', tmpl:Template.view_button }
        ]



Template.office_employees.onCreated ->
    @autorun -> Meteor.subscribe 'office_employees', FlowRouter.getParam('doc_id')
Template.office_employees.helpers    
    collection: ->  
        page_office = Docs.findOne FlowRouter.getParam('doc_id')
        # console.log page_office
        Meteor.users.find
            "profile.office_name": page_office.ev.MASTER_LICENSEE
    settings: ->
        rowsPerPage: 10
        showFilter: true
        showRowCount: true
        showNavigation: 'auto'
        # showColumnToggles: true
        fields: [
            { key: 'username', label: 'Username' }
            { key: 'profile.first_name', label: 'First Name' }
            { key: 'profile.last_name', label: 'Last Name' }
            { key: 'ev.JOB_TITLE', label: 'Job Title' }
            { key: 'ev.WORK_TELEPHONE', label: 'Work Tel' }
            { key: 'email', label: 'Email' }
            { key: '', label: 'Publicize', tmpl:Template.toggle_user_published }
            { key: '', label: 'View', tmpl:Template.view_user_button }
        ]




Template.office_franchisees.onCreated ->
    @autorun -> Meteor.subscribe 'office_franchisees', FlowRouter.getParam('doc_id')
Template.office_franchisees.helpers    
    office_franchisees_obs: ->  
        page_office = Docs.findOne FlowRouter.getParam('doc_id')
        Docs.find
            type: "franchisee"
            "ev.MASTER_LICENSEE": page_office.ev.MASTER_LICENSEE
    settings: ->
        rowsPerPage: 10
        showFilter: true
        showRowCount: true
        # showColumnToggles: true
        fields: [
            { key: 'ev.ID', label: 'JPID' }
            { key: 'ev.FRANCHISEE', label: 'Name' }
            { key: 'ev.FRANCH_EMAIL', label: 'Email' }
            { key: 'ev.FRANCH_NAME', label: 'Short Name' }
            { key: 'ev.TELE_CELL', label: 'Phone' }
            # { key: 'ev.MASTER_LICENSEE', label: 'Office' }
            { key: '', label: 'View', tmpl:Template.view_button }
        ]
