FlowRouter.route '/mail', 
    name:'mail'
    action: -> BlazeLayout.render 'layout', main:'mail'
FlowRouter.route '/unread', 
    name:'unread'
    action: -> BlazeLayout.render 'layout', main:'unread'

Template.unread.onCreated ->
    @autorun -> Meteor.subscribe('unread')
Template.mail.onCreated ->
    @autorun -> Meteor.subscribe('inbox_count')
    @autorun -> Meteor.subscribe('unread_count')
    @view_published = new ReactiveVar(true)
    @autorun -> Meteor.subscribe 'type','message', Session.get('query'), parseInt(Session.get('page_size')),Session.get('sort_key'), Session.get('sort_direction'), parseInt(Session.get('skip'))
    @autorun => Meteor.subscribe 'facet', 
        selected_tags.array()
        selected_author_ids.array()
        selected_location_tags.array()
        selected_timestamp_tags.array()
        type='message'
        author_id=null


Template.message_segment.helpers
    message_segment_class: ->
        if @read_by and Meteor.userId() and Meteor.userId() in @read_by then 'secondary' else ''

Template.unread.helpers
    unread_messages: ->
        Docs.find({
            type:'message'
            read_by: $nin: [Meteor.userId()]
            })


Template.mail.helpers
    inbox_count: ->
        Stats.findOne
            doc_type:'message'
            stat_type:'inbox'

    conversations: -> 
        if Template.instance().view_published.get() is true
            Docs.find {
                type: 'conversation'
                published: true
            }, sort: timestamp: -1
        else
            Docs.find {
                participant_ids: $in: [Meteor.userId()]
                type: 'conversation'
                published: -1
            }, sort: timestamp: -1
        
        
    message_docs: -> Docs.find type:'message'    
        
    message_table_fields: -> [
            {   
                key:'to_username'
                label:'To'
                sortable:false
            }
            {
                key:'from_username'
                label:'From'
                sortable:false
            }
            {
                key:'long_timestamp'
                label:'When'
                sortable:false
                
            }
            {
                key:'text'
                label:'Text'
                sortable:false
            }
        ]

        
        
    selected_conversation: ->
        Docs.findOne Session.get 'current_conversation_id'
    unread_message_count: ->
        count = 0
        my_conversations = Docs.find(
            type: 'conversation'
            participant_ids: $in: [Meteor.userId()]
        ).fetch()
        
        for conversation in my_conversations
            unread_count = Docs.find(
                type: 'message'
                group_id: conversation._id
                read_by: $nin: [Meteor.userId()]
            ).count()
            count += unread_count
        count
        
        
    viewing_published: -> Template.instance().view_published.get() is true
    viewing_private: -> Template.instance().view_published.get() is false  



Template.mail.events
    'click #create_conversation': ->
        Meteor.call 'create_conversation', (err,id)->
            FlowRouter.go "/edit/#{id}"


# 'click #create_conversation': ->
#     id = Docs.insert 
#         type: 'conversation'
#         participant_ids: [Meteor.userId()]
#     FlowRouter.go "/conversation/#{id}"


    'click #view_private_conversations': (e,t)-> 
        t.view_published.set(false)
        # console.log t.view_published.get()
        
    'click #view_published_conversations': (e,t)-> 
        t.view_published.set(true)    

        # console.log t.view_published.get()



Template.conversation_list.onCreated ->
    @autorun => Meteor.subscribe 'my_conversations'
Template.conversation_list_item.onCreated ->
    @autorun => Meteor.subscribe 'group_docs', @data._id
    @autorun => Meteor.subscribe 'people_list', @data._id

    
Template.conversation_list.helpers
    conversation_list_items: ->
        Docs.find
            type: 'conversation'
            participant_ids: $in: [Meteor.userId()]        
    
    message_segment_class: -> if Meteor.userId() in @read_by then 'basic' else ''
    read: -> Meteor.userId() in @read_by

Template.conversation_list_item.helpers
    participants: ->
        participant_array = []
        for participant in @participant_ids
            unless Meteor.userId() is participant
                participant_object = Meteor.users.findOne participant
                participant_array.push participant_object
        return participant_array

    last_message: ->
        Docs.findOne {
            type: 'message'
            group_id: @_id
        }, 
            sort: timestamp: -1
            limit: 1

    conversation_list_item_class: -> if Session.equals 'current_conversation_id', @_id then 'blue inverted tertiary' else ''
