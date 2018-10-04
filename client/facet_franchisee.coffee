@selected_franchisees = new ReactiveArray []


Template.franchisee_facet.helpers
    franchisees: ->
        doc_count = Docs.find().count()
        # if selected_tags.array().length
        if 0 < doc_count < 3
            Franchisees.find {
                # type:Template.currentData().type
                count: $lt: doc_count
                }, limit:42
        else
            cursor = Franchisees.find({}, limit:42)
            # console.log cursor.fetch()
            return cursor

    franchisee_class: ->
        button_class = []
        # console.log @index
        switch
            when @index <= 5 then button_class.push ' '
            when @index <= 10 then button_class.push 'small'
            when @index <= 15 then button_class.push 'tiny '
            when @index <= 20 then button_class.push ' mini'
        return button_class

    selected_franchisees: -> selected_franchisees.array()



Template.franchisee_facet.events
    'click .select_franchisee': -> selected_franchisees.push @name
    'click .unselect_franchisee': -> selected_franchisees.remove @valueOf()
    'click #clear_franchisees': -> selected_franchisees.clear()
