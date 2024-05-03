dynamic apiContainer "AuditTrail" "Audit Trail Workflow" {
    webapp -> nginxContainer "Get Audit Trail request"
    nginxContainer -> recordsControllerComponent "Get Audit Trail request"
    recordsControllerComponent -> sqlContainer "Read record"
    recordsControllerComponent -> rabbitContainer "Publish Audit trail request"
    serviceComponent -> rabbitContainer "Handle DomainEventsRequest Message"
    serviceComponent -> sqlContainer "Read Tenant"


    serviceComponent -> dynamoDbContainer "Read Audit Trail Events"
    serviceComponent -> sqlContainer "Read Audit Trail Events"
    serviceComponent -> rabbitContainer "Publish Audit Trail Responce Message on Temp Queue"
    rabbitContainer -> recordsControllerComponent "Receive Audit trail message Event"
    recordsControllerComponent -> nginxContainer "Rerturn Audit Trail"
    nginxContainer -> webapp "Return Audit Trail"    
}