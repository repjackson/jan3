Template.office_dashboard.helpers
    office_doc: -> Docs.findOne "ev.ID":FlowRouter.getParam('jpid')


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

            
    'click .add_sla_setting_doc': (e,t)->
        # console.log 'this', @
        
        # console.log 'current', Template.currentData()
        # console.log 'parent', Template.parentData(1)
        # console.log 'parent', Template.parentData(2)

        Docs.insert
            type:'sla_setting'
            escalation_number: @number
            office_jpid:FlowRouter.getParam('jpid')      
            incident_type:Session.get('incident_type_selection')
        # sla_setting_doc

    
Template.office_sla.helpers
    current_office: ->
        page_office = Docs.findOne "ev.ID":FlowRouter.getParam('jpid')
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
        return incident_type_owner_value
    
    sla_settings_doc: ->    
        rule_doc = Template.currentData()
        # console.log 'rule doc', rule_doc
        sla_setting_doc = 
            Docs.findOne {
                type:'sla_setting'
                escalation_number: rule_doc.number
                office_jpid:FlowRouter.getParam('jpid') 
                incident_type:Session.get('incident_type_selection')
            }
        return sla_setting_doc
    
    
    
    
Template.incident_owner_select.onCreated ()->
    @user_results = new ReactiveVar( [] )
    
Template.incident_owner_select.helpers
    user_results: ->
        user_results = Template.instance().user_results.get()
        user_results

    selected_user: ->
        sla_setting_doc = Template.currentData()

        # office_doc = Docs.findOne "ev.ID":FlowRouter.getParam('jpid')
        if sla_setting_doc.incident_owner
            Meteor.users.findOne
                username: sla_setting_doc.incident_owner
        else
            false
        
Template.incident_owner_select.events
    'click .select_owner': (e,t) ->
        sla_setting_doc = Template.currentData()
        # key = Template.parentData(0).key
        # searched_value = doc["#{template.data.key}"]
        # office_doc = Docs.findOne "ev.ID":FlowRouter.getParam('jpid')
        Meteor.call('set_incident_owner', FlowRouter.getParam('jpid'), Session.get('incident_type_selection'), @username)
        t.user_results.set null


    'keyup #query_owner': (e,t)->
        owner_val = $(e.currentTarget).closest('#query_owner').val().trim()
        # $('#query_owner').val ''
        # Session.set 'query_owner', owner_val
        current_office_id = FlowRouter.getParam('jpid')
        Meteor.call 'lookup_office_user_by_username_and_office_jpid', current_office_id, owner_val, (err,res)=>
            if err then console.error err
            else
                t.user_results.set res


    'click .pull_user': (e,t)->
        context = Template.currentData()
        
        swal {
            title: "Remove #{context.incident_owner} as incident owner?"
            # text: 'Confirm delete?'
            type: 'info'
            animation: false
            showCancelButton: true
            closeOnConfirm: true
            cancelButtonText: 'Cancel'
            confirmButtonText: 'Remove'
            confirmButtonColor: '#da5347'
        }, =>
            Docs.update context._id,
                $unset: incident_owner: 1




Template.secondary_contact_widget.onCreated ()->
    @user_results = new ReactiveVar( [] )
    
Template.secondary_contact_widget.events
    'click .select_secondary': (e,t) ->
        sla_setting_doc = Template.currentData()
        # key = Template.parentData(0).key
        # searched_value = doc["#{template.data.key}"]
        # office_doc = Docs.findOne "ev.ID":FlowRouter.getParam('jpid')
        
        Docs.update sla_setting_doc._id,
            $set: secondary_contact: @username
        # $(e.currentTarget).closest('#office_username_query').val ''
        t.user_results.set null


    'keyup #secondary_input': (e,t)->
        input_val = $(e.currentTarget).closest('#secondary_input').val().trim()
        # $('#office_username_query').val ''
        current_office_jpid = FlowRouter.getParam('jpid')
        Meteor.call 'lookup_office_user_by_username_and_office_jpid', current_office_jpid, input_val, (err,res)=>
            if err then console.error err
            else
                t.user_results.set res


    'click .pull_secondary': (e,t)->
        context = Template.currentData()
        
        swal {
            title: "Remove #{context.secondary_contact} as secondary contact?"
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
                $unset: secondary_contact: 1

Template.secondary_contact_widget.helpers
    user_results: ->
        user_results = Template.instance().user_results.get()
        user_results

    selected_user: ->
        sla_setting_doc = Template.currentData(0)

        # office_doc = Docs.findOne "ev.ID":FlowRouter.getParam('jpid')
        if sla_setting_doc.secondary_contact
            found = Meteor.users.findOne
                username: sla_setting_doc.secondary_contact
            console.log found
            return found
        else
            false
        
    secondary_contact: ->
        sla_setting_doc = Template.currentData(0)
        sla_setting_doc.secondary_contact






# Template.view_sla_contact.helpers
#     selected_contact: ->
#         context = Template.currentData(0)
#         office_doc = Docs.findOne "ev.ID":FlowRouter.getParam('jpid')
#         if office_doc["#{context.key}"]
#             Meteor.users.findOne
#                 username: office_doc["#{context.key}"]
#         else
#             false
        