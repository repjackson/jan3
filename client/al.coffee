Template.page_edit.events
    'click #add_block': (e,t)->
        # if @tags and typeof @tags is 'string'
        #     split_tags = @tags.split ','
        # else
        #     split_tags = @tags
        Docs.insert
            type:'block'
            horizontal_position:'center'
            title:'new block'
            published:false
            block_classes:'ui secondary segment'
            view_title:true
            parent_slug:FlowRouter.getParam('page_slug')
            fields: []
            context: 'direct'

Template.blocks.helpers
    blocks: ->
        if @horizontal_position is 'left'
            Docs.find {
                type:'block'
                parent_slug:FlowRouter.getParam('page_slug')
                horizontal_position:'left'
            }, sort:rank:1
        else if @horizontal_position is 'right'
            Docs.find {
                type:'block'
                parent_slug:FlowRouter.getParam('page_slug')
                horizontal_position:'right'
            }, sort:rank:1
        else
            Docs.find {
                type:'block'
                parent_slug:FlowRouter.getParam('page_slug')
                horizontal_position:$nin:['left','right']
            }, sort:rank:1

Template.block.onRendered ->
    Meteor.setTimeout ->
        $('.accordion').accordion();
    , 500
    Meteor.setTimeout ->
        $('.dropdown').dropdown()
    , 700

# Template.block.onRendered ->
#     stat = Stats.findOne()
#     if stat

Template.edit_block.onCreated ->
    @autorun -> Meteor.subscribe 'schema_doc_by_type', 'display_field'
    @autorun -> Meteor.subscribe 'type', 'schema'
    @autorun => Meteor.subscribe 'type', 'view'
    @autorun => Meteor.subscribe 'type', 'collection'

Template.block.onCreated ->
    @editing_block = new ReactiveVar false
    unless @data.custom_template
        @page_number = new ReactiveVar(1)
        @sort_key = new ReactiveVar('timestamp')
        @sort_direction = new ReactiveVar(-1)
        @number_of_pages = new ReactiveVar(1)
        @page_size = new ReactiveVar(10)
        @skip = new ReactiveVar(0)

        if @data.limit
            @limit = new ReactiveVar(parseInt(@data.limit))
            @page_size = new ReactiveVar(parseInt(@data.limit))
        else
            @page_size = new ReactiveVar(10)
            @limit = new ReactiveVar(10)
        match_object = {}
        if FlowRouter.getParam 'jpid'
            match_object.jpid = FlowRouter.getParam 'jpid'
        if FlowRouter.getQueryParam 'doc_id'
            match_object.doc_id = FlowRouter.getQueryParam 'doc_id'
        if @data.filter_status is "ACTIVE"
            match_object.active = true
        else
            match_object.active = false
        match_object.doc_type = @data.children_doc_type
        match_object.stat_type = @data.table_stat_type
        query_params = FlowRouter.current().queryParams

        @autorun -> Meteor.subscribe 'stat', match_object
        @autorun =>
            Meteor.subscribe 'block_children',
                @data._id,
                @data.filter_key,
                @data.filter_value,
                Session.get('query'),
                @page_size.get(),
                @sort_key.get(),
                @sort_direction.get(),
                @skip.get(),
                @data.filter_status,
                FlowRouter.getParam('jpid'),
                query_params
        @autorun => Meteor.subscribe 'schema_doc_by_type', @data.children_doc_type
        @autorun => Meteor.subscribe 'block_field_docs', @data._id


