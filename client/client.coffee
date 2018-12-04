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
        if delta and delta.keys_return
            for item in delta.keys_return
                facets.push item.name
            facets.push 'keys'
            facets
    
    toggle_value_class: ->
        delta = Docs.findOne type:'delta'
        filter = Template.parentData()
        filter_list = delta["filter_#{filter.key}"]
        if filter_list and @name in filter_list then 'blue active' else ''


Template.facet.helpers
    values: ->
        # console.log @
        delta = Docs.findOne type:'delta'
        # delta["#{@valueOf()}_return"]?[..20]
        filtered_values = []
        # filters = delta["filter_#{@valueOf()}"]
        # filtered_values
        delta["#{@valueOf()}_return"]
    
    
    selected_values: ->
        # console.log @
        delta = Docs.findOne type:'delta'
        # delta["#{@valueOf()}_return"]?[..20]
        filtered_values = []
        fo_values = delta["#filter_{@valueOf()}"]
        filters = delta["filter_#{@valueOf()}"]


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


Template.facet.events
    'click .unselect': ->
        facet = Template.currentData()

        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $pull: 
                "filter_#{facet}": @valueOf()
                active_facets: facet
        Meteor.call 'fo', (err,res)->

    'click .select': ->
        facet = Template.currentData()
        delta = Docs.findOne type:'delta'

        facet_filters = delta["filter_#{facet}"]
        
        Docs.update delta._id,
            $addToSet:
                "filter_#{facet}": @name
                active_facets: facet
        Meteor.call 'fo', (err,res)->