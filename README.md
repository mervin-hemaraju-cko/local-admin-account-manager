# Local Admin Account Manager

This script has been built to verify the local admin configuration and
credentials on a Windows instance.


## What does it do?

1.  It will first check if the ckoawsadmin user account is present.

2.  If it is not present, the script will create one and add it to the
    corresponding groups

3.  If it was already present, the script will then check if the user
    account is present in the correct local admin essential groups
    (Administrators, Remote Desktop Users, etc.)

4.  If not present, it will add it.

5.  Finally, it will check if the credentials match the generally
    defined local admin password.

## How to use the Script?

#### **AWS Systems Manager**

You can use AWS Systems Manager to run the script on a batch of
instances.

You can deploy an AWS SSM document to download the script from a bucket and run it on a batch of instances

You can then use this document in an AWS RunCommand to launch it.

### **Locally**

You can also run this script individually on an instance. You will first
need to clone the repo and run the script.

Before running it, the two variables below must be set on the PowerShell
instance for it to work:

```
$LocalAdminPassword = 'the_password'
$LocalUserName = 'the_username'
```
