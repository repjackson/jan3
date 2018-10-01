@selected_offices = new ReactiveArray []


Template.office_facet.helpers
    offices: ->
        doc_count = Docs.find().count()
        # if selected_tags.array().length
        if 0 < doc_count < 3
            Offices.find {
                # type:Template.currentData().type
                count: $lt: doc_count
                }, limit:42
        else
            cursor = Offices.find({}, limit:42)
            # console.log cursor.fetch()
            return cursor


    selected_offices: -> selected_offices.array()



Template.office_facet.events
    'click .select_office': -> selected_offices.push @name
    'click .unselect_office': -> selected_offices.remove @valueOf()
    'click #clear_offices': -> selected_offices.clear()
