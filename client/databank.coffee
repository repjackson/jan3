FlowRouter.route '/databank', action: ->
    BlazeLayout.render 'layout', 
        sub_nav: 'admin_nav'
        main: 'databank'


Template.databank.onCreated ->
    # @autorun => Meteor.subscribe 'type', 'item'
    @autorun => Meteor.subscribe 'count', 'item'
    @autorun => Meteor.subscribe 'incomplete_item_count'
    @autorun => Meteor.subscribe 'facet', 
        selected_tags.array()
        selected_author_ids.array()
        selected_location_tags.array()
        selected_timestamp_tags.array()
        type='item'
        author_id=null
Template.databank.onRendered ->
    # $('.indicating.progress').progress();
    

Template.databank.helpers
    databank: ->  Docs.find { type:'item'}
    databank_view: -> 
        array = selected_doc_types.array()
        return "databank_#{array[0]}"

    current_doc_type: -> 
        array = selected_doc_types.array()
        return array[0]




    

Template.item_segment.onCreated ->
    # @autorun => Meteor.subscribe 'type', 'item'
    # @autorun => Meteor.subscribe 'item', @data._id

    
Template.item_edit.onCreated ->
    # @autorun => Meteor.subscribe 'type', 'item'
    @autorun => Meteor.subscribe 'item', @data._id

    
Template.item_view.onCreated ->
    # @autorun => Meteor.subscribe 'type', 'item'
    @autorun => Meteor.subscribe 'item', @data._id

    
    

Template.item_edit.helpers
    item: -> Doc.findOne FlowRouter.getParam('doc_id')
    
Template.item_edit.events
    'click #delete': ->
        template = Template.currentData()
        swal {
            title: 'Delete item?'
            # text: 'Confirm delete?'
            type: 'error'
            animation: false
            showCancelButton: true
            closeOnConfirm: true
            cancelButtonText: 'Cancel'
            confirmButtonText: 'Delete'
            confirmButtonColor: '#da5347'
        }, =>
            doc = Docs.findOne FlowRouter.getParam('doc_id')
            # console.log doc
            Docs.remove doc._id, ->
                FlowRouter.go "/databank"



