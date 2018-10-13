Template.block.events
    'click .set_page_number': (e,t)->
        t.page_number.set @number
        int_page_size = parseInt(t.page_size.get())
        skip_amount = @number*int_page_size-int_page_size
        t.skip.set skip_amount


    'click .increment_page': (e,t)->
        current_page = t.page_number.get()
        next_page = current_page+1
        t.page_number.set next_page
        int_page_size = parseInt(t.page_size.get())
        skip_amount = next_page*int_page_size-int_page_size
        t.skip.set skip_amount

    'click .decrement_page': (e,t)->
        current_page = t.page_number.get()
        previous_page = current_page-1
        t.page_number.set previous_page
        int_page_size = parseInt(t.page_size.get())
        skip_amount = previous_page*int_page_size-int_page_size
        t.skip.set skip_amount


    'change #page_size': (e,t)->
        t.page_size.set $('#page_size').val()

    'click .set_10': (e,t)->
        t.page_size.set 10
        t.page_number.set 1
        t.skip.set 0

    'click .set_20': (e,t)->
        t.page_size.set 20
        t.page_number.set 1
        t.skip.set 0


    'click .set_50': (e,t)->
        t.page_size.set 50
        t.page_number.set 1
        t.skip.set 0

    'click .set_100': (e,t)->
        t.page_size.set 100
        t.page_number.set 1
        t.skip.set 0


Template.sort_column_header.events
    'click .sort_by': (e,t)->
        t.sort_key.set @key
        if t.sort_direction.get() is -1
            t.sort_direction.set 1
        else
            t.sort_direction.set -1

Template.sort_column_header.helpers
    sort_descending: ->
        if Template.instance().sort_direction.get() is 1 and Template.instance().sort_key.get() is @key
            return true
    sort_ascending: ->
        if Template.instance().sort_direction.get() is -1 and Template.instance().sort_key.get() is @key
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
        # t.skip.set 0
        # $('#query').val ''
        Session.set 'query', query

    'click .clear_search': -> Session.set('query', null)


Template.block.helpers
    no_query: -> Session.equals('query', null) or Session.equals('query', '')

    show_decrement: -> Template.instance().page_number.get()>1

    show_increment: ->
        current_page = Template.instance().page_number.get()
        number_of_pages = Template.instance().number_of_pages.get()
        current_page < number_of_pages

    show_10_decrement: -> Template.instance().page_number.get() >  10

    current_page: ->
        current_page = Template.instance().page_number.get()

    current_page_size: -> Template.instance().page_size.get()

    skip_amount: -> parseInt(Template.instance().skip.get())+1
    end_result: -> Template.instance().skip.get() + 1 + Template.instance().page_size.get()

    pagination_item_class: ->
        if Template.instance().page_number.get() is @number then 'active' else ''


    page_size_button_class: (string_size)->
        number = parseInt string_size
        if Template.instance().page_size.get() is number then 'active' else ''