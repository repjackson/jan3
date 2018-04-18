if Meteor.isClient
    FlowRouter.route '/edit/:doc_id', action: (params) ->
        BlazeLayout.render 'layout',
            main: 'edit_doc'
    
    Template.edit_doc.onCreated ->
        @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
        @autorun -> Meteor.subscribe 'templates'
    
    Template.edit_doc.onRendered ->
        # @autorun =>
        #     if @subscriptionsReady()
        #         Meteor.setTimeout ->
        #             $('.ui.accordion').accordion()
        #         , 1000
            
    
    Template.edit_doc.helpers
        doc: -> Docs.findOne FlowRouter.getParam('doc_id')
        edit_type_template: -> "edit_#{@type}"
    
    
    Template.edit_doc.events
        # 'change #toggle_title': (e,t)->
        #     # console.log e.currentTarget.value
        #     value = $('#toggle_title').is(":checked")
        #     Docs.update FlowRouter.getParam('doc_id'), 
        #         $set:
        #             has_title: value
                    
        # 'change #toggle_subtitle': (e,t)->
        #     # console.log e.currentTarget.value
        #     value = $('#toggle_subtitle').is(":checked")
        #     Docs.update FlowRouter.getParam('doc_id'), 
        #         $set:
        #             has_subtitle: value
                    
        # 'change #toggle_image': (e,t)->
        #     # console.log e.currentTarget.value
        #     value = $('#toggle_image').is(":checked")
        #     Docs.update FlowRouter.getParam('doc_id'), 
        #         $set:
        #             has_image: value
        
        # 'change #toggle_youtube': (e,t)->
        #     # console.log e.currentTarget.value
        #     value = $('#toggle_youtube').is(":checked")
        #     Docs.update FlowRouter.getParam('doc_id'), 
        #         $set:
        #             has_youtube: value
        
        # 'change #toggle_content': (e,t)->
        #     # console.log e.currentTarget.value
        #     value = $('#toggle_content').is(":checked")
        #     Docs.update FlowRouter.getParam('doc_id'), 
        #         $set:
        #             has_content: value
                    
        # 'change #toggle_slug': (e,t)->
        #     # console.log e.currentTarget.value
        #     value = $('#toggle_slug').is(":checked")
        #     Docs.update FlowRouter.getParam('doc_id'), 
        #         $set:
        #             has_slug: value
                    
        # 'change #toggle_number': (e,t)->
        #     # console.log e.currentTarget.value
        #     value = $('#toggle_number').is(":checked")
        #     Docs.update FlowRouter.getParam('doc_id'), 
        #         $set:
        #             has_number: value
                    
        # 'change #toggle_price': (e,t)->
        #     # console.log e.currentTarget.value
        #     value = $('#toggle_price').is(":checked")
        #     Docs.update FlowRouter.getParam('doc_id'), 
        #         $set:
        #             has_price: value