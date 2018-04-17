Template.edit_price.events
    'change #price': ->
        doc_id = FlowRouter.getParam('doc_id')
        price = $('#price').val()

        Docs.update doc_id,
            $set: price: price
            
Template.edit_title.events
    'blur #title': ->
        title = $('#title').val()
        Docs.update FlowRouter.getParam('doc_id'),
            $set: title: title

Template.edit_type.events
    'blur #type': ->
        type = $('#type').val()
        Docs.update FlowRouter.getParam('doc_id'),
            $set: type: type
            
Template.building_code.events
    'blur #building_code': (e,t)->
        building_code = $(e.currentTarget).closest('#building_code').val()
        Docs.update @_id,
            $set: building_code: building_code

Template.due_date.events
    'change #due_date': (e,t)->
        due_date = e.currentTarget.value
        Docs.update @_id,
            $set: due_date: due_date

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

Template.staff.events
    'blur #staff': (e,t)->
        staff = $(e.currentTarget).closest('#staff').val()
        Docs.update @_id,
            $set: staff: staff

Template.notes.events
    'blur #notes': (e,t)->
        notes =  $(e.currentTarget).closest('#notes').val()
        Docs.update @_id,
            $set: notes: notes
