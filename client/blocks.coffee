Template.toggle_boolean.events
    'click #turn_on': ->
        data_doc = Template.parentData()
        Docs.update data_doc._id, $set: "#{@key}": true

    'click #turn_off': ->
        data_doc = Template.parentData()
        Docs.update data_doc._id, $set: "#{@key}": false

Template.toggle_boolean.helpers
    is_on: ->
        # page_doc = Docs.findOne FlowRouter.getQueryParam('doc_id')
        data_doc = Template.parentData()
        data_doc["#{@key}"]


Template.add_button.events
    'click #add': ->
        id = Docs.insert type:@type
        FlowRouter.go "/edit/#{id}"




Template.ticket_assignment_cell.onCreated ->
    @autorun =>  Meteor.subscribe 'assigned_to_users', @data._id

Template.ticket_assignment_cell.helpers
    # ticket_assignment_cell_class: ->
    #     if @assignment_timestamp
    #         now = Date.now()
    #         response = @assignment_timestamp - now
    #         calc = moment.duration(response).humanize()
    #         hour_amount = moment.duration(response).asHours()
    #         if hour_amount<-5 then 'negative' else 'positive'

    assigned_users: ->
        if @assigned_to
            Meteor.users.find
                _id: $in: @assigned_to


Template.call_method.events
    'click .call_method': ->
        Meteor.call @name, @argument, (err,res)->
            # else


Template.toggle_key.helpers
    toggle_key_button_class: ->
        current_doc = Docs.findOne FlowRouter.getQueryParam('doc_id')
        if @value
            if current_doc["#{@key}"] is @value then 'primary'
        # else if current_doc["#{@key}"] is true then 'primary' else ''
        else ''

Template.toggle_key.events
    'click .toggle_key': ->
        doc_id = FlowRouter.getQueryParam('doc_id')
        if @value
            Docs.update {_id:doc_id},
                { $set: "#{@key}": "#{@value}" }

        else if Template.parentData()["#{@key}"] is true
            Docs.update doc_id,
                $set: "#{@key}": false
        else
            Docs.update doc_id,
                $set: "#{@key}": true



Template.set_sla_key_value.events
    'click .set_page_key_value': ->
        sla_doc = Template.parentData(1)
        Docs.update sla_doc._id,
            { $set: "#{@key}": @value }

Template.set_sla_key_value.helpers
    set_value_button_class: ->
        sla_doc = Template.parentData(1)
        if sla_doc["#{@key}"] is @value then 'primary' else ''


Template.toggle_sla_boolean.helpers
    toggle_boolean_button_class: ->
        sla_doc = Template.parentData(1)
        if sla_doc["#{@key}"] is true then 'primary'
        else ''

Template.toggle_sla_boolean.events
    'click .trigger': (e,t)->
        sla_doc = Template.parentData(1)
        if sla_doc
            boolean_value = sla_doc["#{@key}"]

        Docs.update sla_doc._id,
            $set: "#{@key}": !boolean_value

Template.toggle_user_published.events
    'click #toggle_button': (e,t)->
        doc_id = FlowRouter.getQueryParam('doc_id')
        Meteor.users.update @_id,
            $set: published: !@published




Template.office_card.onCreated ->
    @autorun =>  Meteor.subscribe 'doc_by_jpid', @data.office_jpid
Template.office_card.helpers
    office_doc: ->
        context = Template.currentData(0)
        doc =
            Docs.findOne
                type:'office'
                "ev.ID": context.office_jpid
        doc

Template.customer_card.onCreated ->
    @autorun =>  Meteor.subscribe 'doc_by_jpid', @data.customer_jpid
Template.customer_card.helpers
    customer_doc: ->
        context = Template.currentData(0)
        doc =
            Docs.findOne
                type:'customer'
                "ev.ID": context.customer_jpid
        doc


Template.franchisee_card.onCreated ->
    @autorun =>  Meteor.subscribe 'doc_by_jpid', @data.franchisee_jpid
