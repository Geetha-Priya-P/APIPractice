
## FSG November Hackathon
### Abstract
This document describes the goals of the hackathon as well as the solution design implemented to accomplish the goals.

### Hackathon Goals
Extend integration capabilities between X5 and FlukeConnect

### Scenarios

1. Assets created in FlukeConnect can be imported from X5
2. An alarm is triggered in FlukeConnect -> A work order is created in X5
3. A PM triggers creating a work order -> The work order can be found in FlukeConnect mobile app
4. A work order is closed in FlukeConnect -> X5 closes the work order if exists
5. Display live data from a Mystique sensor associated to an asset

### POC Implementation

#### Credentials
X5 stores a FlukeConnect user name and password that is used for interacting with FC Service and Streaming Service

#### Asset Import
X5 can import assets from FC Service on demand. X5 GETs all assets by calling FC Service and then it replicates the hierarchical structure.
Important Note: FC Hierarchy contains non-assets in the hierarchy that are used as measuring points, X5 supports a different way to model this concept (i.e. an asset can have one or more measuring points)

#### Triggering PMs from FC Alarms
Given a PM configured in X5 for one or more assets and an alarm configured in FlukeConnect for one of the previous assets, when an alarm triggers, FlukeConnect notifies X5 about the incident.
X5 then looks for a PM containing the asset and then triggers the PM resulting into a new work order being created.

#### Notifying FC about new work orders
X5's Fluke Integration service listens for Work Order Created events and then POSTs the information to FC Service, who eventually creates a work order in FlukeConnect

#### Notifying X5 about changes in the work order status
When a work order is closed using FlukeConnect's mobile app, FlukeConnect notifies X5 by calling its API.

#### Displaying live data points
TBD
