Template.edit_number_field.events
    'change #number_field': (e,t)->
        number_value = parseInt e.currentTarget.value
        Docs.update FlowRouter.getParam('doc_id'),
            $set: "#{@key}": number_value
            
Template.edit_textarea.events
    'blur #textarea': (e,t)->
        doc_id = FlowRouter.getParam('doc_id')
        textarea_value = $('#textarea').val()
        Docs.update doc_id,
            $set: 
                "#{@key}": textarea_value


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


Template.toggle_follow.helpers
    is_following: -> if Meteor.user()?.following_ids then @_id in Meteor.user().following_ids
        
Template.toggle_follow.events
    'click #follow': (e,t)-> 
        Meteor.users.update Meteor.userId(), $addToSet: following_ids: @_id

        # Meteor.call 'add_notification', @_id, 'friended', Meteor.userId()

    'click #unfollow': (e,t)-> 
        Meteor.users.update Meteor.userId(), $pull: following_ids: @_id

        # Meteor.call 'add_notification', @_id, 'unfriended', Meteor.userId()

Template.vote_button.helpers
    vote_up_button_class: ->
        if not Meteor.userId() then 'disabled'
        else if @upvoters and Meteor.userId() in @upvoters then 'green'
        else 'outline'

    vote_down_button_class: ->
        if not Meteor.userId() then 'disabled'
        else if @downvoters and Meteor.userId() in @downvoters then 'red'
        else 'outline'

Template.vote_button.events
    'click .vote_up': (e,t)-> 
        if Meteor.userId()
            Meteor.call 'vote_up', @_id
        else FlowRouter.go '/sign-in'

    'click .vote_down': -> 
        if Meteor.userId() then Meteor.call 'vote_down', @_id
        else FlowRouter.go '/sign-in'
            
        
        
Template.toggle_key.helpers
    toggle_key_button_class: -> 
        current_doc = Docs.findOne FlowRouter.getParam('doc_id')
        # console.log current_doc["#{@key}"]
        # console.log @key
        # console.log Template.parentData()
        # console.log Template.parentData()["#{@key}"]
        if @value
            if current_doc["#{@key}"] is @value then 'grey' else ''
        else if current_doc["#{@key}"] is true then 'grey' else ''


Template.toggle_key.events
    'click #toggle_key': ->
        # console.log @
        if @value
            Docs.update FlowRouter.getParam('doc_id'), 
                $set: "#{@key}": "#{@value}"
        else if Template.parentData()["#{@key}"] is true
            Docs.update FlowRouter.getParam('doc_id'), 
                $set: "#{@key}": false
        else
            Docs.update FlowRouter.getParam('doc_id'), 
                $set: "#{@key}": true



Template.edit_html_field.events
    'blur .froala-container': (e,t)->
        html = t.$('div.froala-reactive-meteorized-override').froalaEditor('html.get', true)
        
        doc_id = FlowRouter.getParam('doc_id')

        Docs.update doc_id,
            $set: 
                description: html




Template.edit_html_field.helpers
    getFEContext: ->
        @current_doc = Docs.findOne FlowRouter.getParam('doc_id')
        self = @
        {
            _value: self.current_doc.description
            _keepMarkers: true
            _className: 'froala-reactive-meteorized-override'
            toolbarInline: false
            initOnClick: false
            # imageInsertButtons: ['imageBack', '|', 'imageByURL']
            tabSpaces: false
            height: 300
            '_onsave.before': (e, editor) ->
                # Get edited HTML from Froala-Editor
                newHTML = editor.html.get(true)
                # Do something to update the edited value provided by the Froala-Editor plugin, if it has changed:
                if !_.isEqual(newHTML, self.current_doc.description)
                    # console.log 'onSave HTML is :' + newHTML
                    Docs.update { _id: self.current_doc._id }, $set: description: newHTML
                false
                # Stop Froala Editor from POSTing to the Save URL
        }


Template.toggle_boolean.events
    'click #make_featured': ->
        Docs.update FlowRouter.getParam('doc_id'),
            $set: featured: true

    'click #make_unfeatured': ->
        Docs.update FlowRouter.getParam('doc_id'),
            $set: featured: false
