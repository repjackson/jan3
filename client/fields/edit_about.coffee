Template.edit_about.events
    'blur #about': ->
        about = $('#about').val()
        Docs.update FlowRouter.getParam('doc_id'),
            $set: about: about