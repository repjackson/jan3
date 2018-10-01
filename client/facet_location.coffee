@selected_location_tags = new ReactiveArray []

Template.location_facet.helpers
    location_tags: ->
        doc_count = Docs.find(type: Template.currentData().type).count()
        # if selected_location_tags.array().length
        if 0 < doc_count < 3
            Location_tags.find {
                count: $lt: doc_count
                }, limit:20
        else
            Location_tags.find({}, limit:20)


    location_tag_class: ->
        button_class = []
        switch
            when @index <= 5 then button_class.push ' '
            when @index <= 10 then button_class.push 'small'
            when @index <= 15 then button_class.push 'tiny '
            when @index <= 20 then button_class.push ' mini'
        return button_class

    selected_location_tags: -> selected_location_tags.array()



Template.location_facet.events
    'click .select_location_tag': -> selected_location_tags.push @name
    'click .unselect_location_tag': -> selected_location_tags.remove @valueOf()
    'click #clear_location_tags': -> selected_location_tags.clear()

    'keyup #search': (e,t)->
        e.preventDefault()
        val = $('#search').val().toLowerCase().trim()
        switch e.which
            when 13 #enter
                switch val
                    when 'clear'
                        selected_location_tags.clear()
                        $('#search').val ''
                    else
                        unless val.length is 0
                            selected_location_tags.push val.toString()
                            $('#search').val ''
            when 8
                if val.length is 0
                    selected_location_tags.pop()

    'autocompleteselect #search': (event, template, doc) ->
        # console.log 'selected ', doc
        selected_location_tags.push doc.name
        $('#search').val ''