Template.block.helpers
    editing_block: -> Template.instance().editing_block.get() and Session.get('editing_mode')
    editing_button_class: -> if Template.instance().editing_block.get() is true then 'blue' else ''

    block_class: ->
        if @published
            @block_classes
        # else
            # @block_classes+" disabled"


    sort_descending: ->
        key = if @ev_subset then "ev.#{@key}" else @key
        temp = Template.instance()
        if temp.sort_direction.get() is 1 and temp.sort_key.get() is key
            return true
    sort_ascending: ->
        key = if @ev_subset then "ev.#{@key}" else @key
        temp = Template.instance()
        if temp.sort_direction.get() is -1 and temp.sort_key.get() is key
            return true

    comment_children: ->
        temp = Template.instance()
        Docs.find {
            type:'event'
            parent_id:FlowRouter.getQueryParam('doc_id')
            },{
            sort:"timestamp":-1
            }


    children: ->
        temp = Template.instance()
        if @children_collection is 'users'
            Meteor.users.find {_id:$ne:Meteor.userId()},{
                sort:"#{temp.sort_key.get()}":parseInt("#{temp.sort_direction.get()}")
                }
        else if @children_collection is 'stats'
            Stats.find {type:'stat_log'},{
                sort:"#{temp.sort_key.get()}":parseInt("#{temp.sort_direction.get()}")
                }
        else
            match = {}
            if @filter_value is "{source_key}"
                context_doc = Docs.findOne FlowRouter.getQueryParam 'doc_id'
                if context_doc
                    result = context_doc["#{@filter_source_key}"]
                    if @children_doc_type is 'event'
                        match["#{@filter_key}"] = result

            match.type = @children_doc_type
            # if @children_doc_type is 'event'
            if @filter_key is '_id'
                match._id = FlowRouter.getQueryParam 'doc_id'
            if @hard_limit
                Docs.find match,
                    {
                        sort:"#{temp.sort_key.get()}":parseInt("#{temp.sort_direction.get()}")
                        limit:parseInt(@hard_limit)
                        }
            else
                Docs.find match,
                    { sort:"#{temp.sort_key.get()}":parseInt("#{temp.sort_direction.get()}") }

    can_view_block: ->
        if @published
            true
        else
            if Meteor.user() and Meteor.user().roles and 'dev' in Meteor.user().roles and Session.get('editing_mode')
                true
            else
                false
    child_schema_field_value: ->
        child_doc = Template.parentData(1)
        if @ev_subset
            child_doc.ev["#{@key}"]
        else
            child_doc["#{@key}"]

    is_table: -> @view is 'table'
    is_list: -> @view is 'list'
    is_comments: -> @view is 'comments'
    is_grid: -> @view is 'grid'
    is_cards: -> @view is 'cards'
    is_sla_settings: -> @view is 'sla_settings'

    can_lower: -> @rank>1
    can_move_left: -> @horizontal_position is 'center' or 'right'
    can_move_right: -> @horizontal_position is 'center' or 'left'

    th_field_docs: ->
        # block = Template.currentData()
        block = Template.parentData(0)
        # count = Docs.find(
        #     type:'display_field'
        #     # block_id:@_id
        # ).count()
        Docs.find {
            type:'display_field'
            block_id: block._id
        }, sort:rank:1

    children_field_docs: ->
        block = Template.parentData(1)
        Docs.find {
            type:'display_field'
            block_id: block._id
        }, sort:rank:1


Template.block.events
    'click .move_left': ->
        if @horizontal_position is 'center'
            Docs.update @_id,
                $set:horizontal_position:'left'
        if @horizontal_position is 'right'
            Docs.update @_id,
                $set:horizontal_position:'center'
    'click .move_right': ->
        if @horizontal_position is 'center'
            Docs.update @_id,
                $set:horizontal_position:'right'
        if @horizontal_position is 'left'
            Docs.update @_id,
                $set:horizontal_position:'center'

    'click .raise_block':->
        Docs.update @_id,
            $inc:rank:1

    'click .lower_block':->
        Docs.update @_id,
            $inc:rank:-1

    'click .toggle_editing_block': (e,t)->
        t.editing_block.set(!t.editing_block.get())

    'click .add_block_child': (e,t)->
        if FlowRouter.getParam('jpid')
            new_id = Docs.insert
                type:@children_doc_type
                office_jpid:FlowRouter.getParam('jpid')
        else
            new_id = Docs.insert
                type:@children_doc_type
        # FlowRouter.go("/edit/#{_id}")


    'click .move_up': ->
        current = Template.currentData()
        current_index = current.fields.indexOf @
        next_index = current+1
        Meteor.call 'move', current._id, current.fields, current_index, next_index


    'click .move_down': ->
        current = Template.currentData()
        current_index = current.fields.indexOf @
        lower_index = current-1
        Meteor.call 'move', current._id, current.fields, current_index, lower_index

    'click .sort_by': (e,t)->
        key = if @ev_subset then "ev.#{@key}" else @key
        t.sort_key.set key
        if t.sort_direction.get() is -1
            t.sort_direction.set 1
        else
            t.sort_direction.set -1


