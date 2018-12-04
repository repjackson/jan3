Template.registerHelper 'delta', () -> Docs.findOne type:'delta'


Template.home.onCreated ->
    @autorun -> Meteor.subscribe 'delta'
    delta = Docs.findOne type:'delta'




# consolidate all templates in home, only new templates if different data context
# which shouldn't be


# comments are fun.  hi future people.

Template.home.helpers
    facets: ->
        # at least keys
        delta = Docs.findOne type:'delta'
        if delta and delta.keys_return
            facets = delta.keys_return
            facets.push 'keys'
            facets
    selector_value: ->
        switch typeof @name
            when 'string' then @name
            when 'boolean'
                if @name is true then 'True'
                else if @name is false then 'False'
            when 'number' then @name

    toggle_value_class: ->
        delta = Docs.findOne type:'delta'
        filter = Template.parentData()
        filter_list = delta["filter_#{filter.key}"]
        if filter_list and @name in filter_list then 'blue active' else ''


    values: ->
        # console.log @
        delta = Docs.findOne type:'delta'
        # delta["#{@key}_return"]?[..20]
        filtered_values = []
        fo_values = delta["#{@valueOf()}_return"]
        filters = delta["filter_#{@valueOf()}"]
        if fo_values
            for value in fo_values
                if value.name in filters
                    filtered_values.push value
                else if value.count < delta.total
                    filtered_values.push value
        filtered_values
    
    
    selected_values: ->
        # console.log @
        delta = Docs.findOne type:'delta'
        # delta["#{@key}_return"]?[..20]
        filtered_values = []
        fo_values = delta["#filter_{@key}"]
        filters = delta["filter_#{@key}"]


Template.home.events
    'click .create_delta': (e,t)->
        new_delta_id =
            Docs.insert
                type:'delta'
                result_ids:[]
        Meteor.call 'fo', new_delta_id
    
    'click .delete_delta': (e,t)->
        delta = Docs.findOne type:'delta'
        Docs.remove delta._id
    
    'click .print_delta': (e,t)->
        delta = Docs.findOne type:'delta'
        console.log delta

    'click .recalc': ->
        Meteor.call 'fo', (err,res)->

    'click .unselect': ->
        facet = Template.currentData()
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $pull: 
                "filter_#{facet.key}": @valueOf()
                active_facets: facet.key
        Meteor.call 'fo', (err,res)->

    'click .select': ->
        filter = Template.parentData()
        delta = Docs.findOne type:'delta'
        filter_list = delta["filter_#{filter.key}"]
        
        Docs.update delta._id,
            $addToSet:
                "filter_#{filter.key}": @name
                active_facets: filter.key
                
        Meteor.call 'fo', (err,res)->