Template.boolean_edit.events
    'click .toggle_field': (e,t)->
        delta = Docs.findOne type:'delta'
        target_doc = Docs.findOne _id:delta.detail_id
        bool_value = target_doc["#{@key}"]
        # console.log t.data
        # console.log @

        if bool_value and bool_value is true
            Docs.update target_doc._id,
                $set: "#{t.data.key}": false
        else
            Docs.update target_doc._id,
                $set: "#{t.data.key}": true

Template.string_edit.events
    'blur .string_val': (e,t)->
        delta = Docs.findOne type:'delta'
        target_doc = Docs.findOne _id:delta.detail_id

        val = t.$('.string_val').val()
        Docs.update target_doc._id,
            $set:
                "#{t.data.key}": val




Template.number_edit.events
    'blur .number_val': (e,t)->
        # console.log Template.parentData()
        delta = Docs.findOne type:'delta'
        target_doc = Docs.findOne _id:delta.detail_id

        val = parseInt e.currentTarget.value
        Docs.update target_doc._id,
            $set:
                "#{t.data.key}": val

Template.date_edit.events
    'blur .date_val': (e,t)->
        # console.log Template.parentData()
        delta = Docs.findOne type:'delta'
        target_doc = Docs.findOne _id:delta.detail_id

        val = e.currentTarget.value
        Docs.update target_doc._id,
            $set:
                "#{t.data.key}": val

Template.textarea_edit.events
    'blur .textarea_val': (e,t)->
        # console.log Template.parentData()
        delta = Docs.findOne type:'delta'
        target_doc = Docs.findOne _id:delta.detail_id

        val = e.currentTarget.value
        Docs.update target_doc._id,
            $set: "#{t.data.key}": val


Template.array.onCreated ->
    @editing = new ReactiveVar false

Template.array.helpers
    value: ->
        parent = Template.parentData()
        parent["#{@key}"]


Template.array.events
    'click .edit': (e,t)-> t.editing.set !t.editing.get()

    'keyup .add_array_element': (e,t)->
        if e.which is 13
            delta = Docs.findOne type:'delta'
            target_doc = Docs.findOne _id:delta.detail_id

            val = e.currentTarget.value
            Docs.update target_doc._id,
                $addToSet:
                    "#{t.data.key}": val
            t.$('.add_array_element').val('')

    'click .pull_element': (e,t)->
        delta = Docs.findOne type:'delta'
        target_doc = Docs.findOne _id:delta.detail_id
        field_doc = Template.currentData()

        Docs.update target_doc._id,
            $pull:
                "#{field_doc.key}": @valueOf()





Template.field_edit.helpers
    can_edit: -> @editable

    edit_template: ->
        if @primative
            "#{@primative}_edit"
        else
            "string_edit"

Template.boolean_edit.helpers
    bool_switch_class: ->
        delta = Docs.findOne type:'delta'
        target_doc = Docs.findOne _id:delta.detail_id
        bool_value = target_doc?["#{@key}"]
        if bool_value and bool_value is true then 'teal' else 'basic'

Template.string_edit.helpers
    value: ->
        delta = Docs.findOne type:'delta'
        editing_doc = Docs.findOne _id:delta.detail_id
        # console.log 'target doc', editing_doc
        value = editing_doc?["#{@key}"]



Template.date_edit.helpers
    value: ->
        delta = Docs.findOne type:'delta'
        editing_doc = Docs.findOne _id:delta.detail_id
        # console.log 'target doc', editing_doc
        value = editing_doc?["#{@key}"]

Template.field_view.helpers
    value: ->
        delta = Docs.findOne type:'delta'
        editing_doc = Docs.findOne _id:delta.detail_id
        # console.log 'target doc', editing_doc
        value = editing_doc?["#{@key}"]



Template.number_edit.helpers
    value: ->
        delta = Docs.findOne type:'delta'
        editing_doc = Docs.findOne _id:delta.detail_id
        # console.log 'target doc', editing_doc
        value = editing_doc?["#{@key}"]

