Template.table_footer.events
    # 'click .set_page_number': (e,t)-> 
    #     Session.set 'page_number', @number
    #     int_page_size = parseInt(Session.get('page_size'))
    #     skip_amount = @number*int_page_size-int_page_size
    #     Session.set 'skip', skip_amount
    
    # 'change #page_size': (e,t)->
    #     Session.set 'page_size',$('#page_size').val()

    # 'click .set_10': (e,t)-> 
    #     Session.set 'page_number', 1
    #     $('.table_stats').transition(
    #         animation:'pulse'
    #         duration:100
    #         )
    #     $('tbody').transition(
    #         animation:'pulse'
    #         duration:100
    #         )
    #     Session.set 'page_size',10
    #     Session.set 'page_number',1
    #     Session.set 'skip',0

    
    # 'click .set_20': (e,t)-> 
    #     $('.table_stats').transition(
    #         animation:'pulse'
    #         duration:100
    #         )
    #     $('tbody').transition(
    #         animation:'pulse'
    #         duration:100
    #         )
    #     Session.set 'page_size',20
    #     Session.set 'page_number', 1
    #     Session.set 'skip',0
    
    # 'click .set_50': (e,t)-> 
    #     $('.table_stats').transition(
    #         animation:'pulse'
    #         duration:100
    #         )
    #     $('tbody').transition(
    #         animation:'pulse'
    #         duration:100
    #         )
    #     Session.set 'page_number', 1
    #     Session.set 'page_size',50
    #     Session.set 'skip',0
    
    # 'click .set_100': (e,t)-> 
    #     $('.table_stats').transition(
    #         animation:'pulse'
    #         duration:100
    #         )
    #     $('tbody').transition(
    #         animation:'pulse'
    #         duration:100
    #         )
    #     Session.set 'page_number', 1
    #     Session.set 'page_size',100
    #     Session.set 'skip',0
    


    # 'click .increment_page': (e,t)->
    #     current_page = Session.get('page_number')
    #     next_page = current_page+1
    #     Session.set 'page_number', next_page
    #     int_page_size = parseInt(Session.get('page_size'))
    #     skip_amount = next_page*int_page_size-int_page_size
    #     Session.set 'skip', skip_amount
    
    # 'click .decrement_page': (e,t)->
    #     current_page = Session.get('page_number')
    #     previous_page = current_page-1
    #     Session.set 'page_number', previous_page
    #     int_page_size = parseInt(Session.get('page_size'))
    #     skip_amount = previous_page*int_page_size-int_page_size
    #     Session.set 'skip', skip_amount
    





Template.block.events
    'click .set_page_number': (e,t)->
        # $('.table_stats').transition(
        #     animation:'pulse'
        #     duration:100
        #     )
        # $('tbody').transition(
        #     animation:'pulse'
        #     duration:100
        #     )
        console.log @
        console.log Template.currentData()
        console.log Template.parentData(0)
        console.log Template.parentData(1)
        console.log Template.parentData(2)
        
        t.page_number.set @number
        int_page_size = parseInt(t.page_size.get())
        skip_amount = @number*int_page_size-int_page_size
        t.skip.set skip_amount
    
    
    'click .increment_page': (e,t)->
        console.log @
        console.log Template.currentData()
        console.log Template.parentData(0)
        console.log Template.parentData(1)
        console.log Template.parentData(2)

        # $('.table_stats').transition(
        #     animation:'pulse'
        #     duration:100
        #     )
        # $('tbody').transition(
        #     animation:'pulse'
        #     duration:100
        #     )
        current_page = t.page_number.get()
        next_page = current_page+1
        t.page_number.set next_page
        int_page_size = parseInt(t.page_size.get())
        skip_amount = next_page*int_page_size-int_page_size
        t.skip.set skip_amount
    
    'click .decrement_page': (e,t)->
        # $('.table_stats').transition(
        #     animation:'pulse'
        #     duration:100
        #     )
        # $('tbody').transition(
        #     animation:'pulse'
        #     duration:100
        #     )
        current_page = Session.get('page_number')
        previous_page = current_page-1
        Session.set 'page_number', previous_page
        int_page_size = parseInt(Session.get('page_size'))
        skip_amount = previous_page*int_page_size-int_page_size
        Session.set 'skip', skip_amount
    
    
    'change #page_size': (e,t)->
        t.page_size.set $('#page_size').val()

    'click .set_10': (e,t)-> 
        # $('.table_stats').transition(
        #     animation:'pulse'
        #     duration:100
        #     )
        # $('tbody').transition(
        #     animation:'pulse'
        #     duration:100
        #     )
        t.page_size.set 10
        t.page_number.set 1
        t.skip.set 0
        
    'click .set_20': (e,t)-> 
        # $('.table_stats').transition(
        #     animation:'pulse'
        #     duration:100
        #     )
        # $('tbody').transition(
        #     animation:'pulse'
        #     duration:100
        #     )
        t.page_size.set 20
        t.page_number.set 1
        t.skip.set 0
    
    
    'click .set_50': (e,t)-> 
        # $('.table_stats').transition(
        #     animation:'pulse'
        #     duration:100
        #     )
        # $('tbody').transition(
        #     animation:'pulse'
        #     duration:100
        #     )
        t.page_size.set 50
        t.page_number.set 1
        t.skip.set 0
    
    'click .set_100': (e,t)-> 
        # $('.table_stats').transition(
        #     animation:'pulse'
        #     duration:100
        #     )
        # $('tbody').transition(
        #     animation:'pulse'
        #     duration:100
        #     )
        t.page_size.set 100
        t.page_number.set 1
        t.skip.set 0
    

