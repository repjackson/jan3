Template.rules.onCreated ->
    @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
Template.rules.helpers


FlowRouter.route '/rules', action: ->
    BlazeLayout.render 'layout', 
        # sub_nav: 'dev_nav'
        main: 'rules'


Template.rules.onCreated ->
    @autorun => Meteor.subscribe 'docs', [], 'rule'
Template.rules.helpers
    rules: ->  Docs.find { type:'rule'}


Template.rule_card.onCreated ->

Template.rule_card.helpers
    

# Template.rule_edit.onCreated ->
#     @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')

# Template.rule_edit.helpers
#     rule: -> Doc.findOne FlowRouter.getParam('doc_id')
    
Template.rule_edit.events
    'click #delete': ->
        template = Template.currentData()
        swal {
            title: 'Delete rule?'
            # text: 'Confirm delete?'
            type: 'error'
            animation: false
            showCancelButton: true
            closeOnConfirm: true
            cancelButtonText: 'Cancel'
            confirmButtonText: 'Delete'
            confirmButtonColor: '#da5347'
        }, =>
            doc = Docs.findOne FlowRouter.getParam('doc_id')
            # console.log doc
            Docs.remove doc._id, ->
                FlowRouter.go "/rules"

