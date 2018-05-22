# Running with Scissors

The workshop "Running with Scissors" presented at ChefConf 2018. The following repository contains notes, outline, code, and workstation setup materials.

## Summary

Join Franklin Webber and go deep into a detect and correct journey. You will build a cookbook in a test-driven approach with InSpec, extract the InSpec tests/controls into a InSpec profile, use the InSpec profile to test another cookbook, use the InSpec profile to scan non-nodes (agent-less), and finally use the InSpec profile with the Chef Audit cookbook to run on nodes (chef-client agent).

## Schedule

09:00-10:00 - Introduction and initial exercise
10:00-11:00
11:00-12:00
LUNCH
13:00-14:00
14:00-15:00
15:00-16:00

16:00-16:30 - Wrap Up

## Summary Outline

### Test the site

The participants are given cookbook to deploy a new micro-service written in Ruby. The cookbook is untested and incomplete. The participant will:

* Complete the cookbook based on results of the unit tests
* Create integration tests to ensure it works correctly
* Run the tests and verify the the results
* Create integration tests to ensure the language framework is deployed correctly
* Refactor the existing resources for the language framework into a custom resource / cookbook
* Refactor the existing resources for the application deployment into a custom resource / cookbook (download, extract, create service)

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

## Command-Complete Outline

The repositories for each of the sites with their cookbooks already exist on the workstation.

### First exercise

As a warm-up exercise to help bring people together and orient everyone to the work ahead I want to hand out source code to the chef recipes for the first site. A quick exercise will ask people to pair up and discuss in their groups:

* What is the recipe doing?
* What are the different concerns taking place within this recipe?
* What would you test?
* What would you refactor?
* Under what circumstances would you refactor this code?

> I found that this was a good exercise for the elegant tests workshop to get people acquainted to the code before immediately moving into testing the code. This again feels like a good way to get everyone away from the computers and talking to one another and using some of their judgement skills and conversational skills to communicate with one another. I don't believe it will have as great of an impact as that introduction did before but it definitely feels likes it will be helpful. I should qualify that - not as great - as this is only one recipe of many that they will be looking at during the day, where the other one was the test suite that they spent the entire day refactoring.

### First Site (Ruby)

Given a completely defined cookbook we want to have the learner define the tests for the cookbook.

```shell
$ cd first_site
$ kitchen converge
$ kitchen verify
```

These are the major concerns I see being accomplished in this cookbook:

1. application deployment
2. platform tools
3. service setup
4. the application

#### application deployment

The first few resources within the recipe perform a series of operations to create a deployment location, retrieve the code, and extract the site. This pattern will repeat itself in the future as long as you continue to use cookbooks for your application deployment. This simplistic version does not completely capture the complexity of what a deployment may really need.

* The path to the application may be available via a complex URL that requires authentication or additional components to create the complex URL
* The resulting archive may come in various forms or require some additional variations on the extraction
* The user / owner for this application may already need to be created
* The permissions may need to be defined for the path components

This could be extracted to a custom resource defined in a generic application cookbook.

These could be tested but it depends on the context which this matters.

InSpec: `command`, `file`, `package`

#### platform tools

The second few set of resources are classically the required tools necessary to run the application. In this case the Ruby language which requires a lot of additional libraries to be present on the system before the ruby language can be installed correctly to work with this application. The complexity of this could increase if one wanted to:

* specify a version of the application
* specify additional dependencies required by the application
* install with a particular user/owner and particular flags and such

This could be extracted to a custom resource or resources defined in a platform cookbook.

These could be tested but it depends on the context which this matters.

InSpec: `command`, `file`, `package`

##### service setup

A service is defined through a series of resources. This is platform specific. It could be extracted to a custom resource and placed in that same generic application cookbook.

InSpec: `command`, `service`, `file`

##### the application

The application is run with particular settings that may be important that could be configured. That would probably be extracted into the service setup pattern.

InSpec: `command`, `http`, `host`, and `port`

### Second site


## Additional Instructions

To generate the source code for discussion.

```bash
$ brew install enscript
```

```bash
$ enscript -CG2r -U2 --header="~/cookbooks/ruby_service/recipes/default.rb" --font="Courier@14" --word-wrap --mark-wrapped-lines=arrow cookbooks/ruby_service/recipes/default.rb --output ruby_service-default.ps
$ enscript -CG2r -U2 --header="~/cookbooks/node_service/recipes/default.rb" --font="Courier@14" --word-wrap --mark-wrapped-lines=arrow cookbooks/ruby_service/recipes/default.rb --output node_service-default.ps
$ enscript -CG2r -U2 --header="~/cookbooks/rust_service/recipes/default.rb" --font="Courier@14" --word-wrap --mark-wrapped-lines=arrow cookbooks/rust_service/recipes/default.rb --output rust_service-default.ps
```
