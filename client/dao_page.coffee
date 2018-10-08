FlowRouter.route '/d/:page_slug/',
    action: (params, query_params)->
        BlazeLayout.render 'layout',
            main: 'dao_page'


Template.dao_page_edit.onRendered ->
    Meteor.setTimeout ->
        $('.accordion').accordion();
    , 500


Template.dao_page.onCreated ->
    @autorun => Meteor.subscribe 'page_by_slug', FlowRouter.getParam('page_slug')
    # @autorun => Meteor.subscribe 'blocks_by_page_slug', FlowRouter.getParam('page_slug')
    # @autorun => Meteor.subscribe 'doc', FlowRouter.getQueryParam('doc_id')
    # @autorun => Meteor.subscribe 'type', 'event_type'


Template.dao_page.events
    'click #create_page': ->
        slug = FlowRouter.getParam('page_slug')
        Docs.insert
            type:'page'
            slug:slug

Template.dao_page.helpers
    page_doc: ->
        FlowRouter.watchPathChange();
        currentContext = FlowRouter.current();
        Docs.findOne
            type:'page'
            slug: FlowRouter.getParam('page_slug')

    current_page_slug: -> FlowRouter.getParam('page_slug')

Template.dao_page_edit.helpers
    page_doc: ->
        FlowRouter.watchPathChange();
        currentContext = FlowRouter.current();
        Docs.findOne
            type:'page'
            slug: FlowRouter.getParam('page_slug')

    current_page_slug: -> FlowRouter.getParam('page_slug')