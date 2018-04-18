Template.session_edit_button.events
    'click .edit_this': -> Session.set 'editing_id', @_id
    'click .save_doc': -> Session.set 'editing_id', null

Template.session_edit_button.helpers
    button_classes: -> Template.currentData().classes


Template.session_edit_icon.events
    'click .edit_this': -> Session.set 'editing_id', @_id
    'click .save_doc': -> Session.set 'editing_id', null

Template.session_edit_icon.helpers
    button_classes: -> Template.currentData().classes


Template.toggle_boolean.events
    'click #make_featured': ->
        Docs.update FlowRouter.getParam('doc_id'),
            $set: featured: true

    'click #make_unfeatured': ->
        Docs.update FlowRouter.getParam('doc_id'),
            $set: featured: false
