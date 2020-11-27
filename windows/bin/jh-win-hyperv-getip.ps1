# Thanks to https://stackoverflow.com/a/27999072/1954789

get-vm | ?{$_.State -eq "Running"} | select -ExpandProperty networkadapters | select vmname, macaddress, switchname, ipaddresses
