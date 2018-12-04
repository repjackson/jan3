Template.home.onCreated ->
    @autorun -> Meteor.subscribe 'delta'

Template.home.helpers
    delta: -> 
        delta = Docs.findOne type:'delta'
        if delta 
            delta
    
    facets: ->
        # at least keys
        facets = []
        delta = Docs.findOne type:'delta'
        if delta 
            console.log delta
            if delta.keys_filter
                for item in delta.keys_filter
                    facets.push item.name
        facets.push 'keys'
        facets
    
    toggle_value_class: ->
        delta = Docs.findOne type:'delta'
        filter = Template.parentData()
        filter_list = delta["filter_#{filter.key}"]
        if filter_list and @name in filter_list then 'blue active' else ''
        
    
Template.result.helpers
    value: ->
        filter = Template.parentData()
        filter["#{@valueOf()}"]


Template.facet.helpers
    values: ->
        # console.log @
        delta = Docs.findOne type:'delta'
        filtered_values = []
        if delta
            filters = delta["filter_#{@valueOf()}"]
            unfiltered_return = delta["#{@valueOf()}_return"]
            if unfiltered_return and filters
                console.log filters
                for val in unfiltered_return
                    if val.name in filters
                        continue
                    else if val.count < delta.total
                        filtered_values.push val
                filtered_values
    
    selected_values: ->
        # console.log @
        delta = Docs.findOne type:'delta'
        # delta["#{@valueOf()}_return"]?[..20]
        filtered_values = []
        if delta
            delta["filter_#{@valueOf()}"]


Template.home.events
    'click .create_delta': (e,t)->
        Docs.insert
            type:'delta'
            facets: [{key:'keys', res:[]}]
            result_ids:[]
        # Meteor.call 'fo'
    
    'click .delete_delta': (e,t)->
        delta = Docs.findOne type:'delta'
        Docs.remove delta._id
    
    'click .print_delta': (e,t)->
        delta = Docs.findOne type:'delta'
        console.log delta

    'click .recalc': ->
        Meteor.call 'fo', (err,res)->


Template.facet.events
    'click .unselect': ->
        facet = Template.currentData()

        delta = Docs.findOne type:'delta'
        Meteor.call 'remove_facet_filter', delta._id, facet.key, @valueOf(), ->


    'click .select': ->
        facet = Template.currentData()
        delta = Docs.findOne type:'delta'

        facet_filters = delta["filter_#{facet}"]
        
        Meteor.call 'add_facet_filter', delta._id, facet.key, @name, ->

