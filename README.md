# Running with Scissors

## Outline

### Test the site

The participants are given cookbook to deploy a new micro-service written in Ruby. The cookbook is untested and incomplete. The participant will:

* Complete the cookbook based on results of the unit tests
* Create integration tests to ensure it works correctly
* Run the tests and verify the the results

### Create portable tests

The participants are given a second cookbook that deploys a node implementation of the same service. The cookbook is untested and incomplete. The participant will:

* Complete the cookbook based on results of the unit tests
* Extract the integration tests from the original cookbook into a profile
* Define the test suite with the new profile

### Handle the test results

The participants want to run these tests every time the cookbook is applied (not just as integration tests run on the local workstation). This can be accomplished through the audit cookbook. The audit cookbook leaves the results on the local filesystem. The new micro-service is able to see the results. Another handler is required to send the results to the service. The participant will:

* Create a new test suite that deploys the micro-service and runs the audit cookbook
* View the results found on the local file system in the test environment
* Create/Use a handler to upload the results to the deployed service.
* View the results in the service

The conclusion for this section talks through how the participants have a report service now to receive the results of their InSpec scans that all nodes could use when given the right host and port. This eventually leads the conversation to using Chef Automate to display the results.

### Habitat with tests

The final act has the participants see that the InSpec profile that they created to test their micro-service can also be used when working with Habitat. The participants will:

* Download / Check out / Build a Habitat plan for one service
* Run the service and see the InSpec results
