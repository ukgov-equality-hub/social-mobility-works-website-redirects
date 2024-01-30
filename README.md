# What is this?
This is the code behind the Social Mobility Works website redirects.

The Social Mobility Commission used to have a website called Social Mobility Works:
* [socialmobilityworks.org]()

This domain name now redirects to the new SMC website:
* [socialmobility.independent-commission.uk]()

By default, requests will redirect to the homepage of the new SMC website.  
But there are several specific redirects configured.  

# How do I configure the redirects?
1. Ask a member of the team for editing permissions on this GitHub repository
2. Edit the files:
   * [configure_the_redirects.json](./terraform/configure_the_redirects.json) (in the `terraform` folder)
   * [configure_the_redirects.csv](./terraform/configure_the_redirects.csv) (in the `terraform` folder)
3. Save the files.  
   This will run a [GitHub Action](https://github.com/ukgov-equality-hub/social-mobility-commission-vanity-domain-redirects/actions) and the changes will be uploaded to our cloud hosting