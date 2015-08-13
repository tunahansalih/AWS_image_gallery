#!/usr/bin/perl

$filename = 'credentials.txt';  #file containing credentials 
$keypair = 'MyKeyPair.pem'; #File containing 

#Getting AWS credentials from file
if(open($fh , '<' , $filename)){
	@cred = <$fh>;
	

	if($cred[0] =~ /AWS_ACCESS_KEY=(\w+)/){
		$awsaccesskeyid = $1;
		#print $awsaccesskeyid ."\n";

	}
	if($cred[1] =~ /AWS_SECRET_KEY=(\S+)/){
		$awssecretkey = $1;
		#print $awssecretkey . "\n";
	}
	#Sets Environment Variables so that connection can be done
	$ENV{AWS_SECRET_ACCESS_KEY} = "$awssecretkey";
	$ENV{AWS_ACCESS_KEY_ID} = "$awsaccesskeyid";

}else{
	die "Couldn't find the file containing credentials: '$filename' $!";
}

#Gets the ID of instances
$instance = `aws ec2 describe-instances`; 
if($instance =~ /\s(i-\w+)/){
	$instance_ID = $1;
}
#Gets the Region of Instance
if($instance =~ /(us-[\w\-]*)/){
	$region = $1;
}
#Sets Environment Variables so that connection can be done easily
	$ENV{AWS_DEFAULT_REGION} = "$region";

#Starts the machine
$status = `aws ec2 start-instances --instance-ids $instance_ID`;

#Waits for instance to open in order to get Public_DNS
while(!($status =~ /running\n/)){
	print "Waiting for instance to run...\n";
	sleep(1);
	$status = `aws ec2 start-instances --instance-ids $instance_ID`;	
}

#Gets Public DNS of instance
$instance = `aws ec2 describe-instances`; 
if($instance =~ /(ec2-.*amazonaws\.com)/){
	$public_DNS = $1;
}

#Stores the instance data for further use
open($outfile, '>' , 'instanceproperties.txt') or die "Couldn't find output file";
print $outfile "INSTANCE_ID=$instance_ID\n";
print $outfile "PUBLIC_DNS=$public_DNS";

$public_DNS = "ec2-user@" . $public_DNS;

#Uploads scripts that can be used within AWS instance,
#You can run these codes in the first opening
#But they still require some Perl modules to be installed 
#`scp -i $keypair -rp "labelimage.pl" $public_DNS:~` ;
#`scp -i $keypair -rp "searchlabels.pl" $public_DNS:~`;
#`scp -i $keypair -rp "gallery.pl" $public_DNS:~`;
#`scp -i $keypair -rp "imagga.pm" $public_DNS:~`;


#Connect to instance using this code
#exec("ssh -i $keypair $public_DNS -v");