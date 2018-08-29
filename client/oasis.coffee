FlowRouter.route '/feed', 
    name:'oasis'
    action: ->
        BlazeLayout.render 'layout', 
            main: 'oasis'

Template.oasis.onCreated ->
    Meteor.subscribe 'count', 'event'
    Meteor.subscribe 'type', 'event_type'
    Session.setDefault 'view_mode', 'table'
    @autorun => Meteor.subscribe 'oasis', 
        selected_tags.array()
        selected_author_ids.array()
        selected_location_tags.array()
        selected_timestamp_tags.array()
        type='event'
        author_id=null
        selected_doc_types.array()

Template.oasis.onRendered ->
    @autorun =>
        if @subscriptionsReady()
            Meteor.setTimeout ->
                $('.ui.accordion').accordion()
            , 500

    
Template.oasis.events
    'click #set_table_view': ->
        Session.set 'view_mode', 'table'
    'click #set_list_view': ->
        Session.set 'view_mode', 'list'
    
Template.oasis.helpers
    viewing_table: -> Session.equals 'view_mode', 'table'
    viewing_list: -> Session.equals 'view_mode', 'list'

    table_mode_button_class: -> if Session.equals('view_mode', 'table') then 'blue' else ''
    list_mode_button_class: -> if Session.equals('view_mode', 'list') then 'blue' else ''


    event_types: -> Docs.find type:'event_type'


    oasis_table_fields: -> [
            {   
                key:'event_type'
                label:'type'
                sortable:true
            }
            {
                key:'parent_id'
                label:'parent id'
                sortable:false
            }
            {
                key:'long_timestamp'
                label:'When'
                sortable:true
                
            }
            {
                key:'text'
                label:'Text'
                sortable:false
            }
            {
                key:'action'
                label:'action'
                sortable:false
            }
        ]


    # feed_events: -> Docs.find {type:'event'}, sort:timestamp:-1
    # settings: ->
    #     collection: 'events'
    #     rowsPerPage: 10
    #     showFilter: true
    #     showRowCount: true
    #     # showColumnToggles: true
    #     fields: [
    #         { key: 'author_id', label: 'Author', tmpl:Template.author_info }
    #         { key: 'text', label: 'Text' }
    #         { key: 'action', label: 'Action' }
    #         # { key: 'parent_id', label: 'Parent Link', tmpl:Template.parent_link }
    #         { key: 'timestamp', label: 'Logged', tmpl:Template.when_template }
    #         { key: 'timestamp_tags', label: 'Time Tags' }
    #         { key: '', label: 'Mark Read', tmpl:Template.mark_read_link }
    #         { key: '', label: 'View', tmpl:Template.view_button }
    #     ]


# Template.feed_event.onCreated ->
#     @autorun => Meteor.subscribe 'parent_doc', @data._id
# Template.feed_event.events
#     'click .remove_event': -> 
#         if confirm 'Delete Event?'
#             Docs.remove @_id


Template.view_event_stat.onCreated ->
    @autorun =>  Meteor.subscribe 'event_type_count', @data.event_type
Template.view_event_stat.helpers
    stat_value: ->
        inputs = Template.currentData(0)
        doc = 
            Stats.findOne 
                doc_type:'event'
                event_type:inputs.event_type
        if doc
            doc.amount