Template.sort_column_header.events
    'click .sort_by': (e,t)->
        Session.set 'sort_key', @key
        if Session.equals 'sort_direction', -1
            Session.set 'sort_direction', 1
        else
            Session.set 'sort_direction', -1

Template.sort_column_header.helpers
    sort_descending: ->
        if Session.equals('sort_direction', 1) and Session.equals('sort_key', @key) 
            return true
    sort_ascending: ->
        if Session.equals('sort_direction', -1) and Session.equals('sort_key', @key)
            return true
        

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
    # no_query: -> Session.equals('query', null) or Session.equals('query', '')

    # show_decrement: -> Session.get('page_number')>1
    # show_increment: -> Session.get('page_number')<Session.get('number_of_pages')

    # show_10_decrement: -> Session.get('page_number')>10

    # skip_amount: -> parseInt(Template.instance().skip.get())+1
    # end_result: -> Template.instance().skip.get() + 1 + Session.get('page_size')

    # pagination_item_class: ->
    #     if Session.equals('page_number', @number) then 'active' else ''
        
    # count_amount: ->
    #     count_stat = Stats.findOne
    #         doc_type:@doc_type
    #         stat_type:@stat_type
    #     # console.log 'count_stat', count_stat
    #     # console.log 'this', @
            
    #     if count_stat
    #         count_stat.amount
            
    # page_size_button_class: (string_size)->
    #     number = parseInt string_size
    #     if Session.equals('page_size', number) then 'active' else ''
    
    # show_10: ->
    #     # console.log @
    #     count_stat = Stats.findOne
    #         doc_type:@doc_type
    #         stat_type:@stat_type
    #     if count_stat
    #         if count_stat.amount > 0
    #             true
    #         else
    #             false
    #     else
    #         false
    # show_20: ->
    #     count_stat = Stats.findOne
    #         doc_type:@doc_type
    #         stat_type:@stat_type
    #     if count_stat
    #         if count_stat.amount > 10
    #             true
    #         else
    #             false
    #     else
    #         false
    # show_50: ->
    #     count_stat = Stats.findOne
    #         doc_type:@doc_type
    #         stat_type:@stat_type
    #     if count_stat
    #         if count_stat.amount > 20
    #             true
    #         else
    #             false
    #     else
    #         false
            
    # show_100: ->
    #     count_stat = Stats.findOne
    #         doc_type:@doc_type
    #         stat_type:@stat_type
    #     if count_stat
    #         if count_stat.amount > 50
    #             true
    #         else
    #             false
    #     else
    #         false
            
    
    # pages: ->
    #     stat_doc = Stats.findOne
    #         doc_type:@doc_type
    #         stat_type:@stat_type
    #     if stat_doc
    #         count_amount = stat_doc.amount
    #         page_size = parseInt Session.get('page_size')
    #         number_of_pages = Math.ceil(count_amount/page_size)
    #         Session.set('number_of_pages', number_of_pages)
    #         pages = []
    #         page = 0
    #         if number_of_pages > 15
    #             number_of_pages = 15
    #         while page<number_of_pages
    #             pages.push {number:page+1}
    #             page++
    #         return pages

Template.block.helpers
    no_query: -> Session.equals('query', null) or Session.equals('query', '')

    show_decrement: -> Template.instance().page_number.get()>1
    
    show_increment: -> Template.instance().page_number.get() < Template.instance().number_of_pages.get()

    show_10_decrement: -> Template.instance().page_number.get() >  10



    skip_amount: -> parseInt(Template.instance().skip.get())+1
    end_result: -> Template.instance().skip.get() + 1 + Template.instance().page_size.get()

    pagination_item_class: ->
        if Template.instance().page_number.get() is @number then 'active' else ''
        
    count_amount: ->
        console.log @
        console.log Template.currentData()
        console.log Template.parentData(0)
        console.log Template.parentData(1)
        console.log Template.parentData(2)
        count_stat = Stats.findOne
            doc_type:@children_doc_type
            stat_type:@table_stat_type
        console.log 'count_stat', count_stat
        # console.log 'this', @
            
        if count_stat
            count_stat.amount
            
    page_size_button_class: (string_size)->
        number = parseInt string_size
        if Session.equals('page_size', number) then 'active' else ''
    
    show_10: ->
        count_stat = Stats.findOne
            doc_type:@children_doc_type
            stat_type:@table_stat_type
        console.log count_stat
        if count_stat
            # console.log count_stat
            if count_stat.amount > 0
                # console.log 'true'
                true
            else
                # console.log 'false'
                false
        else
            # console.log '2false'
            false
    show_20: ->
        count_stat = Stats.findOne
            doc_type:@children_doc_type
            stat_type:@table_stat_type
        if count_stat
            if count_stat.amount > 10
                true
            else
                false
        else
            false
    show_50: ->
        count_stat = Stats.findOne
            doc_type:@children_doc_type
            stat_type:@table_stat_type
        if count_stat
            if count_stat.amount > 20
                true
            else
                false
        else
            false
            
    show_100: ->
        count_stat = Stats.findOne
            doc_type:@children_doc_type
            stat_type:@table_stat_type
        if count_stat
            if count_stat.amount > 50
                true
            else
                false
        else
            false
            
    
    pages: ->
        stat_doc = Stats.findOne
            doc_type:@children_doc_type
            stat_type:@table_stat_type
        if stat_doc
            count_amount = stat_doc.amount
            page_size = parseInt Template.instance().page_size.get()
            number_of_pages = Math.ceil(count_amount/page_size)
            pages = []
            page = 0
            if number_of_pages > 15
                number_of_pages = 15
            while page<number_of_pages
                pages.push {number:page+1}
                page++
            return pages



