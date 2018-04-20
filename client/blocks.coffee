Template.toggle_boolean.events
    'click #make_featured': ->
        Docs.update FlowRouter.getParam('doc_id'),
            $set: featured: true

    'click #make_unfeatured': ->
        Docs.update FlowRouter.getParam('doc_id'),
            $set: featured: false



Template.add_button.events
    'click #add': -> 
        id = Docs.insert type:@type
        FlowRouter.go "/edit/#{id}"
