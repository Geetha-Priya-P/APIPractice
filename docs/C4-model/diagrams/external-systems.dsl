sesSystem = softwareSystem "AWS Simple Email Service" "Sends and Receives emails in X5" "AwsSes,ExternalSystem"

flukeConnectSystem = softwareSystem "Fluke Connect" "Integrated asset data and optimizing maintenance workflows, utilizing device across the enterprise" "ExternalSystem,FlukeConnect"
flukeMobileSystem = softwareSystem "Fluke Mobile" "Fluke Mobile allows you to manage work orders and work requests, book spare parts, track work hours, and much more" "ExternalSystem,FlukeMobile"
liveAssetsSystem = softwareSystem "eMaint Condition Monitoring" "Infrared, vibration, temperatur, power-quality, SCADA/PLC with management software" "ExternalSystem,FlukeLiveAssets"

# TODO: clartify this with Mikey what are those systems about
slackNotificationSystem = softwareSystem "Slack" "Team Communication" "ExternalSystem,Slack"
notificationSystem2 = softwareSystem "HTTP notification system" "" "ExternalSystem"
notificationSystem3 = softwareSystem "OAuth notification system" "" "ExternalSystem"

#TODO: could you please find out if we have "push" (webhooks) APIs used by customers ? (I think we use them for FM) but I'm not 100% sure


