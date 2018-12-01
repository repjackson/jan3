if Meteor.isClient
    Template.ticket_type_part.onRendered ->
        Meteor.setTimeout ->
            $('img').popup()
        , 2000
    
    Template.ticket_type_part.helpers
        ticket_type_label: ->
            block_parent = Template.parentData(4)
            switch block_parent.ticket_type
                when 'missed_service' then 'Missed Service'
                when 'team_member_infraction' then 'Team Member Infraction'
                when 'change_service' then 'Request a Change of Service'
                when 'problem' then 'Report a Problem or Service Issue'
                when 'special_request' then 'Request a Special Service'
                when 'other' then 'Other'
    
        type_label_class: ->
            block_parent = Template.parentData(4)
            switch block_parent.ticket_type
                when 'missed_service' then 'blue'
                when 'team_member_infraction' then 'blue'
                when 'change_service' then 'teal'
                when 'problem' then 'yellow'
                when 'special_request' then 'orange'
                when 'other' then 'grey'
    
        ticket_type_icon: ->
            block_parent = Template.parentData(4)
            switch block_parent.ticket_type
                when 'missed_service' then 'leave'
                when 'team_member_infraction' then 'unfriend-male'
                when 'change_service' then 'transfer-between-users'
                when 'problem' then 'box-important'
                when 'special_request' then 'carpet-cleaning'
                when 'other' then 'grey'
    
    Template.level_part.helpers
        is_level_one: ->
            target = Template.parentData(4)
            target.level is 1
        is_level_two: ->
            target = Template.parentData(4)
            target.level is 2
        is_level_three: ->
            target = Template.parentData(4)
            target.level is 3
        is_level_four: ->
            target = Template.parentData(4)
            target.level is 4
    
    
    
    
    Template.submit_big.onCreated ->
        @autorun -> Meteor.subscribe 'type','ticket_type'
    #     @autorun -> Meteor.subscribe 'type','rule'
    
    
    
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
        closing_class: -> if Template.instance().is_closing.get() is true then 'active blue' else ''
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
    
    
    
    Template.ticket_close_user_info.onCreated ()->
        unassign_username = FlowRouter.getQueryParam 'unassign'
        @autorun => Meteor.subscribe 'user', unassign_username
    Template.ticket_close_user_info.helpers
        completing_user: ->
            unassign_username = FlowRouter.getQueryParam 'unassign'
            Meteor.users.findOne username:unassign_username
    
    
    
    Template.ticket_notes.onCreated ->
        @adding_note = new ReactiveVar false
    Template.ticket_notes.helpers
        adding_note: -> Template.instance().adding_note.get()
    
    Template.ticket_notes.events
        'click #start_adding_note': (e,t)->
            t.adding_note.set true
        'click #submit_note': (e,t)->
            note_val = t.$('#note_val').val()
            ticket_id = FlowRouter.getQueryParam('doc_id')
            ticket = Docs.findOne ticket_id
            Docs.insert
                type:'event'
                parent_id: ticket_id
                ticket_id: ticket_id
                event_type:'note'
                office_jpid: ticket.office_jpid
                franchisee_jpid: ticket.franchisee_jpid
                customer_jpid: ticket.customer_jpid
                text: "#{Meteor.user().username} added note: #{note_val}."
            t.adding_note.set false
            
    Template.tickets.onCreated ->
        @autorun -> Meteor.subscribe 'tickets'
            
    Template.tickets.helpers
        tickets: ->
            Docs.find
                type:'ticket'
    
if Meteor.isServer
    Meteor.publish 'tickets', ->
        Docs.find {
            type:'ticket'
        }, limit: 20