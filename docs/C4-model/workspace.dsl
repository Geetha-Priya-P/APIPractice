workspace "eMaint Cmms" "Computerized maintenance management system" {
    model {
        properties {
            "structurizr.groupSeparator" "~"
        }

        !include ./diagrams/external-systems.dsl

        tenantUser = person "Tenant User" "Standard User"

        group "eMaint X5 system boundary" {
            requestUser = person "Requester User" "Limited User"
            adminUser = person "System Admin User" "Super User"

            x5System = softwareSystem "eMaint X5 (CMMS System)" "Maintenance software for workorder, inventory, asset and team management" "eMaint" {
                frontendContainer = container "X5 Primary UI Application" "UI/QueryBuilder" "React/Typescript application" "JS,WebBrowser" {
                    webapp = component "Web Application" "" "React/Typescript application" "JS,WebBrowser"
                    adminApp = component "Administration Application" "" "React/Typescript application" "JS,WebBrowser"
                    requesterApp = component "Requester Application" "" "React/Typescript application" "JS,WebBrowser"
                }

                nginxContainer = container "Nginx Reverse Proxy" "Injects Http Header, like 'Content-Security-Policy'" "Nginx" "Nginx"

                apiContainer = container "X5.Api" "Primary Backend Api" "IHost" "Api" {
                    passwordChangeControllerComponent = component "Password Change Controller" "X5.Admin.WebApi.Controllers.PasswordChangeController" "Controller"
                    tenantSessionControllerComponent = component "Tenant Session Controller" "X5.Shared.WebApi.Controllers.TenantSessionController" "Controller"
                    recordsControllerComponent = component "Records Controller" "X5.Cmms.WebApi.Controllers.RecordsController" "Controller"
                    lapRedirectionControllerComponent = component "LAP Controller" "X5.Cmms.WebApi.Controllers.LapRedirectionController" "Controller"
                    lapJwtControllerComponent = component "LAP JWT Security Controller" "X5.Cmms.WebApi.Controllers.LapSecurityController" "Controller"
                }

                devExpressApiContainer = container "X5.DevExpress.Api" "Manages Dashboard v2 Interactions" "IHost" "Api"

                rabbitContainer = container "Messaging Queue" "Rabbit Queues" "RabbitMQ" "RabbitMQ"
                sqsQueue = container "AWS Simple Queue Service" "Receiving emails into X5" "AWS SQS" "AwsSqs"
                sqlContainer = container "X5 Datastore" "Keeps all the data for whole X5 system" "MSSQLServer" "SQLServer"
                s3BucketContainer = container "AWS S3 Bucket" "Keeps all file and image resource for whole X5 system" "" "ExternalSystem,AwsS3Bucket"

                group "X5 Core Services" {
                    adminContainer = container "Admin Service" "X5.Admin.Service" "BackgroundService" "Service" {
                        passwordResetHandlerComponent = component "Tenant Password Reset Request Handler" "X5.Admin.Handlers.TenantPasswordResetRequestHandler"
                    }
                    cmmsContainer = container "Cmms Service" "X5.Cmms.Service" "BackgroundService" "Service"
                    dataImportContainer = container "Data Import Service" "X5.DataImport.Service" "BackgroundService" "Service"              
                    emailContainer = container "Email Service" "X5.Email.Service" "BackgroundService" "Service" {
                        sendEmailHandlerComponent = component "Send Email Handler" "X5.Email.Handlers.SendEmailHandler"
                    }
                    flukeContainer = container "Fluke Service" "X5.Fluke.Service" "BackgroundService" "Service"
                    integrationsContainer = container "Integrations Push Service" "X5.Integration.Push.Service" "BackgroundService" "Service"
                    inventoryContainer = container "Inventory Service" "X5.Inventory.Service" "BackgroundService" "Service"
                    liveAssetEventsContainer = container "Live Asset Events Service" "X5.LiveAssetsEvents.Service" "BackgroundService" "Service"
                    microServicesConnectorContainer = container "Microservices Contector Service" "X5.Microservices.Service" "BackgroundService" "Service"
                    schedulingContainer = container "Scheduling Service" "X5.Scheduling.Service" "BackgroundService" "Service"
                    workflowsContainer = container "Workflows Service" "X5.Workflows.Service" "BackgroundService" "Service"
                }

                group "X5 Micro services" {
                    domainEventsContainer = container "Audit Trail Service" "X5.DomainEvents.Service" "BackgroundService" "Service" {
                        serviceComponent = component "Domain Events Service" "Handle Domain Events Service" "IService"
                    }
                    preventiveMaintainanceContainer = container "Preventive Maintainance Service" "X5.PreventiveMaintainance.Service" "BackgroundService" "Service"
                    relatedRecordsContainer = container "Related Records Service" "X5.RelatedRecords.Service" "BackgroundService" "Service"
                    rimeRankingContainer = container "Rime Ranking Service" "X5.RimeRanking.Service" "BackgroundService" "Service"
                    schedulerContainer = container "Scheduler Service" "X5.Scheduler.Service" "BackgroundService" "Service"
                    translatorInContainer = container "Message Translation In Service" "X5.Translator.In.Service" "BackgroundService" "Service"
                    translatorOutContainer = container "Message Translation Out Service" "X5.Translator.Out.Service" "BackgroundService" "Service"
                    trendingMetersContainer = container "Trending Meter Service" "X5.TrendingMeters.Service" "BackgroundService" "Service"
                    workOrderCreationContainer = container "Work Order Creation Service" "X5.WorkOrderCreation.Service" "BackgroundService" "Service"
                }
                dynamoDbContainer = container "DyanamoDB Audit Trail Datastore" "Keeps all the Audit trail data" "DynamoDb" "DynamoDb"
                mongoDbContainer = container "MongoDb Scheduled WorkOrders" "Stores Scheduled Work Orders" "MongoDb" "MongoDb"

                group "X5 to LAP navigation integration" {
                    frontendContainer -> lapRedirectionControllerComponent "Redirection after CLICK on LAP url"
                    lapRedirectionControllerComponent -> lapJwtControllerComponent "Acquire token for a given user ID"
                    lapJwtControllerComponent -> lapRedirectionControllerComponent "Return bearer token with the user ID included"                    
                    lapRedirectionControllerComponent -> liveAssetsSystem "Redirection with the acquired bearer token (ideally in the http headers but eventually can be in an url query parameters)"
                }

            }
        }

        # relationships between controllers and container/components
        nginxContainer -> passwordChangeControllerComponent "Forward"
        nginxContainer -> recordsControllerComponent "Forward"
        passwordChangeControllerComponent -> sqlContainer "Read"        
        passwordChangeControllerComponent -> rabbitContainer "Publish" 
        recordsControllerComponent -> rabbitContainer "Publish & Subscribe"

        # relationships between people and systems
        adminUser -> frontendContainer "Uses"
        tenantUser -> frontendContainer "Uses"
        requestUser -> frontendContainer "Uses"
        sesSystem -> tenantUser "Sends email to"

        # relationships between X5 Core services containers and RabbitMQ
        apiContainer -> rabbitContainer "Publish"

        # relationships between X5 Core services containers and SQS
        tenantUser -> sesSystem "Sends an email"
        sesSystem -> sqsQueue "Publish"

        # relationships between X5 core services and Sql datastore
        apiContainer -> sqlContainer "Read"

        # relationships between nginxContainer component and BE API, DevExpress containers
        nginxContainer -> apiContainer "Forward" "JSON/HTTPS"
        nginxContainer -> devExpressApiContainer "Forward" "JSON/HTTPS"      
                        
        # relationships between web applications and nginxContainer reverse reverseProxyComponent components
        webapp -> nginxContainer "Request" "JSON/HTTPS"
        adminApp -> nginxContainer "Request" "JSON/HTTPS"
        requesterApp -> nginxContainer "Request" "JSON/HTTPS"
        
        # relationships between x5 system and external systems
        x5system -> slackNotificationSystem "Notifies"
        x5system -> notificationSystem2 "Notifies"
        x5system -> notificationSystem3 "Notifies"
        x5system -> flukeConnectSystem "Fetches Assets & Pushes Open Workorders"
        x5System -> sesSystem "Send"

        # relationships between components
        adminUser -> adminApp "Uses"
        tenantUser -> webapp "Uses"
        requestUser -> requesterApp "Uses"
        
        # notifications
        integrationsContainer -> slackNotificationSystem "Pushes notifications"
        integrationsContainer -> notificationSystem2 "Pushes notifications"
        integrationsContainer -> notificationSystem3 "Pushes notifications"

        # relationships between X5 Core services containers and RabbitMQ
        adminContainer -> rabbitContainer "Publish & Subscribe"
        emailContainer -> rabbitContainer "Publish & Subscribe"
        cmmsContainer -> rabbitContainer "Publish & Subscribe"
        schedulingContainer -> rabbitContainer "Publish"
        dataImportContainer -> rabbitContainer "Publish & Subscribe"
        flukeContainer -> rabbitContainer "Subscribe"
        integrationsContainer -> rabbitContainer "Subscribe"
        inventoryContainer -> rabbitContainer "Publish & Subscribe"
        liveAssetEventsContainer -> rabbitContainer "Publish"
        microServicesConnectorContainer -> rabbitContainer "Publish & Subscribe"
        workflowsContainer -> rabbitContainer "Publish & Subscribe"

        # relationships between X5 Core services containers and S3 Bucket
        adminContainer -> s3BucketContainer "Deletes or Copies a new resources"
        cmmsContainer -> s3BucketContainer "Moves Blobs"

        # relationships between X5 Core services containers and SQS
        emailContainer -> sqsQueue "Pull (polling)"

        # flukeConnectSystem
        flukeContainer -> flukeConnectSystem "Fetch assets & Pushes Open Workorders"

        # relationships between X5 core services and Sql datastore
        adminContainer -> sqlContainer "Read & Write"
        emailContainer -> sqlContainer "Read"
        dataImportContainer -> sqlContainer "Read & Write"
        cmmsContainer -> sqlContainer "Read & Write"
        flukeContainer -> sqlContainer "Read"
        integrationsContainer -> sqlContainer "Read"
        inventoryContainer -> sqlContainer "Read & Write"
        liveAssetEventsContainer -> sqlContainer "Read & Write"
        microServicesConnectorContainer -> sqlContainer "Read"
        workflowsContainer -> sqlContainer "Read & Write"

        # relationships between X5 core services and external Amazon emailContainer services      
        emailContainer -> sesSystem "Send"   

        # Password reset container
        # TODO: take this out into a component level and keep only container level here
        nginxContainer -> passwordChangeControllerComponent "Forward"
        passwordChangeControllerComponent -> sqlContainer "Read"        
        passwordChangeControllerComponent -> rabbitContainer "Publish"
        passwordResetHandlerComponent -> rabbitContainer "Subscribe"
        passwordResetHandlerComponent -> rabbitContainer "Publish"
        passwordResetHandlerComponent -> sqlContainer "Read & Write"
        sendEmailHandlerComponent -> rabbitContainer "Subscribe"        
        sendEmailHandlerComponent -> sesSystem "Send"
        sendEmailHandlerComponent -> sqlContainer "Read"
        recordsControllerComponent -> sqlContainer "Read"

        # MICROSERVICES

        domainEventsContainer -> rabbitContainer "Publish & Subscribe"
        domainEventsContainer -> sqlContainer "Read"
        serviceComponent -> rabbitContainer
        serviceComponent -> sqlContainer
        serviceComponent -> dynamoDbContainer
        schedulerContainer -> mongoDbContainer
        schedulerContainer -> rabbitContainer "Publish & Subscribe"
        preventiveMaintainanceContainer -> rabbitContainer "Publish & Subscribe"
        preventiveMaintainanceContainer -> sqlContainer "Read"
        preventiveMaintainanceContainer -> microServicesConnectorContainer "Read"
        relatedRecordsContainer -> rabbitContainer "Publish & Subscribe"
        relatedRecordsContainer -> sqlContainer "Read & Write"
        rimeRankingContainer -> rabbitContainer "Publish & Subscribe"
        rimeRankingContainer -> sqlContainer "Read"        
        rimeRankingContainer -> microServicesConnectorContainer "Read"
        translatorInContainer -> rabbitContainer "Publish & Subscribe"
        translatorOutContainer -> rabbitContainer "Publish & Subscribe"
        trendingMetersContainer -> rabbitContainer "Publish & Subscribe"
        trendingMetersContainer -> sqlContainer "Read"
        workOrderCreationContainer -> rabbitContainer "Publish & Subscribe"
        workOrderCreationContainer -> sqlContainer "Read & Write"         
        workOrderCreationContainer -> microServicesConnectorContainer "Read"

        # END MICROSERVICES

        # TODO:
        # take out into a separated file:
            # main that include two systems so x5system and other top level system
            # extend x5 system from the FRS workspace
        # TODO: present it to Cris and confirm it looks nice

        group "Fluke Reliability Systems (FRS)" {
            liveAssetsSystem -> x5System
            flukeMobileSystem -> x5System
            x5System -> flukeMobileSystem
            # TODO: ADP something something system maybe? Ask Cris.
        }

        deploymentEnvironment "Dev Environment" {
            deploymentNode "EU-WEST-1" "" "Microsoft Windows 10 or Apple macOS" {
                #deploymentNode "Web Browser" "" "Chrome, Firefox, Safari, or Edge" {
                #    devSinglePageApplicationInstance = containerInstance web
                #}
                deploymentNode "Docker Container - Web Server" "" "Docker" {
                    deploymentNode "Nginx" "" "Nginx 1.21.4" {
                        devWebApplicationInstance = containerInstance frontendContainer
                    }
                }
                deploymentNode "Database Server" "" "EC2" {
                    deploymentNode "Database Server" "" "MS Sql 2019" {
                        devDatabaseInstance = containerInstance sqlContainer
                    }
                }
                deploymentNode "RabbitMQ Server" "" "AmazonMQ" {
                    deploymentNode "RabbitMQ Server" "" "MS Sql 2019" {
                        devRabbitInstance = containerInstance rabbitContainer
                    }
                }
                deploymentNode "Api Backend" "" "EC2" {
                    deploymentNode "Api Backend" "" "Fargate" {
                        devApiInstance = containerInstance apiContainer
                    }
                }
                // deploymentNode "Docker Container - Admin Service" "" "Fargate" {
                //     deploymentNode "Admin Service" "" "Fargate" {
                //         devAdminInstance = containerInstance emailContainer
                //     }
                // }
                // deploymentNode "Docker Container - Email Service" "" "Fargate" {
                //     deploymentNode "Email Service" "" "Fargate" {
                //         devEmailInstance = containerInstance emailContainer
                //     }
                //}                                                           
            }
            deploymentNode "eMaint X5" "" "eMaint CMMS System" "" {
                deploymentNode "cmms-dev001" "" "" "" {
                    softwareSystemInstance x5System
                }
            }
        }
    }
    
    views "X5 Big Picture" {
        properties {
            "structurizr.softwareSystemBoundaries" "true"
        }
        systemLandscape "cmss" "eMaint" {
            title "[Landscape] eMaint X5 (CMMS System) systems"
            include *
        }

        systemLandscape "FRS" "Fluke Reliability" {
            title "[Landscape] Fluke Reliability systems"
            include x5System flukeConnectSystem flukeMobileSystem liveAssetsSystem
        }

        container x5System "x5Containers" "X5 containers" {
            include *
        }

        deployment x5System "Dev Environment" "DevelopmentDeployment" {
            include *
            animation {
                devWebApplicationInstance
                devWebApplicationInstance devApiInstance
                devDatabaseInstance devRabbitInstance
            }
            #autoLayout
        }

        !include ./diagrams/workflows/audit-trial.dsl
        !include ./diagrams/workflows/password-reset.dsl
        !include ./diagrams/workflows/lap-navigation-integration.dsl

        theme https://static.structurizr.com/themes/amazon-web-services-2020.04.30/theme.json
        theme default
        theme http://127.0.0.1:8070/assets/theme.json
    }
}