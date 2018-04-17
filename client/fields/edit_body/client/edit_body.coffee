Template.edit_body.events
    'blur #body': (e,t)->
        doc_id = FlowRouter.getParam('doc_id')
        body = $('#body').val()

        Docs.update doc_id,
            $set: 
                body: body
