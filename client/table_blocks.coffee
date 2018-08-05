Template.pagination.helpers
    pagination_item_class: ->
        # console.log @
        if Session.equals('current_page_number', @number) then 'active' else ''
        
    pages: ->
        stat_doc = Stats.findOne()
        if stat_doc
            count_amount = stat_doc.amount
            # console.log count_amount
            current_page_size = parseInt Session.get('page_size')
            number_of_pages = Math.ceil(count_amount/current_page_size)
            # console.log 'number of pages', number_of_pages
            pages = []
            page = 0
            if number_of_pages>5
                number_of_pages = 5
            while page<number_of_pages
                pages.push {number:page}
                # console.log page
                page++
            # console.log pages
            return pages
        
        
Template.pagination.events
    'click .set_page_number': -> 
        console.log @
        Session.set 'current_page_number', @number
        skip_amount = @number*parseInt(Session.get('page_size'))
        Session.set 'skip', skip_amount
        console.log skip_amount
    
    

Template.page_size_input.helpers
    count_amount: ->
        count_stat = Stats.findOne()
        if count_stat
            # console.log count_stat
            count_stat.amount

Template.page_size_input.events
    'change #page_size': (e,t)->
        Session.set 'page_size',$('#page_size').val()

    'click .set_10': ()->Session.set 'page_size',10
    'click .set_20': ()->Session.set 'page_size',20
    'click .set_50': ()->Session.set 'page_size',50
    'click .set_100': ()->Session.set 'page_size',100



Template.sort_column_header.helpers
    sort_descending: ->
        # console.log @
        if Session.equals('sort_direction', '1') and Session.equals('sort_key', @key) 
            # console.log '1'
            return true
    sort_ascending: ->
        # console.log @
        if Session.equals('sort_direction', '-1') and Session.equals('sort_key', @key)
            # console.log '-1'
            return true

Template.sort_column_header.events
    'click .sort_by': (e,t)->
        Session.set 'sort_key', @key
        if Session.equals 'sort_direction', '-1'
            Session.set 'sort_direction', '1'
        else if Session.equals 'sort_direction', '1'
            Session.set 'sort_direction', '-1'


Template.search_key.events
    'keyup .search_key': ->
        console.log @
        
        