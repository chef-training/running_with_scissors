# Azrael

> Azrael is an angel in the Abrahamic religions. He is often identified with the Angel of Death of the Hebrew Bible. (Wikipedia)

Azrael cookbook performs a scan against your target system and then uploads the results of that scan to the specified InSpec scan collection endpoint.

## Implementation

This cookbook is a wrapper for the [Audit cookbook]() and configures that cookbook to run the scan and store the results locally on the system using the provided file handler. This cookbook provides an additional handler to find that scan results file, load it, and then send it to a custom scan results collection service.
