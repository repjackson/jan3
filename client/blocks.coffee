Template.toggle_boolean.events
    'click #make_featured': ->
        Docs.update FlowRouter.getParam('doc_id'), $set: featured: true

    'click #make_unfeatured': ->
        Docs.update FlowRouter.getParam('doc_id'), $set: featured: false

Template.add_button.events
    'click #add': -> 
        id = Docs.insert type:@type
        FlowRouter.go "/edit/#{id}"


Template.reference_office.onCreated ->
    @autorun =>  Meteor.subscribe 'docs', [], @data.type
Template.reference_customer.onCreated ->
    @autorun =>  Meteor.subscribe 'docs', [], @data.type


Template.reference_office.helpers
    settings: -> 
        # console.log @
        {
            position: 'bottom'
            limit: 10
            rules: [
                {
                    collection: Docs
                    field: "#{@search_field}"
                    matchAll: true
                    filter: { type: "#{@type}" }
                    template: Template.office_result
                }
            ]
        }

Template.reference_customer.helpers
    settings: -> 
        # console.log @
        {
            position: 'bottom'
            limit: 10
            rules: [
                {
                    collection: Docs
                    field: "#{@search_field}"
                    matchAll: true
                    filter: { type: "#{@type}" }
                    template: Template.customer_result
                }
            ]
        }


Template.reference_office.events
    'autocompleteselect #search': (event, template, doc) ->
        # console.log 'selected ', doc
        searched_value = doc["#{template.data.key}"]
        # console.log 'template ', template
        # console.log 'search value ', searched_value
        Docs.update FlowRouter.getParam('doc_id'),
            $set: "#{template.data.key}": "#{doc._id}"
        $('#search').val ''

Template.reference_customer.events
    'autocompleteselect #search': (event, template, doc) ->
        # console.log 'selected ', doc
        searched_value = doc["#{template.data.key}"]
        # console.log 'template ', template
        # console.log 'search value ', searched_value
        Docs.update FlowRouter.getParam('doc_id'),
            $set: "#{template.data.key}": "#{doc._id}"
        $('#search').val ''




Template.toggle_view_mode_button.helpers
    viewing_list: -> Session.equals 'viewing_list', false

Template.toggle_view_mode_button.events
    'click #toggle_view_mode': ->
        if Session.equals 'viewing_list', true
            Session.set 'viewing_list', false
        else
            Session.set 'viewing_list', true
            
