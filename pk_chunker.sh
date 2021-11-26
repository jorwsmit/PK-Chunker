#!/bin/bash

echo 'Enter your session Id'
read sessionId
echo 'Enter your org domain (examples: kah--qa, kah, kah--hhdev, kah2)'
read org

user_query='user-query.txt'
account_query='account-query.txt'
contact_query='contact-query.txt'
event_query='event-query.txt'
salescall_query='salescall-query.txt'

if [ $org == 'kah2' ]; then
user_query='user-query2.txt'
account_query='account-query2.txt'
contact_query='contact-query2.txt'
event_query='event-query2.txt'
salescall_query='salescall-query2.txt'
fi



# user job
xml=$(curl -H "X-SFDC-Session: $sessionId" -H "Content-Type: application/xml; charset=UTF-8" -H "Sforce-Enable-PKChunking: chunkSize=250000" -d @create-user-job.xml https://$org.my.salesforce.com/services/async/53.0/job)
jobId_user=$(sed -ne '/id/{s/.*<id>\(.*\)<\/id>.*/\1/p;q;}' <<< "$xml")
curl -d @$user_query -H "X-SFDC-Session: $sessionId" -H "Content-Type: text/csv; charset=UTF-8" https://$org.my.salesforce.com/services/async/53.0/job/$jobId_user/batch

# account job
xml=$(curl -H "X-SFDC-Session: $sessionId" -H "Content-Type: application/xml; charset=UTF-8" -H "Sforce-Enable-PKChunking: chunkSize=250000" -d @create-account-job.xml https://$org.my.salesforce.com/services/async/53.0/job)
jobId_account=$(sed -ne '/id/{s/.*<id>\(.*\)<\/id>.*/\1/p;q;}' <<< "$xml")
curl -d @$account_query -H "X-SFDC-Session: $sessionId" -H "Content-Type: text/csv; charset=UTF-8" https://$org.my.salesforce.com/services/async/53.0/job/$jobId_account/batch

# contact job
xml=$(curl -H "X-SFDC-Session: $sessionId" -H "Content-Type: application/xml; charset=UTF-8" -H "Sforce-Enable-PKChunking: chunkSize=250000" -d @create-contact-job.xml https://$org.my.salesforce.com/services/async/53.0/job)
jobId_contact=$(sed -ne '/id/{s/.*<id>\(.*\)<\/id>.*/\1/p;q;}' <<< "$xml")
curl -d @$contact_query -H "X-SFDC-Session: $sessionId" -H "Content-Type: text/csv; charset=UTF-8" https://$org.my.salesforce.com/services/async/53.0/job/$jobId_contact/batch

# event job
xml=$(curl -H "X-SFDC-Session: $sessionId" -H "Content-Type: application/xml; charset=UTF-8" -H "Sforce-Enable-PKChunking: chunkSize=250000" -d @create-event-job.xml https://$org.my.salesforce.com/services/async/53.0/job)
jobId_event=$(sed -ne '/id/{s/.*<id>\(.*\)<\/id>.*/\1/p;q;}' <<< "$xml")
curl -d @$event_query -H "X-SFDC-Session: $sessionId" -H "Content-Type: text/csv; charset=UTF-8" https://$org.my.salesforce.com/services/async/53.0/job/$jobId_event/batch

# sales call job
xml=$(curl -H "X-SFDC-Session: $sessionId" -H "Content-Type: application/xml; charset=UTF-8" -H "Sforce-Enable-PKChunking: chunkSize=250000" -d @create-salescall-job.xml https://$org.my.salesforce.com/services/async/53.0/job)
jobId_salescall=$(sed -ne '/id/{s/.*<id>\(.*\)<\/id>.*/\1/p;q;}' <<< "$xml")
curl -d @$salescall_query -H "X-SFDC-Session: $sessionId" -H "Content-Type: text/csv; charset=UTF-8" https://$org.my.salesforce.com/services/async/53.0/job/$jobId_salescall/batch

userComplete=false
accountComplete=false
contactComplete=false
eventComplete=false
salescallComplete=false

# while [ $allComplete == false ]
while [ $userComplete == false ] || [ $accountComplete == false ] || [ $contactComplete == false ] || [ $eventComplete == false ] || [ $salescallComplete == false ]
do
    # check user
    if [ $userComplete == false ]; then
        xml=$(curl -H "X-SFDC-Session: $sessionId" https://$org.my.salesforce.com/services/async/53.0/job/$jobId_user/)
        jobState_user=$(sed -ne '/state/{s/.*<state>\(.*\)<\/state>.*/\1/p;q;}' <<< "$xml")
        numberBatchesTotal_user=$(sed -ne '/numberBatchesTotal/{s/.*<numberBatchesTotal>\(.*\)<\/numberBatchesTotal>.*/\1/p;q;}' <<< "$xml")
        numberBatchesCompleted_user=$(sed -ne '/numberBatchesCompleted/{s/.*<numberBatchesCompleted>\(.*\)<\/numberBatchesCompleted>.*/\1/p;q;}' <<< "$xml")
        if [ $numberBatchesTotal_user == $numberBatchesCompleted_user ] && [ $jobState_user != 'Queued' ]; then 
            userComplete=true
            echo 'Closing user job.'
            curl -H "X-SFDC-Session: $sessionId" -H "Content-Type: text/csv; charset=UTF-8" -d @close-job.xml https://$org.my.salesforce.com/services/async/53.0/job/$jobId_user
        fi
    fi

    # check account
    if [ $accountComplete == false ]; then
        xml=$(curl -H "X-SFDC-Session: $sessionId" https://$org.my.salesforce.com/services/async/53.0/job/$jobId_account/)
        jobState_account=$(sed -ne '/state/{s/.*<state>\(.*\)<\/state>.*/\1/p;q;}' <<< "$xml")
        numberBatchesTotal_account=$(sed -ne '/numberBatchesTotal/{s/.*<numberBatchesTotal>\(.*\)<\/numberBatchesTotal>.*/\1/p;q;}' <<< "$xml")
        numberBatchesCompleted_account=$(sed -ne '/numberBatchesCompleted/{s/.*<numberBatchesCompleted>\(.*\)<\/numberBatchesCompleted>.*/\1/p;q;}' <<< "$xml")
        echo $numberBatchesTotal_account
        echo $numberBatchesCompleted_account
        echo $jobState_account
        if [ $numberBatchesTotal_account == $numberBatchesCompleted_account ] && [ $jobState_account != 'Queued' ]; then 
            accountComplete=true
            echo 'Closing account job.'
            curl -H "X-SFDC-Session: $sessionId" -H "Content-Type: text/csv; charset=UTF-8" -d @close-job.xml https://$org.my.salesforce.com/services/async/53.0/job/$jobId_account
        fi
    fi

    # check contact
    if [ $contactComplete == false ]; then
        xml=$(curl -H "X-SFDC-Session: $sessionId" https://$org.my.salesforce.com/services/async/53.0/job/$jobId_contact/)
        jobState_contact=$(sed -ne '/state/{s/.*<state>\(.*\)<\/state>.*/\1/p;q;}' <<< "$xml")
        numberBatchesTotal_contact=$(sed -ne '/numberBatchesTotal/{s/.*<numberBatchesTotal>\(.*\)<\/numberBatchesTotal>.*/\1/p;q;}' <<< "$xml")
        numberBatchesCompleted_contact=$(sed -ne '/numberBatchesCompleted/{s/.*<numberBatchesCompleted>\(.*\)<\/numberBatchesCompleted>.*/\1/p;q;}' <<< "$xml")
        echo $numberBatchesTotal_contact
        echo $numberBatchesCompleted_contact
        echo $jobState_contact
        if [ $numberBatchesTotal_contact == $numberBatchesCompleted_contact ] && [ $jobState_contact != 'Queued' ]; then 
            contactComplete=true
            echo 'Closing contact job.'
            curl -H "X-SFDC-Session: $sessionId" -H "Content-Type: text/csv; charset=UTF-8" -d @close-job.xml https://$org.my.salesforce.com/services/async/53.0/job/$jobId_contact
        fi
    fi

    # check event
    if [ $eventComplete == false ]; then
        xml=$(curl -H "X-SFDC-Session: $sessionId" https://$org.my.salesforce.com/services/async/53.0/job/$jobId_event/)
        jobState_event=$(sed -ne '/state/{s/.*<state>\(.*\)<\/state>.*/\1/p;q;}' <<< "$xml")
        numberBatchesTotal_event=$(sed -ne '/numberBatchesTotal/{s/.*<numberBatchesTotal>\(.*\)<\/numberBatchesTotal>.*/\1/p;q;}' <<< "$xml")
        numberBatchesCompleted_event=$(sed -ne '/numberBatchesCompleted/{s/.*<numberBatchesCompleted>\(.*\)<\/numberBatchesCompleted>.*/\1/p;q;}' <<< "$xml")
        echo $numberBatchesTotal_event
        echo $numberBatchesCompleted_event
        echo $jobState_event
        if [ $numberBatchesTotal_event == $numberBatchesCompleted_event ] && [ $jobState_event != 'Queued' ]; then 
            eventComplete=true
            echo 'Closing event job.'
            curl -H "X-SFDC-Session: $sessionId" -H "Content-Type: text/csv; charset=UTF-8" -d @close-job.xml https://$org.my.salesforce.com/services/async/53.0/job/$jobId_event
        fi
    fi

    # check salescall
    if [ $salescallComplete == false ]; then
        xml=$(curl -H "X-SFDC-Session: $sessionId" https://$org.my.salesforce.com/services/async/53.0/job/$jobId_salescall/)
        jobState_salescall=$(sed -ne '/state/{s/.*<state>\(.*\)<\/state>.*/\1/p;q;}' <<< "$xml")
        numberBatchesTotal_salescall=$(sed -ne '/numberBatchesTotal/{s/.*<numberBatchesTotal>\(.*\)<\/numberBatchesTotal>.*/\1/p;q;}' <<< "$xml")
        numberBatchesCompleted_salescall=$(sed -ne '/numberBatchesCompleted/{s/.*<numberBatchesCompleted>\(.*\)<\/numberBatchesCompleted>.*/\1/p;q;}' <<< "$xml")
        echo $numberBatchesTotal_salescall
        echo $numberBatchesCompleted_salescall
        echo $jobState_salescall
        if [ $numberBatchesTotal_salescall == $numberBatchesCompleted_salescall ] && [ $jobState_salescall != 'Queued' ]; then 
            salescallComplete=true
            echo 'Closing salescall job.'
            curl -H "X-SFDC-Session: $sessionId" -H "Content-Type: text/csv; charset=UTF-8" -d @close-job.xml https://$org.my.salesforce.com/services/async/53.0/job/$jobId_salescall
        fi
    fi
    sleep 5
done