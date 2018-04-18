if Meteor.isClient
    Template.edit_position.events
        'change #position': ->
            doc_id = FlowRouter.getParam('doc_id')
            position = $('#position').val()
    
            Docs.update doc_id,
                $set: position: position


