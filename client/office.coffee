Template.office_service_settings.onCreated ->
    @autorun -> Meteor.subscribe 'type', 'service'

Template.office_service_settings.helpers
    services: -> Docs.find {type:'service'}
    select_service_button_class: ->
        page_office =
            Docs.findOne
                office_jpid:Meteor.user().office_jpid
                type:'office'
        if @slug in page_office.services then 'active green' else ''

Template.office_service_settings.events
    'click .select_service': ->
        page_office =
            Docs.findOne
                office_jpid:Meteor.user().office_jpid
                type:'office'
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


Template.office_sla.onCreated ->
    @autorun -> Meteor.subscribe 'type', 'ticket_type'
    @autorun -> Meteor.subscribe 'type', 'rule'
    @autorun -> Meteor.subscribe 'office_sla_settings',Meteor.user().office_jpid
    @autorun -> Meteor.subscribe 'static_office_employees', Meteor.user().office_jpid
    Session.setDefault 'ticket_type_selection', 'change_service'

Template.office_sla.events
    'click .select_ticket_type': ->
        Session.set 'ticket_type_selection', @slug


    'click .add_sla_setting_doc': (e,t)->
        Docs.insert
            type:'sla_setting'
            escalation_number: @number
            office_jpid:Meteor.user().office_jpid
            ticket_type:Session.get('ticket_type_selection')


Template.office_sla.helpers
    current_office: ->
        page_office =
            Docs.findOne
                office_jpid:Meteor.user().office_jpid
                type:'office'
        return page_office
    ticket_types: -> Docs.find {type:'ticket_type'}
    select_ticket_type_button_class: -> if Session.equals('ticket_type_selection', @slug) then 'active green' else ''
    selected_ticket_type: -> Session.get 'ticket_type_selection'
    is_initial: -> Template.parentData().number is 1
    rule_docs: -> Docs.find {type:'rule'}, sort:number:1

    ticket_type_owner_value: ->
        page_office =
            Docs.findOne
                office_jpid:Meteor.user().office_jpid
                type:'office'
        current_ticket_type = Session.get 'ticket_type_selection'
        ticket_type_owner_value = page_office["#{current_ticket_type}_ticket_owner"]
        return ticket_type_owner_value

    sla_settings_doc: ->
        rule_doc = Template.currentData()
        sla_setting_doc =
            Docs.findOne {
                type:'sla_setting'
                escalation_number: rule_doc.number
                office_jpid: Meteor.user().office_jpid
                ticket_type:Session.get('ticket_type_selection')
            }
        return sla_setting_doc




Template.ticket_owner_select.onCreated ()->
    @user_results = new ReactiveVar( [] )

Template.ticket_owner_select.helpers
    user_results: ->
        user_results = Template.instance().user_results.get()
        user_results

    selected_user: ->
        sla_setting_doc = Template.currentData()

        # office_doc =
        Docs.findOne
            office_jpid:Meteor.user().office_jpid
            type:'office'
        if sla_setting_doc.ticket_owner
            Meteor.users.findOne
                username: sla_setting_doc.ticket_owner
        else
            false

Template.ticket_owner_select.events
    'click .clear_results': (e,t)->
        t.user_results.set null

    'click .select_owner': (e,t) ->
        sla_setting_doc = Template.currentData()
        # key = Template.parentData(0).key
        # searched_value = doc["#{template.data.key}"]
        # office_doc =
        Docs.findOne
            office_jpid:Meteor.user().office_jpid
            type:'office'
        Meteor.call('set_ticket_owner', Meteor.user().office_jpid, Session.get('ticket_type_selection'), @username)
        t.user_results.set null


    'keyup #query_owner': (e,t)->
        owner_val = $(e.currentTarget).closest('#query_owner').val().trim()
        # $('#query_owner').val ''
        # Session.set 'query_owner', owner_val
        current_office_id = Meteor.user().office_jpid
        Meteor.call 'lookup_office_user_by_username_and_office_jpid', current_office_id, owner_val, (err,res)=>
            if err then console.error err
            else
                t.user_results.set res


    'click .pull_user': (e,t)->
        context = Template.currentData()

        if confirm "Remove #{context.ticket_owner} as ticket owner?"
            Docs.update context._id,
                $unset: ticket_owner: 1




Template.secondary_contact_widget.onCreated ()->
    @user_results = new ReactiveVar( [] )

Template.secondary_contact_widget.events
    'click .clear_results': (e,t)->
        t.user_results.set null

    'click .select_secondary': (e,t) ->
        sla_setting_doc = Template.currentData()
        # key = Template.parentData(0).key
        # searched_value = doc["#{template.data.key}"]
        # office_doc =
        Docs.findOne
            office_jpid:Meteor.user().office_jpid
            type:'office'

        Docs.update sla_setting_doc._id,
            $set: secondary_contact: @username
        # $(e.currentTarget).closest('#office_username_query').val ''
        t.user_results.set null


    'keyup #secondary_input': (e,t)->
        input_val = $(e.currentTarget).closest('#secondary_input').val().trim()
        # $('#office_username_query').val ''
        current_office_jpid = Met  eor.user().office_jpid
        Meteor.call 'lookup_office_user_by_username_and_office_jpid', current_office_jpid, input_val, (err,res)=>
            if err then console.error err
            else
                t.user_results.set res


    'click .pull_secondary': (e,t)->
        context = Template.currentData()
        if confirm "Remove #{context.secondary_contact} as secondary contact?"
            Docs.update context._id,
                $unset:
                    secondary_contact: 1
                $set:
                    sms_secondary: false
                    email_secondary: false

Template.secondary_contact_widget.helpers
    user_results: ->
        user_results = Template.instance().user_results.get()
        user_results

    selected_user: ->
        sla_setting_doc = Template.currentData(0)

        # office_doc =
        Docs.findOne
            office_jpid:Meteor.user().office_jpid
            type:'office'
        if sla_setting_doc.secondary_contact
            found = Meteor.users.findOne
                username: sla_setting_doc.secondary_contact
            return found
        else
            false

    secondary_contact: ->
        sla_setting_doc = Template.currentData(0)
        sla_setting_doc.secondary_contact




Template.office_roles.helpers
    office_employees: -> Meteor.users.find()