Template.conversation_list.events
    'click .conversation_list_item': (e,t)->
        Session.set 'current_conversation_id', @_id
        console.log Session.get 'current_conversation_id'
    
    'click .mark_unread': (e,t)-> 
        Meteor.call 'mark_unread', @_id, ->
            $(e.currentTarget).closest('.message_segment').transition('flash')

Template.conversation_message.onRendered ->
    Meteor.setTimeout ->
        $('.ui.accordion').accordion()
    , 500
    
    
Template.conversation_message.helpers
    message_segment_class: -> if Meteor.userId() in @read_by then 'basic' else ''
    read: -> Meteor.userId() in @read_by

    readers: ->
        readers = []
        for reader_id in @read_by
            readers.push Meteor.users.findOne reader_id
        readers


Template.conversation_message.events
    'click .mark_read, click .text': (e,t)->
        unless Meteor.userId() in @read_by
            Meteor.call 'mark_read', @_id, ->
                $(e.currentTarget).closest('.message_segment').transition('flash')
    
    'click .mark_unread': (e,t)-> 
        Meteor.call 'mark_unread', @_id, ->
            $(e.currentTarget).closest('.message_segment').transition('flash')


Template.conversation_view.helpers
    participants: ->
        participants = []
        for participant_id in @participant_ids
            participants.push Meteor.users.findOne participant_id
        participants

    conversation_messages: -> 
        Docs.find {
            type: 'message'
            group_id: @_id },
            sort: timestamp: 1

    message_count: -> 
        Docs.find({
            type: 'message'
            group_id: @_id }).count()

    unread_message_count: -> 
        Docs.find({
            type: 'message'
            group_id: @_id 
            read_by: $nin: [Meteor.userId()]}).count()


    subscribed: -> @_id in Docs.findOne(FlowRouter.getParam('doc_id')).subscribers


Template.conversation_messages_pane.onCreated ->
    # @autorun => Meteor.subscribe 'doc', @data._id
    @autorun => Meteor.subscribe 'group_docs', @data._id
    @autorun => Meteor.subscribe 'people_list', @data._id

Template.conversation_messages_pane.helpers
    conversation_messages: -> 
        Docs.find {
            type: 'message'
            group_id: @_id },
            sort: timestamp: -1

    conversation_tag_class:-> if @valueOf() in selected_conversation_tags.array() then 'teal' else ''
    conversation: -> Docs.findOne @_id

    in_conversation: -> if Meteor.userId() in @participant_ids then true else false

    
    participants: ->
        participant_array = []
        for participant in @participant_ids
            participant_object = Meteor.users.findOne participant
            participant_array.push participant_object
        return participant_array


Template.conversation_messages_pane.events
    'click .join_conversation': (e,t)-> Meteor.call 'join_conversation', @_id, ->
    'click .leave_conversation': (e,t)-> Meteor.call 'leave_conversation', @_id, ->


    'keydown .add_message': (e,t)->
        e.preventDefault
        if e.which is 13
            group_id = @_id
            # console.log group_id
            body = t.find('.add_message').value.trim()
            if body.length > 0
                # console.log body
                Meteor.call 'add_message', body, group_id, (err,res)=>
                    if err then console.error err
                    else
                        console.log res
                t.find('.add_message').value = ''

    'click .close_conversation': ->
        self = @
        swal {
            title: "Close Conversation?"
            text: 'This will also delete the messages'
            type: 'warning'
            showCancelButton: true
            animation: false
            confirmButtonColor: '#DD6B55'
            confirmButtonText: 'Close'
            closeOnConfirm: true
        }, ->
            Meteor.call 'close_conversation', self._id, ->
                FlowRouter.go '/conversations'
            # console.log self
            Session.set 'editing', false

            # swal "Submission Removed", "",'success'
            return
    
Template.conversation_edit.events
    'click #delete_doc': ->
        if confirm 'Delete this Conversation?'
            Docs.remove @_id
            FlowRouter.go '/conversation'
