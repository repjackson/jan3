FlowRouter.route '/alfred', action: ->
    BlazeLayout.render 'layout', 
        sub_nav: 'admin_nav'
        main: 'alfred'


Template.alfred.onCreated ->
    # @autorun => Meteor.subscribe 'type', 'bit'
    @autorun => Meteor.subscribe 'count', 'bit'
    @autorun => Meteor.subscribe 'incomplete_bit_count'
    @autorun => Meteor.subscribe 'facet', 
        selected_tags.array()
        selected_author_ids.array()
        selected_location_tags.array()
        selected_timestamp_tags.array()
        type='bit'
        author_id=null


    
Template.alfred.onRendered ->
    $('.indicating.progress').progress();
 

Template.alfred.events
    'keyup #ask_alfred': (e,t)->
        val = $('#ask_alfred').val().trim()
        if e.which is 13
            unless val.length is 0
                Meteor.call 'ask_alfred', val.toString(), (err,res)=>
                    if err
                        Bert.alert "#{err.reason}", 'danger', 'growl-top-right'
                    else
                        Bert.alert "Searched #{val}", 'success', 'growl-top-right'
                        console.log res
                    $('#ask_alfred').val ''

Template.bit_segment.onCreated ->
    # @autorun => Meteor.subscribe 'type', 'bit'
    # @autorun => Meteor.subscribe 'bit', @data._id

    
Template.bit_edit.onCreated ->
    # @autorun => Meteor.subscribe 'type', 'bit'
    @autorun => Meteor.subscribe 'bit', @data._id

    
Template.bit_view.onCreated ->
    # @autorun => Meteor.subscribe 'type', 'bit'
    @autorun => Meteor.subscribe 'bit', @data._id

    
    
Template.alfred.helpers
    alfred: ->  Docs.find { type:'bit'}

Template.bit_edit.helpers
    bit: -> Doc.findOne FlowRouter.getParam('doc_id')
    
Template.bit_edit.events
    'click #delete': ->
        template = Template.currentData()
        swal {
            title: 'Delete bit?'
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
                FlowRouter.go "/alfred"

