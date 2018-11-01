Template.delete_button.events
    'click .delete_doc': ->
        if confirm "Delete #{@title} #{@label}?"
            Docs.remove @_id