Template.doc.onCreated ->
    delta = Docs.findOne type:'delta'
    @autorun => Meteor.subscribe 'schema_blocks'
    if delta.doc_id
        @autorun => Meteor.subscribe 'doc', delta.doc_id
        @autorun => Meteor.subscribe 'children', delta.doc_id

Template.delta.onRendered ->
    Meteor.setTimeout ->
        $('.accordion').accordion();
    , 500
    Meteor.setTimeout ->
        $('.ui.button').popup()
    , 1000



Template.doc.events
    'click .remove_doc': ->
        delta = Docs.findOne type:'delta'
        target_doc = Docs.findOne _id:delta.doc_id
        if confirm "Delete #{target_doc.title}?"
            Docs.remove target_doc._id
            Docs.update delta._id,
                $set:
                    doc_id:null
                    editing:false
                    doc_view:false
        Session.set 'is_calculating', true
        Meteor.call 'fo', (err,res)->
            if err then console.log err
            else
                Session.set 'is_calculating', false


Template.doc.helpers
    detail_doc: ->
        delta = Docs.findOne type:'delta'
        Docs.findOne delta.doc_id

    delta_doc: -> Docs.findOne type:'delta'

    fields: ->
        console.log @

    local_doc: ->
        if @data
            Docs.findOne @data.valueOf()
        else
            Docs.findOne @valueOf()


    value: ->
        parent = Template.parentData()
        parent["#{@valueOf()}"]
        
        # delta = Docs.findOne type:'delta'
        # values = []
        # if @keys
        #     for key in @keys
        #         values.push parent["#{@key}"]
        # values