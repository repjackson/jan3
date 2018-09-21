Meteor.users.allow
    update: (userId, doc, fields, modifier) ->
        true
        # if userId and doc._id == userId
        #     true

Cloudinary.config
    cloud_name: 'facet'
    api_key: Meteor.settings.cloudinary_key
    api_secret: Meteor.settings.cloudinary_secret


Meteor.startup(() =>
    Docs._ensureIndex({ "$**": "text" })

    Meteor.users._ensureIndex({ "$**": "text" })

    Meteor.users._ensureIndex( { "username": 1 }, { unique: true } )
)


Accounts.onCreateUser (options=null, user)=>
    if options
        edited_user = Object.assign({
            customer_jpid:options.customer_jpid
            franchisee_jpid:options.franchisee_jpid
            office_jpid:options.office_jpid
            roles:options.roles
        }, user)
        if options.profile
            edited_user.profile = options.profile
    else
        edited_user = {}
    return edited_user



SyncedCron.config
    log: true
    collectionName: 'cron_history'
    utc: false
    collectionTTL: 17280

Meteor.startup () ->
    SyncedCron.add
        name: 'Update incident escalations'
        schedule: (parser) ->
            parser.text 'every 10 minutes'
            # so it catches 1 hour escalations
        job: ->

            SlaSettings = new Mongo.Collection null
            now = moment()

            Docs.find(
                type:'sla_setting'
            ).forEach (sla) ->
                SlaSettings.insert(sla)

            Docs.find(
                type: 'incident'
                open: true,
                level:
                    $lte: 3
            ).forEach (incident) ->
                sla = SlaSettings.findOne
                    type:'sla_setting'
                    escalation_number:incident.level + 1
                    incident_type:incident.incident_type
                    office_jpid:incident.office_jpid

                if sla and sla.escalation_hours
                    last_escalation = moment(incident.escalation_timestamp)
                    hours_diff = (now.diff last_escalation) / 3600000

                    if hours_diff > sla.escalation_hours
                        Incident_Helpers.escalate_incident incident, 'Manual'

if Meteor.isProduction
    SyncedCron.add(
        {
            name: 'Update customers'
            schedule: (parser) ->
                parser.text 'every 6 hours'
            job: ->
                Meteor.call 'get_recent_customers', (err, res)->
                    if err then console.error err
        },{
            name: 'Update users'
            schedule: (parser) ->
                parser.text 'every 3 hours'
            job: ->
                Meteor.call 'sync_ev_users', (err, res)->
                    if err then console.error err
        },{
        },{
            name: 'Update franchisee'
            schedule: (parser) ->
                parser.text 'every 8 hours'
            job: ->
                Meteor.call 'get_recent_franchisees', (err, res)->
                    if err then console.error err
        },{
            name: 'Update office'
            schedule: (parser) ->
                parser.text 'every 6 hours'
            job: ->
                Meteor.call 'get_recent_offices', (err, res)->
                    if err then console.error err
        }
    )


if Meteor.isProduction
    SyncedCron.start()



Docs.allow
    insert: (user_id, doc) -> user_id
    # update: (user_id, doc) -> doc.author_id is user_id or Roles.userIsInRole(user_id, 'admin')
    remove: (user_id, doc) ->
        user = Meteor.users.findOne user_id
        doc.author_id is user_id or 'dev' in user.roles
    update: (user_id, doc) -> user_id
    # remove: (user_id, doc) -> user_id
