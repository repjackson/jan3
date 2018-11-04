Meteor.methods
    ls: ->
        # HTTP.call 'GET',"https://sandbox.lodestarbpm.com/test/api-test.php", (err,res)->
        HTTP.call 'GET',"https://secure.lodestarbpm.com/jpi-api/", (err,res)->
            if err then console.error err
            else
                body = res.content
                json = JSON.parse body
                # console.dir json
                # console.log json.offices.length
                # console.log json.franchisees.length
                console.dir json.customers[..4]
                # for customer in json.customers
                #     # console.log 'customer id', customer.id
                #     # console.dir customer
                #     found_customer =
                #         Docs.findOne
                #             type:'customer'
                #             jpid:customer.id
                #     if found_customer
                #         console.log 'found customer', customer.id
                #     else
                #         local = {}

                #         local.type = 'customer'
                #         local.source = 'ls'
                #         local.jpid = customer.id
                #         local.customer_name = customer.cust_name
                #         local.customer_contact_person = customer.cust_cont_person
                #         local.customer_contact_email = customer.cust_contact_email
                #         local.telephone = customer.telephone
                #         local.address = customer.addr_street
                #         local.address2 = customer.addr_street_2
                #         local.franchisee = customer.franchisee
                #         local.city = customer.addr_city
                #         local.state = customer.addr_state
                #         local.customer_number_days_service = customer. cust_num_days_service
                #         local.customer_days_service = customer.cust_days_service
                #         local.customer_regular_service_amount = customer.cust_reg_service_amt
                #         local.status = customer.account_status

                #         new_id = Docs.insert local
                #         console.log 'inserted customer', new_id


                # for franchisee in json.franchisees
                #     console.log 'franchisee id', franchisee.id
                #     console.dir franchisee
                #     found_franchisee =
                #         Docs.findOne
                #             type:'franchisee'
                #             id:franchisee.id
                #     if found_franchisee
                #         console.log 'found franchisee', franchisee.id
                #     else
                #         franchisee['type'] = 'franchisee'
                #         new_id = Docs.insert franchisee
                #         console.log 'inserted franchisee', new_id
                # for office in json.offices
                #     console.log 'office id', office.id
                #     console.dir office
                #     found_office =
                #         Docs.findOne
                #             type:'office'
                #             id:office.id
                #     if found_office
                #         console.log 'found office', office.id
                #     else
                #         office['type'] = 'office'
                #         new_id = Docs.insert office
                #         console.log 'inserted office', new_id
                # for office in json.offices
                #     console.log 'office id', office.id
                # for franchisee in json.franchisees
                #     console.log 'franchisee id', franchisee.id


    sync_ev_users: ()->
        self = @

        res = HTTP.call 'GET',"http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action",
            headers: "User-Agent": "Meteor/1.0"
            params:
                user_id:'JAN-HUB'
                password:'j@NhU8'
                statevar: 'get_users'
                # disabled: [Y|N|
                # filter: pattern
                # filter_type: "ID"
        # console.dir res.content
        split_res = res.content.split '\r\n'

        for user_string in split_res
            split_user = user_string.split '|'
            if split_user[0]
                found_user =
                    Meteor.users.findOne
                        username:split_user[0]
                if found_user
                    Meteor.call 'get_user_info', split_user[0]
                else
                    options = {}
                    options.username = split_user[0]
                    options.first_name = split_user[1]
                    options.last_name = split_user[2]
                    result = Accounts.createUser(options)
                    if result
                        Meteor.call 'get_user_info', options.username

    get_user_info: (username)->
        # users_cursor = Meteor.users.find({}).fetch()
        # for each_user in users_cursor

        user_doc = Meteor.users.findOne username:username
        # if each_user.ev.LAST_NAME
        # else
        res = HTTP.call 'GET',"http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action",
            headers: "User-Agent": "Meteor/1.0"
            params:
                user_id:'JAN-HUB'
                password:'j@NhU8'
                statevar:'get_user_info'
                login_id: username
        if res.content.includes("denied")
            throw new Meteor.Error('permission denied', "Permission denied to get user")
        else
            split_res = res.content.split '\r\n'
            console.log split_res
            save_json = {}
            for key_value_string in split_res
                split_key_value = key_value_string.split '|'
                save_json["#{split_key_value[0]}"] = split_key_value[1]
            if user_doc
                Meteor.users.update user_doc._id,
                    $set:
                        ev: save_json

            else
                # Meteor.users.insert

    get_jp_id: (jp_id)->
        res = HTTP.call 'GET',"http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action",
            headers: "User-Agent": "Meteor/1.0"
            params:
                user_id:'JAN-HUB'
                password:'j@NhU8'
                statevar:'get'
                id:jp_id
        includes_boolean = res.content.includes("does not exist")
        if includes_boolean
            throw new Meteor.Error('no user', "JP Id #{jp_id} does not exist")
        else
            xml2js.parseString res.content, {explicitArray:false, emptyTag:'', ignoreAttrs:true, trim:true}, (err, json_result)=>
                if err then console.error('errors',err)
                else
                    # json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1]
                    # console.dir json_result.PROBLEM_RECORD
                    updatedList = JSON.stringify(json_result.PROBLEM_RECORD, (key, value) ->
                        if value == undefined then '' else value
                    )
                    console.dir updatedList
                    # existing_jpid =
                    #     Docs.findOne
                    #         type: 'jpid'
                    #         jpid: jp_id
                    # if existing_jpid
                    #     Docs.update existing_jpid,
                    #         $set:
                    #             ev: json_result.PROBLEM_RECORD
                    # else
                    #     new_jpid = Docs.insert
                    #         type:'jpid'
                    #         jpid:jp_id
                    #         ev: json_result.PROBLEM_RECORD

    search_ev: (query)->
        res = HTTP.call 'GET',"http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action",
            headers:"User-Agent": "Meteor/1.0"
            params:
                user_id:'JAN-HUB'
                password:'j@NhU8'
                statevar: 'search'
                page_length: 10
                record_start: 1
                record_count: 10
                username_display: 'ID'
                area: 'Customer'
                # DATE_CREATED: "'2018-07-23'-'2018-07-30'"
                # timestamp: "'2018-07-23'-'2018-07-30'"
        # xml2js.parseString res.content, {explicitArray:false, emptyTag:'', ignoreAttrs:true, trim:true}, (err, json_result)=>
        #     if err then console.error('errors',err)
        #     else
        #         result = json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
        #         # console.dir result
        #         for doc in json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
        #             # if doc.AREA is 'Customer'
        #             # if doc.AREA in ['Franchisee','Customer']
        #             # if (doc.MASTER_LICENSEE is "Jan-Pro of Upstate New York") or (doc.AREA is 'Customer')
        #                 # doc.type = 'customer'
        #             existing_search_history_doc =
        #                 Docs.findOne
        #                     type: 'search_history_doc'
        #                     "ev.ID": doc.ID
        #             if existing_search_history_doc
        #                 # Docs.update existing_search_history_doc._id,
        #                 #     $set: ev: doc
        #             else
        #                 new_search_history_doc = Docs.insert
        #                     type:'search_history_doc'
        #                     ev: doc
        #             # else continue

    update_franchisees: () ->
        res = HTTP.call 'GET',"http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action",
            headers:"User-Agent": "Meteor/1.0"
            params:
                user_id:'JAN-HUB'
                password:'j@NhU8'
                statevar:'run_report'
                username_display:'ID'
                api_reverse_lookup:'NO'
                id:'49352'
                page_length:'10000'
                record_start:'0'
                record_count:'10000'
        # return res.content
        xml2js.parseString res.content, {explicitArray:false, emptyTag:'', ignoreAttrs:true, trim:true}, (err, json_result)=>
            if err then console.error('errors',err)
            # else
                # json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1]
                # console.dir json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1..5]
            if json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
                for ev_doc in json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
                    franch_doc = {}
                    franch_doc.type = 'franchisee'
                    franch_doc.franchisee = ev_doc.FRANCHISEE
                    franch_doc.jpid = ev_doc.ID
                    franch_doc.email = ev_doc.FRANCH_EMAIL
                    franch_doc.cell = ev_doc.TELE_CELL
                    franch_doc.home = ev_doc.TELE_HOME
                    franch_doc.office_name = ev_doc.MASTER_LICENSEE
                    franch_doc.short_name = ev_doc.SHORT_NAME
                    franch_doc.franch_name = ev_doc.FRANCH_NAME
                    franch_doc.status = ev_doc.ACCOUNT_STATUS
                    franch_doc.ev_timestamp = ev_doc.TIMESTAMP
                    franch_doc.city = ev_doc.ADDR_CITY
                    franch_doc.state = ev_doc.ADDR_STATE
                    franch_doc.country = ev_doc.MASTER_COUNTRY

                    existing_franchisee =
                        Docs.findOne
                            type: 'franchisee'
                            jpid: ev_doc.ID
                    if existing_franchisee
                        Docs.update existing_franchisee._id,
                            $set:
                                franchisee: ev_doc.FRANCHISEE
                                jpid: ev_doc.ID
                                email: ev_doc.FRANCH_EMAIL
                                cell: ev_doc.TELE_CELL
                                home: ev_doc.TELE_HOME
                                office_name: ev_doc.MASTER_LICENSEE
                                short_name: ev_doc.SHORT_NAME
                                franch_name: ev_doc.FRANCH_NAME
                                status: ev_doc.ACCOUNT_STATUS
                                ev_timestamp: ev_doc.TIMESTAMP
                                city: ev_doc.ADDR_CITY
                                state: ev_doc.ADDR_STATE
                                country: ev_doc.MASTER_COUNTRY
                        console.log 'updated franch', existing_franchisee.franchisee, existing_franchisee.jpid
                    else
                        new_franchisee_doc = Docs.insert franch_doc
                        console.log 'add franchisee', new_franchisee_doc




    sync_services: () ->
        res = HTTP.call 'GET',"http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action",
            headers:"User-Agent": "Meteor/1.0"
            params:
                user_id:'JAN-HUB'
                password:'j@NhU8'
                statevar:'run_report'
                username_display:'ID'
                api_reverse_lookup:'NO'
                id:'47857'
                page_length:'7500'
                record_start:'1'
                record_count:'7500'
        # return res.content
        xml2js.parseString res.content, {explicitArray:false, emptyTag:'', ignoreAttrs:true, trim:true}, (err, json_result)=>
            if err then console.error('errors',err)
            else
        #         # json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1]
        #         # console.dir json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1..5]
        #         # new_id = Docs.insert
            if json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
                for doc in json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
                    # doc.type = 'customer'
                    existing_service_doc =
                        Docs.findOne
                            type: 'special_service'
                            jpid: doc.ID
                    if existing_service_doc
                        Docs.update existing_service_doc._id,
                            $set:
                                ev: doc
                    else
                        new_special_service_doc = Docs.insert
                            type:'special_service'
                            jpid: doc.ID
                            ev: doc
                            customer_name: doc.CUSTOMER
                            franchisee_name: doc.FRANCHISEE

    get_ev_finance: () ->
        res = HTTP.call 'GET',"http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action",
            headers:"User-Agent": "Meteor/1.0"
            params:
                user_id:'JAN-HUB'
                password:'j@NhU8'
                statevar:'run_report'
                username_display:'ID'
                api_reverse_lookup:'NO'
                id:'49467'
                page_length:'10000'
                record_start:'10000'
                record_count:'10000'
        xml2js.parseString res.content, {explicitArray:false, emptyTag:'', ignoreAttrs:true, trim:true}, (err, json_result)=>
            if err then console.error('errors',err)
            else
                # json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1]
                console.dir json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1..5]
                # new_id = Docs.insert
            if json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
                for doc in json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
                    # doc.type = 'customer'
                    existing_finance_doc =
                        Docs.findOne "ev.BILL_QB_INVOICE": doc.BILL_QB_INVOICE
                    if existing_finance_doc
                        Docs.update existing_finance_doc._id,
                            $set:
                                ev: doc
                    else
                        new_finance_doc = Docs.insert
                            type:'finance'
                            ev: doc

    update_offices: () ->
        res = HTTP.call 'GET',"http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action",
            headers:"User-Agent": "Meteor/1.0"
            params:
                user_id:'JAN-HUB'
                password:'j@NhU8'
                statevar:'run_report'
                username_display:'ID'
                api_reverse_lookup:'NO'
                id:'48307'
                page_length:'250'
                record_start:'1'
                record_count:'250'
        # return res.content
        xml2js.parseString res.content, {explicitArray:false, emptyTag:'', ignoreAttrs:true, trim:true}, (err, json_result)=>
            if err then console.error('errors',err)
            else
        #         # json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1]
        #         # console.dir json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1..5]
        #         # new_id = Docs.insert
            if json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
                for doc in json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
                    # doc.type = 'customer'
                    existing_office_doc =
                        Docs.findOne
                            type: 'office'
                            "ev.ID": doc.ID
                    if existing_office_doc
                        Docs.update existing_office_doc._id,
                            $set:
                                ev: doc
                                state: doc.ADDR_STATE
                                city: doc.ADDR_CITY
                                office_name: doc.MASTER_LICENSEE
                    else
                        new_office_doc = Docs.insert
                            type:'office'
                            ev: doc
                            state: doc.ADDR_STATE
                            city: doc.ADDR_CITY
                            office_name: doc.MASTER_LICENSEE

    update_customers: () ->
        res = HTTP.call 'GET',"http://ext-jan-pro.extraview.net/jan-pro/ExtraView/ev_api.action",
            headers:"User-Agent": "Meteor/1.0"
            params:
                user_id:'JAN-HUB'
                password:'j@NhU8'
                statevar:'run_report'
                username_display:'ID'
                api_reverse_lookup:'NO'
                id:'49072'
                page_length:'10000'
                record_start:'1'
                record_count:'10000'
        # return res.content
        xml2js.parseString res.content, {explicitArray:false, emptyTag:'', ignoreAttrs:true, trim:true}, (err, json_result)=>
            if err then console.error('errors',err)
            else
                # json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1]
                # console.dir json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1..5]
                # new_id = Docs.insert
            if json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
                for doc in json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
                    # doc.type = 'customer'
                    existing_customer_doc =
                        Docs.findOne
                            type: 'customer'
                            "ev.CUST_NAME": doc.CUST_NAME
                    if existing_customer_doc
                        console.log 'existing',existing_customer_doc._id
                        Docs.update existing_customer_doc._id,
                            $set: ev: doc
                    unless existing_customer_doc
                        console.log 'new customer'
                        new_customer_doc = Docs.insert
                            type: 'customer'
                            ev: doc