Template.edit_block.onRendered ->
    Meteor.setTimeout ->
        $('.tabular.menu .tab_nav').tab()
    , 400


Template.edit_block.helpers
    schema_doc: ->
        Docs.findOne
            type:'schema'
            slug:@children_doc_type

    show_schema_field: ->
        parent = Template.parentData()
        schema_fields =
            Docs.findOne({
                type:'schema'
                slug:parent.children_doc_type
                block_id:parent._id
            }).fields
        block_fields = Docs.find(type:'display_field').fetch()
        selected_keys = _.pluck block_fields, 'key'
        if @slug in selected_keys then false else true


    schema_doc_fields: ->
        block_doc = Template.parentData(1)
        schema_doc = Docs.findOne
            type:'schema'
            slug: block_doc.children_doc_type
        if schema_doc
            schema_doc.fields

    values: ->
        schema_doc = Docs.findOne
            type:'schema'
            slug:@children_doc_type
        if schema_doc
            fields = schema_doc.fields
            values = []
            for field in fields
                values.push @ev["#{field.slug}"]
                # if field.ev_subset is true
                #     values.push Template.currentData().ev["#{field.key}"]
                # else
                #     values.push Template.currentData()["#{field.key}"]
            values

    schemas: -> Docs.find type:'schema'
    views: -> Docs.find type:'view'
    collections: -> Docs.find type:'collection'

    display_field_schema: ->
        found = Docs.findOne
            type:'schema'
            slug:'display_field'

    display_field_value: ->
        display_field = Template.parentData(1)
        display_field["#{@slug}"]

    field_docs: ->
        Docs.find {
            type:'display_field'
            block_id: @_id
        }, sort:rank:1




Template.edit_block.events
    'click .tab_nav': (e,t)->
        tab_name = e.target.getAttribute('data-tab')

        button=e.currentTarget.id

        $("#"+button).addClass('primary');

        $.tab('change tab', tab_name)

    'click .add_field_doc': ->
        block = Template.currentData()
        field_count = Docs.find(type:'display_field').count()
        Docs.insert
            type:'display_field'
            block_id: @_id
            rank:field_count+1


    'click .delete_field': ->
        if confirm 'Remove field?'
            Docs.remove @_id


    'click .remove_block': ->
        if confirm 'Remove block?'
            Docs.remove @_id

    'click .add_schema_field': ->
        block = Template.currentData()
        field_count = Docs.find(type:'display_field').count()
        Docs.insert
            type:'display_field'
            key:@slug
            label:@title
            sortable:true
            visible:true
            ev_subset:@ev_subset
            block_id: block._id
            rank:field_count+1

    'click .remove_schema_field': ->
        if confirm 'Remove field?'
            block = Template.currentData()
            Meteor.call 'remove_block_field_object', block._id, @

    'blur .field_template': (e,t)->
        template_value = e.currentTarget.value
        Meteor.call 'update_block_field', Template.currentData()._id, @, 'field_template', template_value

    'blur .field_label': (e,t)->
        template_value = e.currentTarget.value
        Meteor.call 'update_block_field', Template.currentData()._id, @, 'label', template_value

