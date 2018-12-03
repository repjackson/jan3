Meteor.methods
    franch: ->
        Docs.update({type:'franchisee'},
            {$rename:
                "ev.FRANCH_EMAIL":"email"
                "ev.TELE_CELL":"cell"
                "ev.ID":'franchisee_jpid'
                "ev.MASTER_LICENSEE":'office_name'
                "ev.TELE_HOME":"home_phone"
                "ev.FRANCH_NAME":"franch_name"
                "ev.FRANCHISEE":"franchisee_name"
                "ev.SHORT_NAME":"short_name"
                "ev.ACCOUNT_STATUS":"status"
            },
            {multi:true}
        )

    ss: ->
        Docs.update({type:'special_service'},
            {$rename:
                "ev.CUSTOMER": "customer_name"
                "ev.DUE_DATE": "due_date"
                "ev.CUST_OPS_MANAGER": "customer_operations_manager"
                "ev.FRANCHISEE": "franchisee_name"
                "ev.SERV_TYPE": "service_type"
                "ev.EXTRA_SERV_DESC": "extra_services_description"
                "ev.DATE_CREATED": "date_created"
                "ev.EXTRA_PRICE": "extra_price"
                "ev.FRANCH_NAME": "franch_name"
                "ev.ID": "jpid"
            },
            {multi:true}
        )


    update_office_jpid: ->
        Docs.update({type:'office'},
            {$rename:
                "ev.ID":'office_jpid'
            },
            {multi:true}
        )

    update_customer_jpid: ->
        Docs.update({type:'customer'},
            {$rename:
                "ev.ID":"customer_jpid"
            },
            {multi:true}
        )

    customer: ->
        Docs.update({type:'customer'},
            {$rename:
                "ev.MASTER_LICENSEE":"office_name"
                "ev.CUST_NAME":"customer_name"
                "ev.CUST_CONT_PERSON":"customer_contact_person"
                "ev.CUST_CONTACT_EMAIL":"customer_contact_email"
                "ev.ACCOUNT_STATUS":"status"
                "ev.TELEPHONE": "phone"
                "ev.ADDR_STREET": "address"
                "ev.ADDR_STREET_2": "address_2"
                "ev.FRANCHISEE": "franchisee_name"
                "ev.ADDR_CITY": "city"
                "ev.ADDR_STATE": "state"
                "ev.CUST_NUM_DAYS_SERVICE": "customer_number_days_service"
                "ev.CUST_DAYS_SERVICE": "customer_days_service"
                "ev.CUST_REG_SERVICE_AMT": "customer_regular_service_amount"
            },
            {multi:true}
        )


    customer: ->
        Docs.update({type:'customer'},
            {$rename:
                "ev.MASTER_LICENSEE":"office_name"
                "ev.CUST_NAME":"customer_name"
                "ev.CUST_CONT_PERSON":"customer_contact_person"
                "ev.CUST_CONTACT_EMAIL":"customer_contact_email"
                "ev.ACCOUNT_STATUS":"status"
                "ev.TELEPHONE": "phone"
                "ev.ADDR_STREET": "address"
                "ev.ADDR_STREET_2": "address_2"
                "ev.FRANCHISEE": "franchisee_name"
                "ev.ADDR_CITY": "city"
                "ev.ADDR_STATE": "state"
                "ev.CUST_NUM_DAYS_SERVICE": "customer_number_days_service"
                "ev.CUST_DAYS_SERVICE": "customer_days_service"
                "ev.CUST_REG_SERVICE_AMT": "customer_regular_service_amount"
            },
            {multi:true}
        )

    finance: ->
        Docs.update({type:'finance'},
            {$rename:
                "ev.MASTER_LICENSEE": 'office_name'
                "ev.CUSTOMER": 'customer_name'
                "ev.BILL_QB_INVOICE": 'invoice'
                "ev.BILL_QB_INVOICE_DATE": 'invoice_date'
                "ev.BILL_QB_TOTAL": 'total'
                "ev.BILL_BALANCE": 'balance'
                "ev.BILL_QB_RS_AMOUNT": 'rs_amount'
                "ev.BILL_QB_SPECIALS": 'specials'
                "ev.SUP_TOT_TAX": 'total_tax'
            },
            {multi:true}
        )





    office: ->
        Docs.update(
            {type:'office'},
            {$rename: {
                "ev.MASTER_LICENSEE": "office_name"
                "ev.TIMESTAMP": "ev_timestamp"
                "ev.LAST_CHANGE_USER": "last_change_user"
                "ev.DATE_CREATED": "date_created"
                "ev.ORIGINATOR": "originator"
                "ev.MASTER_COUNTRY": "country"
                "ev.MASTER_OFFICENAME": "office_name2"
                "ev.TELEPHONE": "phone"
                "ev.ADDR_STREET": "address"
                "ev.ADDR_STREET_2": "address_2"
                "ev.ADDR_CITY": "city"
                "ev.ADDR_STATE": "state"
                "ev.ADDR_POSTAL_CODE": "zipcode"
                "ev.MASTER_OFFICE_MANAGER": "office_manager"
                "ev.MASTER_OFFICE_OWNER": "office_owner"
            }},{multi:true})

    rename_ls: ->
        console.log 'renaming ls'
        result = Docs.update(
            {
                type:'customer',
                master_licensee:{$exists:true}
            },
            {$rename:
                master_licensee: 'office_name'
                # master_id: '78'
                id: 'jpid'
                cust_name: 'customer_name'
                cust_cont_person: 'customer_contact_person'
                cust_contact_email: 'customer_contact_email'
                # telephone: '6625347871'
                addr_street: 'address'
                addr_street_2: 'address_2'
                franchisee: 'franchisee_name'
                addr_city: 'city'
                addr_state: 'state'
                cust_num_days_service: 'customer_number_days_service'
                cust_days_service: 'customer_days_service'
                cust_regc_service_amt: 'customer_regular_service_amount'
                account_status: 'status'
            },
            {multi:true}
        )
        console.log 'result', result

    raw_count: ->
        raw = Docs.rawCollection()
            # .distinct('author_id')
        dis = Meteor.wrapAsync raw.distinct, raw
        count = dis 'author_id'
        console.log count
        
        
    keys: ->
        start = Date.now()
        console.log 'starting keys'
        cursor = Docs.find({keys:$exists:false}, {limit:1000}).fetch()
        for doc in cursor
            keys = _.keys doc
            # console.log doc
            Docs.update doc._id,
                $set:keys:keys
            
            console.log "updated keys for doc #{doc._id}"
        stop = Date.now()
        
        diff = stop - start
        # console.log diff
        console.log moment(diff).format("HH:mm:ss:SS")