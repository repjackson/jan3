# import { truncatehtml } from 'truncate-html'
# truncate = require('truncate-html')

Template.edit_image_field.events
    "change input[type='file']": (e) ->
        doc_id = FlowRouter.getQueryParam('doc_id')
        files = e.currentTarget.files

        Cloudinary.upload files[0],
            # folder:"secret" # optional parameters described in http://cloudinary.com/documentation/upload_images#remote_upload
            # type:"private" # optional: makes the image accessible only via a signed url. The signed url is available publicly for 1 hour.
            (err,res) -> #optional callback, you can catch with the Cloudinary collection as well
                # console.dir res
                if err
                    console.error 'Error uploading', err
                else
                    Docs.update doc_id, 
                        { $set: image_id: res.public_id }
                return

    'keydown #input_image_id': (e,t)->
        if e.which is 13
            doc_id = FlowRouter.getQueryParam('doc_id')
            image_id = $('#input_image_id').val().toLowerCase().trim()
            if image_id.length > 0
                Docs.update doc_id,
                    $set: image_id: image_id
                $('#input_image_id').val('')



    'click #remove_photo': ->
        if confirm 'Remove photo?'
            Meteor.call "c.delete_by_public_id", @image_id, (err,res) ->
                if not err
                    # Do Stuff with res
                    Docs.update FlowRouter.getQueryParam('doc_id'), 
                        $unset: image_id: 1
                else
                    throw new Meteor.Error "it failed"

    # 		Cloudinary.delete "37hr", (err,res) ->
    # 		    if err 
    # 		    else
    #                 # Docs.update FlowRouter.getQueryParam('doc_id'), 
    #                 #     $unset: image_id: 1

    # Template.edit_image.helpers



Template.edit_number_field.events
    'change #number_field': (e,t)->
        page = Docs.findOne
            type:'page'
            slug:FlowRouter.getParam('page_slug')
        number_value = parseInt e.currentTarget.value
        Docs.update page._id,
            { $set: "#{@key}": number_value }
            
        
Template.block_edit_number.events
    'change #number_field': (e,t)->
        child_doc = Template.parentData(0)
        field_object = Template.parentData(3)
        field_key = Template.parentData(3).key
        number_value = parseInt e.currentTarget.value
        Docs.update child_doc._id,
            { $set: "#{field_object.key}": number_value }
          
Template.block_edit_text_field.events
    'blur .block_text_field': (e,t)->
        text_value = e.currentTarget.value
        child_doc = Template.parentData(0)
        field_object = Template.parentData(3)
        field_key = Template.parentData(3).key
        Docs.update child_doc._id,
            { $set: "#{field_key}": text_value }
          
          
Template.block_boolean_toggle.events
    'click .toggle_field_boolean': (e,t)->
        child_doc = Template.parentData(0)
        field_key = Template.parentData(3).key
        field_object = Template.parentData(3)
        negative_value = !child_doc["#{field_key}"]
        Docs.update child_doc._id,
            { $set: "#{field_key}": negative_value }
          
          
          
          
Template.block_list_dropdown.events
    'click .select_dropdown_item': (e,t)->
        field_object = Template.parentData(3)
        child_doc = Template.parentData(0)
        field_key = Template.parentData(3).key
        Docs.update child_doc._id,
            { $set: "#{field_key}": @slug }
          
          
Template.block_list_dropdown.onCreated ->
    @autorun => Meteor.subscribe 'type', 'ticket_type'
Template.block_list_dropdown.onRendered ->
    Meteor.setTimeout ->
        $('.ui.dropdown').dropdown()
    ,500


Template.block_list_dropdown.helpers
    ticket_types: ->
        Docs.find type:'ticket_type'
          
          
Template.edit_textarea.events
    'blur .textarea': (e,t)->
        textarea_value = $(e.currentTarget).closest('.textarea').val()
        update_textarea = ->
            doc_id = FlowRouter.getQueryParam('doc_id')
            Docs.update doc_id,
                { $set: "#{t.data.key}": textarea_value }
        debounced = _.debounce(update_textarea, 500)
        debounced()

