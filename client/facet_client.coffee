@selected_levels = new ReactiveArray []
@selected_ticket_types = new ReactiveArray []


Template.ticket_facet.onCreated ->
    Session.setDefault 'view_mode', 'cards'
    @autorun =>
        Meteor.subscribe('facet',
            selected_levels.array()
            selected_offices.array()
            selected_customers.array()
            selected_timestamp_tags.array()
            selected_status.array()
            selected_ticket_types.array()
            type='ticket'
            )
        Meteor.subscribe 'usernames'

Template.ticket_facet.helpers
    tickets: -> Docs.find type:'ticket'
    view_segments: -> Session.equals 'view_mode', 'segments'
    view_cards: -> Session.equals 'view_mode', 'cards'
    view_cards_class: -> if Session.equals 'view_mode', 'cards' then 'primary' else ''
    view_segments_class: -> if Session.equals 'view_mode', 'segments' then 'primary' else ''

Template.ticket_facet.events
    'click .set_view_cards': -> Session.set 'view_mode', 'cards'
    'click .set_view_segments': -> Session.set 'view_mode', 'segments'

Template.level_facet.helpers
    levels: ->
        doc_count = Docs.find().count()
        if 0 < doc_count < 3
            Levels.find {
                count: $lt: doc_count
                }, limit:42
        else
            cursor = Levels.find({}, limit:42)
            return cursor

    cloud_level_class: ->
        button_class = []
        switch
            when @index <= 5 then button_class.push ' '
            when @index <= 10 then button_class.push 'small'
            when @index <= 15 then button_class.push 'tiny '
            when @index <= 20 then button_class.push ' mini'
        return button_class
    selected_levels: -> selected_levels.array()
Template.level_facet.events
    'click .select_level': -> selected_levels.push @name
    'click .unselect_level': -> selected_levels.remove @valueOf()
    'click #clear_levels': -> selected_levels.clear()


Template.ticket_type_facet.helpers
    ticket_types: ->
        doc_count = Docs.find().count()
        if 0 < doc_count < 3
            Ticket_types.find {
                count: $lt: doc_count
                }, limit:42
        else
            cursor = Ticket_types.find({}, limit:42)
            return cursor

    cloud_ticket_type_class: ->
        button_class = []
        switch
            when @index <= 5 then button_class.push ' '
            when @index <= 10 then button_class.push 'small'
            when @index <= 15 then button_class.push 'tiny '
            when @index <= 20 then button_class.push ' mini'
        return button_class
    selected_ticket_types: -> selected_ticket_types.array()
Template.ticket_type_facet.events
    'click .select_ticket_type': -> selected_ticket_types.push @name
    'click .unselect_ticket_type': -> selected_ticket_types.remove @valueOf()
    'click #clear_ticket_types': -> selected_ticket_types.clear()
