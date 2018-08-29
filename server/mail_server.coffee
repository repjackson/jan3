Meteor.publish 'unread', ->
    Docs.find({
        type:'message'
        read_by: $nin: [Meteor.userId()]
    }, {limit:20})




Meteor.publish 'unread_count', ()->
    Meteor.call 'calculate_current_user_unread_count'
    if Meteor.user()
        Stats.find
            doc_type: 'message'
            stat_type: 'unread'
            username: Meteor.user().username

Meteor.publish 'inbox_count', ()->
    Meteor.call 'calculate_current_user_inbox_count'
    if Meteor.user()
        Stats.find
            doc_type: 'message'
            stat_type: 'inbox'
            username: Meteor.user().username


Meteor.methods
    calculate_current_user_unread_count: ()->
        username = Meteor.user().username
        unread_message_count = 
            Docs.find({
                type:'message'
                read_by: $nin: [Meteor.userId()]
            }).count()
        Stats.update({
            doc_type: 'message'
            stat_type: 'unread'
            username: username
        },{ $set:amount:unread_message_count },{upsert:true})

    calculate_current_user_inbox_count: ()->
        username = Meteor.user().username
        inbox_message_count = 
            Docs.find({
                type:'message'
                to_username: username
            }).count()
        Stats.update({
            doc_type: 'message'
            stat_type: 'inbox'
            username: username
        },{ $set:amount:inbox_message_count },{upsert:true})