Template.textarea_edit.helpers
    value: ->
        delta = Docs.findOne type:'delta'
        editing_doc = Docs.findOne _id:delta.detail_id
        # console.log 'target doc', editing_doc
        value = editing_doc?["#{@key}"]









Template.multiref_edit.onCreated ->
    @autorun => Meteor.subscribe 'type', @data.ref_schema
Template.ref_edit.onCreated ->
    @autorun => Meteor.subscribe 'type', @data.ref_schema

Template.multiref_edit.helpers
    choices: ->
        Docs.find {type:@ref_schema},
            {sort:title:1}

    value: ->
        delta = Docs.findOne type:'delta'
        target_doc = Docs.findOne _id:delta.detail_id
        target_doc["#{@key}"]

    element_class: ->
        delta = Docs.findOne type:'delta'
        target_doc = Docs.findOne _id:delta.detail_id
        parent = Template.parentData()

        value =
            if @key then @key
            else if @slug then @slug
            else if @username then @username
        if parent and target_doc and value
            if target_doc["#{parent.key}"]
                if value in target_doc["#{parent.key}"] then 'teal' else 'basic'


Template.multiref_edit.events
    'click .toggle_element': (e,t)->
        delta = Docs.findOne type:'delta'
        target_doc = Docs.findOne _id:delta.detail_id
        editing_field = Template.currentData().key
        value =
            if @key then @key
            else if @slug then @slug
            else if @username then @username
        if target_doc and value
            if target_doc["#{editing_field}"]
                if value in target_doc["#{editing_field}"]
                    Docs.update target_doc._id,
                        $pull:"#{editing_field}": value
                else
                    Docs.update target_doc._id,
                        $addToSet:"#{editing_field}": value
            else
                Docs.update target_doc._id,
                    $addToSet:"#{editing_field}": value




Template.ref_edit.events
    'click .choose_element': (e,t)->
        delta = Docs.findOne type:'delta'
        target_doc = Docs.findOne _id:delta.detail_id
        editing_field = Template.currentData().key
        value =
            if @key then @key
            else if @slug then @slug
            else if @username then @username

        Docs.update target_doc._id,
            $set:"#{editing_field}": value

Template.ref_edit.helpers
    choices: ->
        Docs.find
            type:@ref_schema
    element_class: ->
        delta = Docs.findOne type:'delta'
        target_doc = Docs.findOne _id:delta.detail_id
        parent = Template.parentData()

        value =
            if @key then @key
            else if @slug then @slug
            else if @username then @username
        if target_doc?["#{parent.key}"] is value then 'teal' else 'basic'






Template.header.onCreated ->
    @editing = new ReactiveVar false
Template.textarea.onCreated ->
    @editing = new ReactiveVar false

Template.header.events
    'click .edit': (e,t)-> t.editing.set !t.editing.get()

    'blur .string_val': (e,t)->
        text_value = e.currentTarget.value
        # console.log @filter_id
        Docs.update @_id,
            { $set: title: text_value }

Template.textarea.events
    'click .edit': (e,t)-> t.editing.set !t.editing.get()

    'blur .text_val': (e,t)->
        text_value = e.currentTarget.value

        Docs.update @_id,
            { $set: text: text_value }



Template.edit_field_number.helpers
    field_value: ->
        field = Template.parentData()
        field["#{@key}"]


Template.edit_field_number.events
    'change .number_val': (e,t)->
        number_value = parseInt e.currentTarget.value
        # console.log @filter_id
        Docs.update @filter_id,
            { $set: "#{@key}": number_value }

Template.edit_field_text.helpers
    field_value: ->
        field = Template.parentData()
        field["#{@key}"]


Template.edit_field_text.events
    'change .text_val': (e,t)->
        text_value = e.currentTarget.value
        # console.log @filter_id
        Docs.update @filter_id,
            { $set: "#{@key}": text_value }






