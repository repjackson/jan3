@selected_status = new ReactiveArray []
Template.status_facet.helpers
    status: ->
        doc_count = Docs.find().count()
        if 0 < doc_count < 3
            Status.find {
                count: $lt: doc_count
                }, limit:42
        else
            cursor = Status.find({}, limit:42)
            return cursor
    selected_status: -> selected_status.array()
Template.status_facet.events
    'click .select_status': -> selected_status.push @name
    'click .unselect_status': -> selected_status.remove @valueOf()
    'click #clear_status': -> selected_status.clear()
