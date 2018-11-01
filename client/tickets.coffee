FlowRouter.route '/tickets',
    name:'tickets'
    action: ->
        BlazeLayout.render 'layout',
            main: 'tickets'

FlowRouter.route '/add',
    name:'submit_ticket'
    action: ->
        BlazeLayout.render 'layout',
            main: 'submit_ticket'



Template.tickets.onCreated ->
    @autorun -> Meteor.subscribe 'session'
    @autorun -> Meteor.subscribe 'ticket_schema'
    @autorun -> Meteor.subscribe 'ticket_fields'
    @autorun -> Meteor.subscribe 'fe'
    @editing_id = new ReactiveVar null
    @viewing_id = new ReactiveVar null
    Session.setDefault 'viewing_task_id',null
    Session.setDefault 'editing',false


Template.ticket_card.onCreated ->
    @autorun => Meteor.subscribe 'single_doc', @data


Template.ticket_card.helpers
    local_doc: ->
        if @data
            Docs.findOne @data.valueOf()
        else
            Docs.findOne @valueOf()

    is_viewing: -> Session.equals('viewing_task_id',@_id)

    ticket_card_class: ->
        if Session.equals('viewing_task_id',@_id) then 'raised blue' else 'secondary'


Template.tickets.helpers
    session_doc: -> Docs.findOne type:'session'
    editing: -> Session.get 'editing'
    viewing_task_id: -> Session.get 'viewing_task_id'
    viewing_task: ->
        Docs.findOne Session.get('viewing_task_id')


    faceted_fields: ->
        fields =
            Docs.find({
                type:'field'
                schema_slugs:$in:['ticket']
                faceted: true
            }, {sort:{rank:1}}).fetch()

    fields: ->
        fields = Docs.find({
            type:'field'
            schema_slugs: $in: ['ticket']
        }, {sort:{rank:1}}).fetch()
        # console.log fields
        fields

    task_docs: ->
        query = {type:'task'}
        if Session.get 'view_incomplete'
            query.complete = $ne:true
        else if Session.get 'view_complete'
            query.complete = true
        if Session.get 'view_by_me'
            query.assigned_by = Meteor.user().username
        if Session.get 'view_to_me'
            query.assigned_to = Meteor.user().username
        Docs.find query


Template.tickets.onRendered ->
    # Meteor.setTimeout ->
    #     $('.ui.accordion').accordion()
    # , 400


Template.ticket_card.events
    'click .ticket_card': ->
        if Session.equals 'viewing_task_id', @_id
            Session.set 'viewing_task_id', null
        else
            Session.set 'viewing_task_id', @_id

Template.tickets.events
    'click .create_session': (e,t)->
        new_session_id =
            Docs.insert
                type:'session'
                current_page:1
                page_size:10
                skip_amount:0
                view_full:true
                type_filter:['ticket']
        Session.set 'session_id', new_session_id
        Meteor.call 'fe'

    'click .show_session': ->
        session = Docs.findOne type:'session'
        console.log session

    'click .delete_session': ->
        if confirm 'Clear Session?'
            session = Docs.findOne type:'session'
            Docs.remove session._id

    'click .run_fe': ->
        session = Docs.findOne type:'session'
        Meteor.call 'fe'


    'click #new_task': (e,t)->
        new_id = Docs.insert
            type:'task'
        Session.set('editing_task', true)
        Session.set('viewing_task_id',new_id)

    'click .toggle_incomplete': -> Session.set('view_incomplete', !Session.get('view_incomplete'))
    'click .toggle_complete': -> Session.set('view_complete', !Session.get('view_complete'))
    'click .toggle_to_me': -> Session.set('view_to_me', !Session.get('view_to_me'))
    'click .toggle_by_me': -> Session.set('view_by_me', !Session.get('view_by_me'))

    'click .mark_complete': ->
        Docs.update @_id,
            $set: complete: true

    'click .mark_incomplete': ->
        Docs.update @_id,
            $set: complete: false


    'click .delete_comment': ->
        if confirm 'delete comment?'
            Docs.remove @_id

    'click .close_pane': ->
        Session.set 'viewing_task_id', null



Template.facet.helpers
    values: ->
        session = Docs.findOne type:'session'
        session["#{@key}_return"]?[..20]

    set_facet_key_class: ->
        session = Docs.findOne type:'session'
        if session.query["#{@slug}"] is @value then 'blue' else ''

Template.select.helpers
    toggle_value_class: ->
        # console.log @
        session = Docs.findOne type:'session'
        filter = Template.parentData()
        filter_list = session["filter_#{filter.key}"]
        if filter_list and @name in filter_list then 'blue' else ''

Template.facet.events
    # 'click .set_facet_key': ->
    #     session = Docs.findOne type:'session'
    'click .recalc': ->
        session = Docs.findOne type:'session'
        Meteor.call 'fe'

Template.select.events
    'click .toggle_value': ->
        # console.log @
        filter = Template.parentData()
        session = Docs.findOne type:'session'
        filter_list = session["filter_#{filter.key}"]

        if filter_list and @name in filter_list
            Docs.update session._id,
                $set:
                    current_page:1
                $pull: "filter_#{filter.key}": @name
        else
            Docs.update session._id,
                $set:
                    current_page:1
                $addToSet:
                    "filter_#{filter.key}": @name
        Session.set 'is_calculating', true
        # console.log 'hi call'
        Meteor.call 'fe', (err,res)->
            if err then console.log err
            else if res
                # console.log 'return', res
                Session.set 'is_calculating', false
