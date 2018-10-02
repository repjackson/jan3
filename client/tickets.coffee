Template.add_ticket_button.events
    'click #add_ticket': ->
        Meteor.call 'log_ticket', (err,res)->
            if err then console.error err
            else
                FlowRouter.go "/p/submit_ticket?doc_id=#{res}"


Template.ticket_type_label.onRendered ->
    Meteor.setTimeout ->
        $('img').popup()
    , 2000

Template.ticket_type_label.helpers
    ticket_type_label: ->
        switch @ticket_type
            when 'missed_service' then 'Missed Service'
            when 'team_member_infraction' then 'Team Member Infraction'
            when 'change_service' then 'Request a Change of Service'
            when 'problem' then 'Report a Problem or Service Issue'
            when 'special_request' then 'Request a Special Service'
            when 'other' then 'Other'

    type_label_class: ->
        switch @ticket_type
            when 'missed_service' then 'blue'
            when 'team_member_infraction' then 'green'
            when 'change_service' then 'teal'
            when 'problem' then 'yellow'
            when 'special_request' then 'orange'
            when 'other' then 'grey'

    ticket_type_icon: ->
        switch @ticket_type
            when 'missed_service' then 'leave'
            when 'team_member_infraction' then 'unfriend-male'
            when 'change_service' then 'transfer-between-users'
            when 'problem' then 'box-important'
            when 'special_request' then 'carpet-cleaning'
            when 'other' then 'grey'

Template.ticket_type_small.helpers
    ticket_type_label: ->
        switch @ticket_type
            when 'missed_service' then 'Missed Service'
            when 'team_member_infraction' then 'Team Member Infraction'
            when 'change_service' then 'Request a Change of Service'
            when 'problem' then 'Report a Problem or Service Issue'
            when 'special_request' then 'Request a Special Service'
            when 'other' then 'Other'

    type_label_class: ->
        switch @ticket_type
            when 'missed_service' then 'blue'
            when 'team_member_infraction' then 'green'
            when 'change_service' then 'teal'
            when 'problem' then 'yellow'
            when 'special_request' then 'orange'
            when 'other' then 'grey'

    ticket_type_icon: ->
        switch @ticket_type
            when 'missed_service' then 'leave'
            when 'team_member_infraction' then 'unfriend-male'
            when 'change_service' then 'transfer-between-users'
            when 'problem' then 'box-important'
            when 'special_request' then 'carpet-cleaning'
            when 'other' then 'grey'

Template.level_icon.helpers
    is_level_one: -> @level is 1
    is_level_two: -> @level is 2
    is_level_three: -> @level is 3
    is_level_four: -> @level is 4




Template.submit_ticket.onCreated ->
    @autorun -> Meteor.subscribe 'type','ticket_type'
#     @autorun -> Meteor.subscribe 'type','rule'
#     @autorun -> Meteor.subscribe 'ticket', FlowRouter.getQueryParam('doc_id')


Template.submit_ticket.helpers
    ticket_type_docs: -> Docs.find type:'ticket_type'
    can_submit: ->
        ticket = Docs.findOne FlowRouter.getQueryParam('doc_id')
        user = Meteor.user()
        is_customer = user and user.roles and ('customer' in user.roles)
        ticket.service_date and ticket.ticket_details and ticket.ticket_type and is_customer

Template.submit_ticket.events
    'click .submit': ->
        doc_id = FlowRouter.getQueryParam 'doc_id'

        FlowRouter.go "/p/ticket_customer_view?doc_id=#{doc_id}"
        Meteor.call 'submit_ticket', doc_id, (err,res)->



Template.view_sla_contact.helpers
    user_ob: ->
        Meteor.users.findOne
            username: @username



Template.ticket_status.onCreated ->
    @is_closing = new ReactiveVar false
    @autorun => Meteor.subscribe 'type', 'close_ticket_type'
Template.ticket_status.helpers
    ticket: -> Docs.findOne FlowRouter.getQueryParam('doc_id')
    is_closing: -> Template.instance().is_closing.get()
    closing_class: -> if Template.instance().is_closing.get() is true then 'active' else ''
    close_ticket_types: -> Docs.find type:'close_ticket_type'

Template.ticket_status.events
    'click .reopen': ->
        Docs.update FlowRouter.getQueryParam('doc_id'),
            $set: open:true

    'click .start_closing': (e,t)->
        t.is_closing.set(!t.is_closing.get())
        Meteor.setTimeout ->
            $('.ui.fluid.reason.dropdown').dropdown()
        ,200

    'click .finish_closing': (e,t)->
        ticket_id = FlowRouter.getQueryParam('doc_id')
        ticket = Docs.findOne ticket_id

        details_val = t.$('#close_details').val()
        Docs.update ticket_id,
            $set:
                open:false
                close_timestamp: Date.now()
                close_details: details_val
                close_author: Meteor.user().username
        Docs.insert
            type:'event'
            parent_id: ticket_id
            event_type:'ticket_close'
            text:"#{Meteor.user().username} closed ticket with note: #{details_val}"
            ticket_id: ticket_id
            office_jpid: ticket.office_jpid
            customer_jpid: ticket.customer_jpid
        Docs.insert
            type:'event'
            parent_id: ticket_id
            event_type:'email_customer'
            text:"Customer '#{ticket.customer_name}' emailed about ticket close."
            ticket_id: ticket_id
            office_jpid: ticket.office_jpid
            customer_jpid: ticket.customer_jpid
        t.is_closing.set false


