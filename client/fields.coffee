Template.edit_number_field.events
    'change #number_field': (e,t)->
        number_value = e.currentTarget.value
        Docs.update FlowRouter.getParam('doc_id'),
            $set: "#{@key}": number_value
            


Template.edit_date_field.events
    'change #date_field': (e,t)->
        date_value = e.currentTarget.value
        Docs.update FlowRouter.getParam('doc_id'),
            $set: "#{@key}": date_value


Template.edit_text_field.events
    'change #text_field': (e,t)->
        text_value = e.currentTarget.value
        Docs.update FlowRouter.getParam('doc_id'),
            $set: "#{@key}": text_value



Template.complete.events
    'click #mark_complete': (e,t)->
        Docs.update @_id,
            $set: complete: true
    'click #mark_incomplete': (e,t)->
        Docs.update @_id,
            $set: complete: false

Template.complete.helpers
    complete_class: -> if @complete then 'green' else 'basic'
    incomplete_class: -> if @complete then 'basic' else 'red'