Template.franchisee_card.helpers
    franchisee_doc: ->
        context = Template.currentData(0)
        doc =
            Docs.findOne
                type:'franchisee'
                "ev.ID": context.franchisee_jpid
        doc



# Template.view_stat.onCreated ->
#     @autorun =>  Meteor.subscribe 'stat', @data.doc_type, @data.stat_type
# Template.view_stat.helpers
#     stat_value: ->
#         inputs = Template.currentData(0)
#         doc =
#             Stats.findOne
#                 doc_type:inputs.doc_type
#                 stat_type:inputs.stat_type
#         if doc
#             doc.amount





Template.assignment_widget.onCreated ()->
    @autorun => Meteor.subscribe 'assigned_users', FlowRouter.getQueryParam('doc_id')
    @user_results = new ReactiveVar( [] )

Template.assignment_widget.onRendered ()->
    unassigned_username = FlowRouter.getQueryParam 'unassign'
    if unassigned_username
        console.log 'found unassign', unassigned_username
        Meteor.call 'unassign_user_from_ticket', FlowRouter.getQueryParam('doc_id'), unassigned_username, (err,res)->
            if err then console.error err



Template.assignment_widget.events
    'click .clear_results': (e,t)->
        t.user_results.set null

    'keyup #multiple_user_select_input': (e,t)->
        multiple_user_select_input_value = $(e.currentTarget).closest('#multiple_user_select_input').val().trim()
        current_ticket = Docs.findOne FlowRouter.getQueryParam('doc_id')
        Meteor.call 'lookup_office_user_by_username_and_officename', current_ticket.ticket_office_name, multiple_user_select_input_value, (err,res)=>
            if err then console.error err
            else
                t.user_results.set res

    'click .select_user': (e,t) ->
        key = Template.parentData(0).key
        page_doc = Docs.findOne FlowRouter.getQueryParam('doc_id')
        # searched_value = doc["#{template.data.key}"]
        Meteor.call 'assign_user', page_doc._id, @, (err,res)=>
        $('#multiple_user_select_input').val ''
        t.user_results.set null
        if page_doc.type is 'task'
            # Meteor.call 'send_message', @username, Meteor.user().username, "You have been assigned to task: #{page_doc.title}."
            Meteor.call 'send_email_about_task_assignment', page_doc._id, @username
        else if page_doc.type is 'ticket'
            Docs.update page_doc._id,
                $set: assignment_timestamp:Date.now()
            # Meteor.call 'send_message', @username, Meteor.user().username, "You have been assigned to ticket: #{page_doc.title}."
            Meteor.call 'send_email_about_ticket_assignment', page_doc._id, @username

    'click .pull_user': ->
        context = Template.currentData(0)
        if confirm "Remove #{@username}?"
            page_doc = Docs.findOne FlowRouter.getQueryParam('doc_id')
            Meteor.call 'unassign_user', page_doc._id, @

Template.assignment_widget.helpers
    ticket_assignment_timestamp: ->
        parent_doc = Docs.findOne FlowRouter.getQueryParam('doc_id')
        parent_doc.assignment_timestamp
    user_results: ->
        user_results = Template.instance().user_results.get()
        user_results

    assigned_users: ->
        parent_doc = Docs.findOne FlowRouter.getQueryParam('doc_id')
        if parent_doc
            Meteor.users.find(_id: $in: parent_doc.assigned_to)


Template.author_info.onCreated ->
    @autorun => Meteor.subscribe 'author', @data.author_id

# Template.blocks.onCreated ->
    # if @data.tags and typeof @data.tags is 'string'
    #     split_tags = @data.tags.split ','
    # else
    #     split_tags = @data.tags





Template.set_key_value.events
    'click .set_key_value': ->
        Docs.update Template.parentData(1)._id,
            { $set: "#{@key}": @value }


Template.set_page_key_value.events
    'click .set_page_key_value': ->
        page = Docs.findOne
            type:'page'
            slug:FlowRouter.getParam('page_slug')
        Docs.update page._id,
            { $set: "#{@key}": @value }

Template.set_key_value_2.events
    'click .set_key_value': ->
        Docs.update Template.parentData(2)._id,
            { $set: "#{@key}": @value }

