# RSpec Scan Data Collector

This web application will catch InSpec scans in JSON. They are then represented for review. Consider this the initial implementation of Chef Automate's compliance view.

This is a prototype. Consider the amount of work required to support and extend this application in production. Particularly consider the amount of time one would need to spend to create the correct visualizations.

## Getting Started

To run this application you will need to have [node]() and [npm]() installed.

With the project's root directory as your current working directory.

* Install the project dependencies: `npm install`

* Run the migrations: `npm ...`
* Run the service: `npm start`

## Requirements

Having [node]() and [npm]() installed on a system is a fairly common requirement these days. The use of the local filesystem for storing the records could create concerns about disk space but the choice makes for a simple implementation equation to deploy for evaluation.

## Implementation Notes

This is a node express web application that is connected to a sqlite3 local database. Considerations for launching this application into production:

* Load testing the scan collection service. Most importantly the concurrent connections it can support. As often groups of nodes will converge at the same interval. Creating a bottleneck here has the potential of causing some nodes to fail during post chef-client run phases when the audit cookbook and additional transport handler is written.

* A more robust data storage solution would probably need to be chosen to help with the performance. A local sqlite database file would likely become locked or delayed.
