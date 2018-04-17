Template.edit_name.events
    'blur #first_name': ->
        first_name = $('#first_name').val()
        Docs.update FlowRouter.getParam('doc_id'),
            $set: first_name: first_name
            
    'blur #last_name': ->
        last_name = $('#last_name').val()
        Docs.update FlowRouter.getParam('doc_id'),
            $set: last_name: last_name
            
            