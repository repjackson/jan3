


# Template.facet_table.helpers
#     tickets: -> Docs.find type:'ticket'
# Template.ticket_facet.helpers
#     tickets: -> Docs.find type:'ticket'
#     view_segments: -> Session.equals 'view_mode', 'segments'
#     view_cards: -> Session.equals 'view_mode', 'cards'
#     view_table: -> Session.equals 'view_mode', 'table'

#     view_cards_class: -> if Session.equals 'view_mode', 'cards' then 'primary' else ''
#     view_segments_class: -> if Session.equals 'view_mode', 'segments' then 'primary' else ''
#     view_table_class: -> if Session.equals 'view_mode', 'table' then 'primary' else ''

# Template.ticket_facet.events
#     'click .set_view_cards': -> Session.set 'view_mode', 'cards'
#     'click .set_view_segments': -> Session.set 'view_mode', 'segments'
#     'click .set_view_table': -> Session.set 'view_mode', 'table'
