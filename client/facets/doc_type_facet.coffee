@selected_doc_types = new ReactiveArray []

Template.doc_type_facet.onCreated ->
    @autorun => Meteor.subscribe 'type', @data.doc_type

Template.doc_type_facet.onRendered ->
    @autorun =>
        if @subscriptionsReady()
            Meteor.setTimeout ->
                $('.ui.accordion').accordion()
            , 500


Template.doc_type_facet.helpers
    doc_types: ->
        doc_count = Docs.find().count()
        # if selected_doc_types.array().length
        if 0 < doc_count < 3
            Docs.find { 
                type:Template.currentData().doc_type
                count: $lt: doc_count
                }, limit:42
        else
            cursor = Docs.find({
                type:Template.currentData().doc_type
                }, limit:42)
            # console.log cursor.fetch()
            return cursor
            
    cloud_doc_type_class: ->
        button_class = []
        switch
            when @index <= 5 then button_class.push ' '
            when @index <= 10 then button_class.push 'small'
            when @index <= 15 then button_class.push 'tiny '
            when @index <= 20 then button_class.push ' mini'
        return button_class

    selected_doc_types: -> selected_doc_types.array()
    # settings: -> {
    #     position: 'bottom'
    #     limit: 10
    #     rules: [
    #         {
    #             collection: doc_types
    #             field: 'name'
    #             matchAll: false
    #             template: Template.doc_type_result
    #         }
    #     ]
    # }



Template.doc_type_facet.events
    'click .select_doc_type': -> 
        selected_doc_types.clear()
        selected_doc_types.push @slug
    'click .unselect_doc_type': -> selected_doc_types.remove @valueOf()
    'click #clear_doc_types': -> selected_doc_types.clear()

    'keyup #search': (e,t)->
        e.preventDefault()
        val = $('#search').val().toLowerCase().trim()
        switch e.which
            when 13 #enter
                switch val
                    when 'clear'
                        selected_doc_types.clear()
                        $('#search').val ''
                    else
                        unless val.length is 0
                            selected_doc_types.push val.toString()
                            $('#search').val ''
            when 8
                if val.length is 0
                    selected_doc_types.pop()
                    
    'autocompleteselect #search': (event, template, doc) ->
        # console.log 'selected ', doc
        selected_doc_types.push doc.name
        $('#search').val ''