Template.set_key_value.helpers
    set_value_button_class: ->
        if Template.parentData()["#{@key}"] is @value then 'primary' else ''


Template.set_page_key_value.helpers
    set_value_button_class: ->
        page = Docs.findOne
            type:'page'
            slug:FlowRouter.getParam('page_slug')
        if page["#{@key}"] is @value then 'inverted blue' else ''


Template.set_key_value_2.helpers
    set_value_button_class: ->
        if Template.parentData(2)["#{@key}"] is @value then 'primary' else ''


Template.edit_block_text_field.helpers
    block_key_value: () ->
        block_doc = Template.parentData()
        if block_doc
            block_doc["#{@key}"]
Template.edit_block_text_field.events
    'change .text_field': (e,t)->
        text_value = e.currentTarget.value
        Docs.update Template.parentData()._id,
            { $set: "#{@key}": text_value }


Template.edit_block_number_field.helpers
    block_key_value: () ->
        block_doc = Template.parentData()
        if block_doc
            block_doc["#{@key}"]
Template.edit_block_number_field.events
    'change .number_field': (e,t)->
        number_value = parseInt e.currentTarget.value
        Docs.update Template.parentData()._id,
            { $set: "#{@key}": number_value }


Template.set_field_key_value.events
    'click .set_field_key_value': (e,t)->
        Meteor.call 'update_block_field', Template.parentData(2)._id, Template.parentData(), @key, @value

Template.toggle_block_field_boolean.events
    'click .toggle_block_field_boolean': (e,t)->
        Meteor.call 'update_block_field', Template.parentData(2)._id, Template.parentData(), @key, true

Template.toggle_block_field_boolean.helpers
    toggle_value_button_class: ->
        if Template.parentData(2)["#{@key}"] is true then 'primary' else ''



Template.view_button.helpers
    url:-> "/p/#{@type}?doc_id=#{@_id}"


Template.ticket_status.helpers
    page_context: ->
        page_doc = Docs.findOne FlowRouter.getQueryParam('doc_id')
Template.ticket_status.events
    'click .reopen': ->
        Docs.update FlowRouter.getQueryParam('doc_id'),
            $set: open:true

    'click .close': ->
        ticket = Docs.findOne FlowRouter.getQueryParam('doc_id')
        Docs.update FlowRouter.getQueryParam('doc_id'),
            $set: open:false
        Docs.insert
            type:'event'
            parent_id: FlowRouter.getQueryParam('doc_id')
            event_type:'ticket_close'
            text:"#{Meteor.user().username} closed ticket."
        Docs.insert
            type:'event'
            parent_id: FlowRouter.getQueryParam('doc_id')
            event_type:'emailed_customer_contact'
            text:"Customer #{ticket.customer_name} emailed about ticket close."


Template.customer_ticket_status.helpers
    page_context: ->
        page_doc = Docs.findOne FlowRouter.getQueryParam('doc_id')

    feedback: ->
        Docs.findOne
            type:'feedback'
            parent_id: FlowRouter.getQueryParam('doc_id')

Template.customer_ticket_status.events
    'click .add_feedback': ->
        ticket = Docs.findOne FlowRouter.getQueryParam('doc_id')
        Docs.update FlowRouter.getQueryParam('doc_id'),
            $set: feedback:true
        Docs.insert
            type:'feedback'
            ticket_id: FlowRouter.getQueryParam('doc_id')

    'click .close': ->
        ticket = Docs.findOne FlowRouter.getQueryParam('doc_id')
        Docs.update FlowRouter.getQueryParam('doc_id'),
            $set: open:false
        Docs.insert
            type:'event'
            parent_id: FlowRouter.getQueryParam('doc_id')
            event_type:'ticket_close'
            text:"#{Meteor.user().username} closed ticket."
        Docs.insert
            type:'event'
            parent_id: FlowRouter.getQueryParam('doc_id')
            event_type:'emailed_customer_contact'
            text:"Customer #{ticket.customer_name} emailed about ticket close."


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