Template.edit_textarea.helpers
    'key_value': () -> 
        doc_field = Template.parentData(0)
        if FlowRouter.getParam('jpid')
            current_doc = Docs.findOne "ev.ID":FlowRouter.getParam('jpid')
        if FlowRouter.getQueryParam('doc_id')
            current_doc = Docs.findOne FlowRouter.getParam('jpid')
        if current_doc
            if doc_field.key
                current_doc["#{doc_field.key}"]
    



Template.edit_timerange_field.onRendered ->
    Meteor.setTimeout ->
        $('#time_start').calendar(
            type: 'datetime'
            today:true
            firstDayOfWeek: 0
            constantHeight: true
            endCalendar: $('#time_end')
        )
        $('#time_end').calendar(
            type: 'datetime'
            today:true
            firstDayOfWeek: 0
            constantHeight: true
            startCalendar: $('#time_start')
        )
    , 500

Template.edit_timerange_field.events
    'blur #time_start': (e,t)->
        value = $('#time_start').calendar('get date')
        Docs.update FlowRouter.getQueryParam('doc_id'),
            {$set: time_start: value}
    'blur #time_end': (e,t)->
        value = $('#time_end').calendar('get date')
        Docs.update FlowRouter.getQueryParam('doc_id'),
            {$set: time_end: value}


Template.edit_datetime_field.onRendered ->
    Meteor.setTimeout ->
        $('#semcal').calendar(
            type: 'datetime'
            today:true
            inline:true
            firstDayOfWeek: 0
            constantHeight: true
        )
    , 500



Template.edit_datetime_field.events
    'blur #datetime_field': (e,t)->
        datetime_value = e.currentTarget.value
        value = $('#datetime_field').calendar('get date')
        Docs.update FlowRouter.getQueryParam('doc_id'),
            { $set: "#{@key}": datetime_value } 


Template.edit_date_field.events
    'blur #date_field': (e,t)->
        date_value = e.currentTarget.value
        Docs.update FlowRouter.getQueryParam('doc_id'),
            { $set: "#{@key}": date_value } 


Template.edit_text_field.events
    'change #text_field': (e,t)->
        text_value = e.currentTarget.value
        Docs.update FlowRouter.getQueryParam('doc_id'),
            { $set: "#{@key}": text_value }




Template.edit_text.events
    'change .text_val': (e,t)->
        text_value = e.currentTarget.value
        display_field = Template.parentData(5)
        Docs.update display_field._id,
            { $set: "#{@slug}": text_value }

Template.edit_text.helpers
    local_value: ->
        display_field = Template.parentData(5)
        display_field["#{@slug}"]


Template.edit_int.events
    'change .int_val': (e,t)->
        int_value = parseInt e.currentTarget.value
        display_field = Template.parentData(5)
        Docs.update display_field._id,
            { $set: "#{@slug}": int_value }

Template.edit_int.helpers
    local_value: ->
        display_field = Template.parentData(5)
        display_field["#{@slug}"]


Template.edit_boolean.events
    'click #turn_on': ->
        display_field = Template.parentData(5)
        Docs.update display_field._id,
            { $set: "#{@slug}": true }

    'click #turn_off': ->
        display_field = Template.parentData(5)
        Docs.update display_field._id,
            { $set: "#{@slug}": false }

Template.edit_boolean.helpers
    is_true: -> 
        display_field = Template.parentData(5)
        display_field["#{@slug}"]










Template.edit_page_text_field.events
    'change .text_field': (e,t)->
        text_value = e.currentTarget.value
        page = Docs.findOne slug:FlowRouter.getParam('page_slug')
        Docs.update page._id,
            { $set: "#{@key}": text_value }

Template.edit_profile_text_field.events
    'change #text_field': (e,t)->
        text_value = e.currentTarget.value
        Meteor.users.update FlowRouter.getParam('user_id'),
            { $set: "profile.#{@key}": text_value }

Template.edit_user_text_field.events
    'change #text_field': (e,t)->
        text_value = e.currentTarget.value
        Meteor.users.update FlowRouter.getParam('user_id'),
            { $set: "#{@key}": text_value }



# Template.edit_html.events
#     'blur .froala-container': (e,t)->
#         html = t.$('div.froala-reactive-meteorized-override').froalaEditor('html.get', true)
        
#         doc_id = FlowRouter.getQueryParam('doc_id')
#         # short = truncate(html, 5, { byWords: true })
#         Docs.update doc_id,
#             $set: 
#                 html: html


