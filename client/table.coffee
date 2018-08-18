Template.table.onCreated ->
    @autorun => Meteor.subscribe 'count', @data.type



Template.sort_column_header.helpers
    sort_descending: ->
        if Session.equals('sort_direction', '1') and Session.equals('sort_key', @key) 
            return true
    sort_ascending: ->
        if Session.equals('sort_direction', '-1') and Session.equals('sort_key', @key)
            return true
        
Template.table.helpers
    sort_descending: ->
        if Session.equals('sort_direction', '1') and Session.equals('sort_key', @key) 
            return true
    sort_ascending: ->
        if Session.equals('sort_direction', '-1') and Session.equals('sort_key', @key)
            return true
    fields: -> Template.currentData().fields
    table_docs: -> 
        if Template.currentData().collection is 'Stats' then Stats.find() else Docs.find(type:Template.currentData().type)
    values: ->
        fields = Template.parentData().fields
        values = []
        for field in fields
            values.push @["#{field.key}"]
        values

Template.table_footer.events
    'click .set_page_number': -> 
        Session.set 'current_page_number', @number
        int_page_size = parseInt(Session.get('page_size'))
        skip_amount = @number*int_page_size-int_page_size
        Session.set 'skip', skip_amount
    
    'change #page_size': (e,t)->
        Session.set 'page_size',$('#page_size').val()

    'click .set_10': ()-> Session.set 'page_size',10
    'click .set_20': ()-> Session.set 'page_size',20
    'click .set_50': ()-> Session.set 'page_size',50
    'click .set_100': ()-> Session.set 'page_size',100

Template.sort_column_header.events
    'click .sort_by': (e,t)->
        Session.set 'sort_key', @key
        if Session.equals 'sort_direction', '-1'
            Session.set 'sort_direction', '1'
        else if Session.equals 'sort_direction', '1'
            Session.set 'sort_direction', '-1'


Template.search_key.events
    'keyup .search_key': ->
        
Template.query_input.helpers
    current_query: -> Session.get('query')
        
Template.query_input.events
    'keyup #query': (e,t)->
        e.preventDefault()
        query = $('#query').val().trim()
        # if e.which is 13 #enter
        Session.set 'skip', 0
        # $('#query').val ''
        Session.set 'query', query

    'click .clear_search': -> Session.set('query', null)

Template.table_footer.helpers
    is_querying: -> Session.get('query')

    skip_amount: -> parseInt(Session.get('skip'))+1

    pagination_item_class: ->
        if Session.equals('current_page_number', @number) then 'active' else ''
        
    count_amount: ->
        count_stat = Stats.findOne
            doc_type:@doc_type
            stat_type:@stat_type
        # console.log 'count_stat', count_stat
        # console.log 'this', @
            
        if count_stat
            count_stat.amount
            
    page_size_button_class: (string_size)->
        number = parseInt string_size
        if Session.equals('page_size', number) then 'blue' else ''
    
    show_10: ->
        count_stat = Stats.findOne
            doc_type:@doc_type
            stat_type:@stat_type
        if count_stat
            if count_stat.amount > 0
                true
            else
                false
        else
            false
    show_20: ->
        count_stat = Stats.findOne
            doc_type:@doc_type
            stat_type:@stat_type
        if count_stat
            if count_stat.amount > 10
                true
            else
                false
        else
            false
    show_50: ->
        count_stat = Stats.findOne
            doc_type:@doc_type
            stat_type:@stat_type
        if count_stat
            if count_stat.amount > 20
                true
            else
                false
        else
            false
            
    show_100: ->
        count_stat = Stats.findOne
            doc_type:@doc_type
            stat_type:@stat_type
        if count_stat
            if count_stat.amount > 50
                true
            else
                false
        else
            false
            
    
    pages: ->
        stat_doc = Stats.findOne
            doc_type:@doc_type
            stat_type:@stat_type
        if stat_doc
            count_amount = stat_doc.amount
            current_page_size = parseInt Session.get('page_size')
            number_of_pages = Math.ceil(count_amount/current_page_size)
            pages = []
            page = 0
            if number_of_pages > 10
                number_of_pages = 10
            while page<number_of_pages
                pages.push {number:page+1}
                page++
            return pages



