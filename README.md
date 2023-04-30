# Run Custom Commands on Deployment with Terraform VM Extensions

Author: Richard Haigh

Date of Intial Upload: 01/05/2023

Written - Terraform 1.4.0

Environment: Visual Studio Code 

Using terraform, we are able to create cloud-agnostic infrasturcture as code that can deploy any given Docker or machine image. However, this requires the exact image you require being freely availlable within public repositories and, in the case of particularly complex setups, this may not be the case. What if you require a standard cloud template that is able to download particular python packages or NLP libraries? 

How can cloud engineers automate the collection and setup of a particular suite of software in their template? Using terraform VM Extensions. 

Terraform Virtual Machine Extension allows us to provide post-deployment configuration and run automated tasks such as software install or sserver configuration.

This template demonstrates how to deploy an Azure virtual machine with a windows operating system and then install SQL Server and Python, subsequently setting the correct system path and collecting common libraries. 

This tutorial is aimed at cloud engineers who are new to Terraform and are looking to perform custom post-deployment commands to meet a particular need. We will store our shell commands within a root file and pass it to terraform via protected settings and locals. 