Template.feedback_widget.onCreated ->
    @autorun => Meteor.subscribe 'feedback_doc', FlowRouter.getQueryParam('doc_id')
Template.feedback_widget.helpers
    page_context: ->
        page_doc = Docs.findOne FlowRouter.getQueryParam('doc_id')

    feedback_doc: ->
        Docs.findOne
            type:'feedback'
            parent_id: FlowRouter.getQueryParam('doc_id')

    good_class: ->
        feedback_doc = Docs.findOne
            type:'feedback'
            parent_id: FlowRouter.getQueryParam('doc_id')
        if feedback_doc.rating
            if feedback_doc.rating is 'good'
                'green'
            else
                'grey outline'
    bad_class: ->
        feedback_doc = Docs.findOne
            type:'feedback'
            parent_id: FlowRouter.getQueryParam('doc_id')
        if feedback_doc.rating
            if feedback_doc.rating is 'bad'
                'red'
            else
                'grey outline'
Template.feedback_widget.events
    'click .add_feedback': ->
        ticket = Docs.findOne FlowRouter.getQueryParam('doc_id')
        Docs.update FlowRouter.getQueryParam('doc_id'),
            $set: feedback:true
        Docs.insert
            type:'feedback'
            parent_id: FlowRouter.getQueryParam('doc_id')

    'click .thumbs.up': ->
        feedback_doc = Docs.findOne
            type:'feedback'
            parent_id: FlowRouter.getQueryParam('doc_id')
        Docs.update feedback_doc._id,
            $set: rating: 'good'

    'click .thumbs.down': ->
        feedback_doc = Docs.findOne
            type:'feedback'
            parent_id: FlowRouter.getQueryParam('doc_id')
        Docs.update feedback_doc._id,
            $set: rating: 'bad'

    'blur .feedback_details': (e,t)->
        details = e.currentTarget.value
        feedback_doc = Docs.findOne
            type:'feedback'
            parent_id: FlowRouter.getQueryParam('doc_id')
        Docs.update feedback_doc._id,
            $set:details:details

    'click .submit_feedback': (e,t)->
        feedback_doc = Docs.findOne
            type:'feedback'
            parent_id: FlowRouter.getQueryParam('doc_id')
        Docs.update feedback_doc._id,
            $set:submitted:true


Template.complete_ticket_task.onCreated ()->
    doc_id = FlowRouter.getQueryParam 'doc_id'
    @autorun => Meteor.subscribe 'doc', doc_id

Template.complete_ticket_task.onRendered ()->
    @autorun () =>
        if @subscriptionsReady()
            doc_id = FlowRouter.getQueryParam 'doc_id'
            if ticket
                ticket = Docs.findOne doc_id
            # if unassigned_username
                # console.log 'found unassign', unassigned_username


Template.complete_ticket_task.events
    'click .submit_completion_task': (e,t)->
        completion_details = t.$('#completion_details').val()
        unassigned_username = FlowRouter.getQueryParam 'unassign'
        ticket_id = FlowRouter.getQueryParam('doc_id')
        Meteor.call 'complete_ticket_task', ticket_id, unassigned_username, completion_details, (err,res)->
            if err then console.error err
            else
                FlowRouter.go("/p/ticket_admin_view?doc_id=#{ticket_id}")

Template.ticket_close_user_info.onCreated ()->
    unassign_username = FlowRouter.getQueryParam 'unassign'
    @autorun => Meteor.subscribe 'user', unassign_username
Template.ticket_close_user_info.helpers
    completing_user: ->
        unassign_username = FlowRouter.getQueryParam 'unassign'
        Meteor.users.findOne username:unassign_username



Template.office_ticket_widget.onCreated ()->
    @autorun => Meteor.subscribe 'jpid', FlowRouter.getQueryParam 'jpid'
    @autorun => Meteor.subscribe 'type', 'rule'
    @autorun => Meteor.subscribe 'office_stats', FlowRouter.getQueryParam 'jpid'

Template.office_ticket_widget.helpers
    page_office: ->
        Docs.findOne
            "ev.ID": FlowRouter.getQueryParam 'jpid'
    rules: -> Docs.find {type:'rule'}, sort:number:-1



