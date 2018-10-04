@selected_timestamp_tags = new ReactiveArray []

Template.timestamp_facet.helpers
    timestamp_tags: ->
        doc_count = Docs.find(type:'ticket').count()
        if 0 < doc_count < 3
            Timestamp_tags.find {
                count: $lt: doc_count
                }, limit:10
        else
            Timestamp_tags.find({}, limit:10)

    timestamp_tag_class: ->
        button_class = []
        switch
            when @index <= 5 then button_class.push ' '
            when @index <= 10 then button_class.push 'small'
            when @index <= 15 then button_class.push 'tiny '
            when @index <= 20 then button_class.push ' mini'
        return button_class

    selected_timestamp_tags: -> selected_timestamp_tags.array()



Template.timestamp_facet.events
    'click .select_timestamp_tag': -> selected_timestamp_tags.push @name
    'click .unselect_timestamp_tag': -> selected_timestamp_tags.remove @valueOf()
    'click #clear_timestamp_tags': -> selected_timestamp_tags.clear()
