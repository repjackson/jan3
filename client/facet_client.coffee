@selected_levels = new ReactiveArray []


Template.ticket_facet.onCreated ->
    @autorun =>
        Meteor.subscribe('facet',
            selected_levels.array()
            selected_offices.array()
            selected_customers.array()
            selected_timestamp_tags.array()
            selected_status.array()
            type='ticket'
            )
        Meteor.subscribe 'usernames'

Template.ticket_facet.helpers
    tickets: -> Docs.find type:'ticket'
Template.level_facet.helpers
    levels: ->
        doc_count = Docs.find().count()
        # if selected_levels.array().length
        if 0 < doc_count < 3
            Levels.find {
                # type:Template.currentData().type
                count: $lt: doc_count
                }, limit:42
        else
            cursor = Levels.find({}, limit:42)
            # console.log cursor.fetch()
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
