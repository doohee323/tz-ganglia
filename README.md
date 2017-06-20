This is a Ganglia server example on vagrant.
==========================================================================

# Features
```
	cluster names can be changed in /etc/ganglia/gmond.conf-X in block
	cluster { 
	  name = "cluster-1" #default name for gmond-1
	  owner = "unspecified" 
	  latlong = "unspecified" 
	  url = "unspecified" 
	} 
	
	to feed data use ports set for given gmond instance
	for gmond-1
	tcp_accept_channel { 
	  port = 8649 
	} 
```

# Execution
```
	vagrant up
	#vagrant destroy -f && vagrant up
```

# Run
```
 	http://192.168.82.169/ganglia/
```


