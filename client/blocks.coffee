Template.toggle_boolean.events
    'click #make_featured': ->
        Docs.update FlowRouter.getParam('doc_id'), $set: featured: true

    'click #make_unfeatured': ->
        Docs.update FlowRouter.getParam('doc_id'), $set: featured: false

Template.add_button.events
    'click #add': -> 
        id = Docs.insert type:@type
        FlowRouter.go "/edit/#{id}"


Template.reference_single_doc.onCreated ->
    @autorun =>  Meteor.subscribe 'docs', [], @data.type


Template.reference_single_doc.helpers
    settings: -> 
        # console.log @
        {
            position: 'bottom'
            limit: 10
            rules: [
                {
                    collection: Docs
                    field: 'office_name'
                    matchAll: true
                    filter: { type: 'office' }
                    template: Template.search_result
                }
            ]
        }


Template.reference_single_doc.events
    'autocompleteselect #search': (event, template, doc) ->
        console.log 'selected ', doc
        $('#search').val ''
