#!/usr/bin/perl

#Directory containing instance properties
$insinfo = "instanceproperties.txt";

#Gets Instance Id
if(open($fh, '<', $insinfo)){
	@fl = <$fh>;

	if($fl[0] =~ /INSTANCE_ID=(.*)/){
		$instance_ID = $1;
	}
}

#Stops the running instance
exec("aws ec2 stop-instances --instance-ids $instance_ID");

