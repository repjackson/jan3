# @Ancestor_ids = new Meteor.Collection 'ancestor_ids'
@Location_tags = new Meteor.Collection 'location_tags'
# @Intention_tags = new Meteor.Collection 'intention_tags'
@Timestamp_tags = new Meteor.Collection 'timestamp_tags'
@Watson_keywords = new Meteor.Collection 'watson_keywords'
@People_tags = new Meteor.Collection 'people_tags'
@Author_ids = new Meteor.Collection 'author_ids'
# @Participant_ids = new Meteor.Collection 'participant_ids'
# @Upvoter_ids = new Meteor.Collection 'upvoter_ids'


# @Roles = new Meteor.Collection 'roles'


@Docs = new Meteor.Collection 'docs'

Docs.before.insert (userId, doc)->
    timestamp = Date.now()
    doc.timestamp = timestamp
    # console.log moment(timestamp).format("dddd, MMMM Do YYYY, h:mm:ss a")
    date = moment(timestamp).format('Do')
    weekdaynum = moment(timestamp).isoWeekday()
    weekday = moment().isoWeekday(weekdaynum).format('dddd')
    month = moment(timestamp).format('MMMM')
    year = moment(timestamp).format('YYYY')

    date_array = [weekday, month, date, year]
    if _
        date_array = _.map(date_array, (el)-> el.toString().toLowerCase())
    # date_array = _.each(date_array, (el)-> console.log(typeof el))
    # console.log date_array
    doc.timestamp_tags = date_array
    doc.author_id = Meteor.userId()
    return

Meteor.users.helpers
    name: -> 
        if @profile?.first_name and @profile?.last_name
            "#{@profile.first_name}  #{@profile.last_name}"
        else
            "#{@username}"
    last_login: -> moment(@status?.lastLogin.date).fromNow()

    five_tags: -> if @tags then @tags[0..3]
    

Docs.helpers
    author: -> Meteor.users.findOne @author_id
    when: -> moment(@timestamp).fromNow()
    office: -> Docs.findOne @referenced_office_id
    customer: -> Docs.findOne @referenced_customer_id
    parent: -> Docs.findOne @parent_id
    comment_count: -> Docs.find({type:'comment', parent_id:@_id}).count()
    notified_users: -> 
        Meteor.users.find 