# Template.edit_html_field.events
#     'blur .froala-container': (e,t)->
#         html = t.$('div.froala-reactive-meteorized-override').froalaEditor('html.get', true)
        
#         # doc_id = @doc_id

#         Docs.update @_id,
#             $set: ticket_details: html


# Template.edit_html_field.helpers
#     getFEContext: ->
#         @current_doc = Docs.findOne FlowRouter.getQueryParam('doc_id')
#         self = @
#         {
#             _value: self.current_doc.ticket_details
#             _keepMarkers: true
#             _className: 'froala-reactive-meteorized-override'
#             toolbarInline: false
#             initOnClick: false
#             # imageInsertButtons: ['imageBack', '|', 'imageByURL']
#             tabSpaces: false
#             height: 300
#         }

# Template.edit_html.helpers
#     getFEContext: ->
#         @current_doc = Docs.findOne FlowRouter.getQueryParam('doc_id')
#         self = @
#         {
#             _value: self.current_doc.html
#             _keepMarkers: true
#             _className: 'froala-reactive-meteorized-override'
#             toolbarInline: false
#             initOnClick: false
#             # imageInsertButtons: ['imageBack', '|', 'imageByURL']
#             tabSpaces: false
#             height: 300
#         }


Template.edit_array_field.events
    # "autocompleteselect input": (event, template, doc) ->
    #     Docs.update @doc_id,
    #         $addToSet: tags: doc.name
    #     $('.new_entry').val('')
   
    'keyup .new_entry': (e,t)->
        e.preventDefault()
        # val = $('.new_entry').val().toLowerCase().trim()                    
        val = $(e.currentTarget).closest('.new_entry').val().toLowerCase().trim()   

        switch e.which
            when 13 #enter
                unless val.length is 0
                    Docs.update FlowRouter.getQueryParam('doc_id'),
                        $addToSet: "#{@key}": val
                    # $('.new_entry').val ''
                    $(e.currentTarget).closest('.new_entry').val('')

            # when 8
            #     if val.length is 0
            #         result = Docs.findOne(@doc_id).tags.slice -1
            #         $('.new_entry').val result[0]
            #         Docs.update @doc_id,
            #             $pop: tags: 1


    'click .doc_tag': (e,t)->
        tag = @valueOf()
        Docs.update FlowRouter.getQueryParam('doc_id'),
            $pull: "#{Template.parentData(0).key}": tag
        t.$('.new_entry').val(tag)
        
Template.edit_array_field.helpers
    # editing_mode: -> 
    #     if Session.equals 'editing', true then true else false
    # theme_select_settings: -> {
    #     position: 'top'
    #     limit: 10
    #     rules: [
    #         {
    #             collection: Tags
    #             field: 'name'
    #             matchAll: false
    #             template: Template.tag_result
    #         }
    #         ]
    # }

Template.cell_text_edit.onCreated ->
    @editing_mode = new ReactiveVar false

Template.cell_text_edit.helpers
    editing_cell: -> Template.instance().editing_mode.get()

    cell_value: ->
        cell_object = Template.parentData(3)
        @["#{cell_object.key}"]

Template.cell_text_edit.events
    'click .edit_field': (e,t)-> t.editing_mode.set true
    'click .save_field': (e,t)-> t.editing_mode.set false

    'change .cell_val': (e,t)->
        cell_object = Template.parentData(3)
        
        text_value = e.currentTarget.value
        Docs.update @_id,
            { $set: "#{cell_object.key}": text_value }






Template.user_cell_text_edit.onCreated ->
    @editing_mode = new ReactiveVar false

Template.user_cell_text_edit.helpers
    editing_cell: -> Template.instance().editing_mode.get()

    cell_value: ->
        cell_object = Template.parentData(3)
        @["#{cell_object.key}"]

Template.user_cell_text_edit.events
    'click .edit_field': (e,t)-> t.editing_mode.set true
    'click .save_field': (e,t)-> t.editing_mode.set false

    'change .cell_val': (e,t)->
        cell_object = Template.parentData(3)
        
        text_value = e.currentTarget.value
        Docs.update @_id,
            { $set: "#{cell_object.key}": text_value }
