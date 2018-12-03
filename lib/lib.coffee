@Docs = new Meteor.Collection 'docs'


Docs.before.insert (userId, doc)->
    timestamp = Date.now();
    now = moment(timestamp);

    doc.timestamp = timestamp

    doc.updated = timestamp

    doc.long_timestamp = moment(timestamp).format("dddd, MMMM Do YYYY, h:mm:ss a")
    date = moment(timestamp).format('Do')
    weekdaynum = moment(timestamp).isoWeekday()
    weekday = moment().isoWeekday(weekdaynum).format('dddd')
    month = moment(timestamp).format('MMMM')
    year = moment(timestamp).format('YYYY')

    date_array = [weekday, month, date, year]
    if _
        date_array = _.map(date_array, (el)-> el.toString().toLowerCase())
    doc.timestamp_tags = date_array
    doc.author_id = Meteor.userId()
    return



Docs.helpers
    author: -> Meteor.users.findOne @author_id
    when: -> moment(@timestamp).fromNow()
