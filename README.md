xymon_report

Description
-----------
A Puppet report handler for sending notifications to Xymon.

Requirements
------------
A Xymon client on your Puppet master.

Installation & Usage
--------------------
# Install xymon_report as a module in your Puppet master's module path.
# Adapt xymon_report.yaml and move the file to /etc/puppet/xymon_report.yaml :
* xymon_servers : it's a list of your xymon servers.
* xymon_test_name : the column name in Xymon.
* xymon_test_ttl : the TTL of this test. If your Puppet Agent runs every hour, set TTL to 1h minimum.
* xymon_bin_path : xymon client binary.
* clean_message : remove some content from the report (host, md5sum...)
# Edit `/etc/puppet/puppet.conf` on your PuppetMaster and add xymon_report to your reports line :
`reports = log, http, xymon_report`

Author
------
Rémi remi@binbash.fr

Support
-------
Please log tickets and issues at https://github.com/binbashfr/binbashfr-xymon_report
