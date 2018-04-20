if Meteor.isClient
    Template.html_create.onCreated ->
        @autorun => Meteor.subscribe 'facet_doc', @data.tags
        
    Template.html_create.helpers
        doc: ->
            tags = Template.currentData().tags
            split_array = tags.split ','

            Docs.findOne
                tags: split_array
    
        template_tags: -> Template.currentData().tags
    
        doc_classes: -> Template.parentData().classes

    Template.html_create.events
        'click .create_doc': (e,t)->
            tags = t.data.tags
            split_array = tags.split ','
            new_id = Docs.insert
                tags: split_array
            Session.set 'editing_id', new_id

        'blur #staff': ->
            staff = $('#staff').val()
            Docs.update @_id,
                $set: staff: staff