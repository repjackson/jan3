Template.office_dashboard.helpers
    office_doc: -> Docs.findOne "ev.ID":FlowRouter.getParam('jpid')


Template.office_employees.onCreated ->
    @autorun -> Meteor.subscribe 'office_employees', FlowRouter.getParam('jpid'), Session.get('query'), parseInt(Session.get('page_size')),Session.get('sort_key'), Session.get('sort_direction'), parseInt(Session.get('skip'))
    @autorun => Meteor.subscribe 'office_employee_count', FlowRouter.getParam('jpid')

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
    
    
    
Template.set_sla_key_value.events
    'click .set_page_key_value': ->
        rule_doc = Template.currentData()
        current_sla_doc = 
            Docs.findOne 
                type:'sla_config'
                office_jpid:FlowRouter.getParam('jpid')
                escalation_number: rule_doc.number
        console.log @
        console.log Template.parentData(0)
        console.log Template.parentData(1)
        console.log Template.parentData(2)
        console.log Template.parentData(3)
        # Docs.update page._id,
        #     { $set: "#{@key}": @value }

Template.set_sla_key_value.helpers
    set_value_button_class: ->
        current_sla_doc = 
            Docs.findOne
                type:'sla_config'
        # page = Docs.findOne 
        #     type:'page'
        #     slug:FlowRouter.getParam('page_slug')
        # if page["#{@key}"] is @value then 'inverted blue' else 'basic'

Template.office_sla.onCreated ->
    @autorun -> Meteor.subscribe 'type', 'incident_type'
    @autorun -> Meteor.subscribe 'type', 'rule'
    @autorun -> Meteor.subscribe 'office_sla_settings',FlowRouter.getParam('jpid')
    @autorun -> Meteor.subscribe 'static_office_employees', FlowRouter.getParam('jpid')
    Session.setDefault 'incident_type_selection', 'change_service'

Template.office_sla.events
    'click .select_incident_type': ->
        Session.set 'incident_type_selection', @slug

            

    
Template.office_sla.helpers
    current_office: ->
        page_office = Docs.findOne "ev.ID":FlowRouter.getParam('jpid')
        console.log page_office
        return page_office
    incident_types: -> Docs.find {type:'incident_type'}
    select_incident_type_button_class: -> if Session.equals('incident_type_selection', @slug) then 'blue' else 'basic'
    selected_incident_type: -> Session.get 'incident_type_selection'
    is_initial: -> Template.parentData().number is 1    
    rule_docs: -> Docs.find {type:'rule'}, sort:number:1

    incident_type_owner_value: ->
        page_office = Docs.findOne "ev.ID":FlowRouter.getParam('jpid')
        current_incident_type = Session.get 'incident_type_selection'
        incident_type_owner_value = page_office["#{current_incident_type}_incident_owner"]
        # console.log incident_type_owner_value
        return incident_type_owner_value
    sla_settings_doc: ->    
        console.log @
        rule_doc = Template.currentData()

        sla_setting_doc = 
            Docs.findOne 
                type:'sla_setting'
                escalation_number: rule_doc.number
                incident_type:Session.get('incident_type_selection')
            
        console.log sla_setting_doc
        unless sla_setting_doc
            Docs.insert
                type:'sla_setting'
                escalation_number: rule_doc.number
                office_jpid:FlowRouter.getParam 'jpid'                
                incident_type:Session.get('incident_type_selection')
        sla_setting_doc

Template.incident_owner_select.helpers
    user_results: ->
        user_results = Template.instance().user_results.get()
        user_results

    selected_user: ->
        sla_setting_doc = Template.currentData()
        console.log Template.parentData(1)
        console.log Template.parentData(2)

        context = Template.currentData(0)
        context = Template.parentData(1)
        context = Template.parentData(2)
        # office_doc = Docs.findOne "ev.ID":FlowRouter.getParam('jpid')
        if sla_setting_doc.incident_owner
            # console.log office_doc["#{context.key}"]
            Meteor.users.findOne
                username: sla_setting_doc.incident_owner
        else
            false
        
        
        
Template.incident_owner_select.onCreated ()->
    @user_results = new ReactiveVar( [] )
    
Template.incident_owner_select.events
    'click .select_office_user': (e,t) ->
        # console.log e
        # console.log t
        # console.log @
        sla_setting_doc = Template.currentData()
        # console.log Template.parentData(0)
        # console.log Template.parentData(1)
        # console.log Template.parentData(2)
        # console.log Template.parentData(3)
        # key = Template.parentData(0).key
        # searched_value = doc["#{template.data.key}"]
        # office_doc = Docs.findOne "ev.ID":FlowRouter.getParam('jpid')
        # console.log key
        # console.log @username
        
        
        Docs.update sla_setting_doc._id,
            $set: incident_owner: @username
        # console.log Docs.findOne(office_doc_id)["#{key}"]
        # $(e.currentTarget).closest('#office_username_query').val ''
        t.user_results.set null


    'keyup #office_username_query': (e,t)->
        office_username_query = $(e.currentTarget).closest('#office_username_query').val().trim()
        # $('#office_username_query').val ''
        Session.set 'office_username_query', office_username_query
        current_office_id = FlowRouter.getParam('jpid')
        Meteor.call 'lookup_office_user_by_username_and_office_jpid', current_office_id, office_username_query, (err,res)=>
            if err then console.error err
            else
                t.user_results.set res


    'click .pull_user': (e,t)->
        context = Template.currentData()
        console.log e
        console.log t
        console.log @
        console.log Template.currentData()
        console.log Template.parentData(0)
        console.log Template.parentData(1)
        console.log Template.parentData(2)
        console.log Template.parentData(3)
        
        swal {
            title: "Remove #{context.incident_owner} as incident owner?"
            # text: 'Confirm delete?'
            type: 'info'
            animation: false
            showCancelButton: true
            closeOnConfirm: true
            cancelButtonText: 'Cancel'
            confirmButtonText: 'Unassign'
            confirmButtonColor: '#da5347'
        }, =>
            Docs.update context._id,
                $unset: incident_owner: 1


Template.view_sla_contact.helpers
    selected_contact: ->
        context = Template.currentData(0)
        office_doc = Docs.findOne "ev.ID":FlowRouter.getParam('jpid')
        if office_doc["#{context.key}"]
            Meteor.users.findOne
                username: office_doc["#{context.key}"]
        else
            false
        