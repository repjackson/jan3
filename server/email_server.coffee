api_key = Meteor.settings.mailgun.api_key
domain = Meteor.settings.mailgun.domain
mailgun = require('mailgun-js')({apiKey: api_key, domain: domain});
 
Meteor.methods 
    send_email: (mail_fields) ->
        @unblock()
        data = {
            to: mail_fields.to
            from: mail_fields.from
            subject: mail_fields.subject
            text: mail_fields.text
            html: mail_fields.html
        }
        console.log 'sending email', data
        # if Meteor.isProduction
        # if Meteor.isDevelopment
        mailgun.messages().send(data, (error, body)->
          console.log(body)
        );
        return
        # to: ["<richard@janhub.com>","<zack@janhub.com>", "<Nicholas.Rose@premiumfranchisebrands.com>","<ziedmahdi@gmail.com>"]
        
    send_message: (to_username, from_username, message_text)->    
        Docs.insert
            type:'message'
            from_username:from_username
            to_username: to_username
            text: message_text
        
    
    send_email_about_task_assignment:(task_doc_id, username)->
        task_doc = Docs.findOne task_doc_id
        
        assigned_to_user = Meteor.users.findOne username:username
        task_link = "https://www.jan.meteorapp.com/v/#{task_doc._id}"
        
        mail_fields = {
            to: ["<#{assigned_to_user.emails[0].address}>"]
            from: "Jan-Pro Customer Portal <portal@jan-pro.com>"
            subject: "Task Assignment"
            html: "<h4>You have been assigned to task #{task_doc.title}..</h4>
                <ul>
                    <li>Completed: #{task_doc.complete}</li>
                    <li>Due Date: #{task_doc.due_date}</li>
                    <li>Tags: #{task_doc.tags}</li>
                </ul>
                <p>view the task <a href=#{task_link}>here</a>.
            "
        }
        Meteor.call 'send_email', mail_fields
 
    send_email_about_incident_assignment:(incident_doc_id, username)->
        incident = Docs.findOne incident_doc_id
        
        assigned_to_user = Meteor.users.findOne username:username
        incident_link = "https://www.jan.meteorapp.com/p/incident_admin_view?doc_id=#{incident._id}"
        complete_incident_link = "https://www.jan.meteorapp.com/p/incident_admin_view?doc_id=#{incident._id}&mark_complete=true"
        
        mail_fields = {
            # to: ["<#{assigned_to_user.emails[0].address}>"]
            to: ['<repjackson@gmail.com>, <ziedmahdi@gmail.com>']
            from: "Jan-Pro Customer Portal <portal@jan-pro.com>"
            subject: "Incident Assignment"
            html: "<h4>You have been assigned to incident ##{incident.incident_number} from customer: #{incident.customer_name}.</h4>
                <h5>Type: #{incident.incident_type}</h5>
                <h5>Number: #{incident.incident_number}</h5>
                <h5>Details: #{incident.incident_details}</h5>
                <h5>Created: #{incident.long_timestamp}</h5>
                <h5>Office: #{incident.incident_office_name}</h5>
                <h5>Status: #{incident.status}</h5>
                <h5>Service Date: #{incident.service_date}</h5>
                <p>view the incident <a href=#{incident_link}>here</a>.
                <p>Mark task complete <a href=#{complete_incident_link}>here</a>.</p>
            "
        }
        Meteor.call 'send_email', mail_fields
