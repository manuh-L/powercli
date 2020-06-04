# Powercli
This repository contains my powercli script examples

## vmtools.ps1
This PowerCLI script install VMware Tools on Windows VMs that doesn't have.

Prerequisite:
* administrator role
* VM must have IP and be reachable
* D: drive = CD-ROM Drive or change it, line xx


# vDS_csv.ps1 (v1.0)
Creates virtual distributed switch from csv file ".....the script still in dev phase 'the ultimate goal is to automate all the process of creation and migration of hosts & vms to vDS" 

The csv file must have column with:
portgroup;
IP;
