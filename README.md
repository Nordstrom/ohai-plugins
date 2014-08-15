#HBA Ohai Plugin

##This plugin returns various attributes for HBA(host bus adapter) ports on solaris 10, and linux servers

##Requirements
Have chef client version >= 11.12

##Solaris 10 attributes returned:

 1. port name
 1. node name
 1. supported speeds
 1. speed
 1. os device name
 1. manufacturer
 1. model
 1. firmware version
 1. fcode bios version
 1. driver name
 1. driver version
 1. type
 1. state

##Linux attributes returned:

 1. port name
 1. port state
 1. node name
 1. supported speeds
 1. speed
 1. symbolic name

###Expected Output
````
{
"host2": {
    "port_name": "0x10000090fa1fd129",
    "port_state": "Online",
    "node_name": "0x20000090fa1fd129",
    "supported_speeds": "2 Gbit, 4 Gbit, 8 Gbit",
    "speed": "4 Gbit",
    "symbolic_name": "Emulex AJ763B/AH403A FV1.11A5 DV8.3.5.86.1p"
  }
}
````

###Knife Commands
* `knife search node 'hbaattr_host*_(INSERT_ATTRIBUTE: VALUE)' -a "hbaattr"`
returns all hosts with the given attribute and value

####Examples:
* `knife search node 'hbaattr_host*_state:offline' -a "hbaattr"` returns all offline hba's
* `knife search node 'hbaattr_host*_port_name:*' -a "hbaattr"` returns all hba's with a port name

##Additional Information
* [Chef Inc. Ohai documentation](http://docs.opscode.com/ohai.html)

##Authors:

Author::Nikki Nikkhoui - @nikkhn
Author::Mark Gibbons - @MarkGibbons
Author::Doug Ireton - @dougireton

