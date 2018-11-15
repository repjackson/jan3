Template.userbar.events
    'click .settings': ->
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $set:
                viewing_page:true
                page_template:'account_settings'