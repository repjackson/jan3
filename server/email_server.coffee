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
        )
        return
        # to: ["<richard@janhub.com>","<zack@janhub.com>", "<Nicholas.Rose@premiumfranchisebrands.com>","<ziedmahdi@gmail.com>"]
        
 
    send_email_about_ticket_assignment:(ticket_doc_id, username)->
        ticket = Docs.findOne ticket_doc_id
        
        assigned_to_user = Meteor.users.findOne username:username
        ticket_link = "https://www.jan.meteorapp.com/p/ticket_admin_view?doc_id=#{ticket._id}"
        complete_ticket_link = "https://www.jan.meteorapp.com/p/ticket_admin_view?doc_id=#{ticket._id}&mark_complete=true"
        
        mail_fields = {
            # to: ["<richard@janhub.com>","<zack@janhub.com>", "<Nicholas.Rose@premiumfranchisebrands.com>","<ziedmahdi@gmail.com>"]

            # to: ["<#{assigned_to_user.emails[0].address}>"]
            # to: ["<richard@janhub.com>","<zack@janhub.com>", "<Nicholas.Rose@premiumfranchisebrands.com>","<ziedmahdi@gmail.com>"]
            to: 'repjackson@gmail.com'
            from: "Jan-Pro Customer Portal <portal@jan-pro.com>"
            subject: "Ticket Assignment"
            html: "<h4>You have been assigned to ticket ##{ticket.ticket_number} from customer: #{ticket.customer_name}.</h4>
                <h5>Type: #{ticket.ticket_type}</h5>
                <h5>Number: #{ticket.ticket_number}</h5>
                <h5>Details: #{ticket.ticket_details}</h5>
                <h5>Created: #{ticket.long_timestamp}</h5>
                <h5>Office: #{ticket.ticket_office_name}</h5>
                <h5>Status: #{ticket.status}</h5>
                <h5>Service Date: #{ticket.service_date}</h5>
                <p>view the ticket <a href=#{ticket_link}>here</a>.
                <p>Mark task complete <a href=#{complete_ticket_link}>here</a>.</p>
            "
        }
        Meteor.call 'send_email', mail_fields
