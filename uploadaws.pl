#!/usr/bin/perl


#Usage1: uploadaws.pl filename1 filename2 ... filenameN -o awsdirname
#Usage2: uploadaws.pl dirname -o awsdirname

#Key Pair file to use SSH
$keypair = "MyKeyPair.pem";
#Directory of label file within the instance
$galleryfile = "labels.txt";

#Gets files to upload and the directory
$i=0;
while($ARGV[$i] ne "-o"){
	$files[$i] = $ARGV[$i];
	$i++;
}
$numoffile = $i;

$targetfile = $ARGV[++$i];

#Gets instance Properties from stored data
if(open($fh, '<', "instanceproperties.txt")){
	@instance = <$fh>; 
}else{
	die "instanceproperties.txt file couldn't found";
}

#Gets Public DNS from stored data
if($instance[1] =~ /PUBLIC_DNS=(.*)/){
	$public_DNS = $1;
}

$public_DNS = "ec2-user@" . $public_DNS;

#Creates file for upload
`ssh -i $keypair $public_DNS \'mkdir -p $targetfile\'`;
#Uploads files
`scp -i $keypair -rp @files $public_DNS:$targetfile`;

#foreach(@files){
#	`ssh -i $keypair $public_DNS \'./gallery.pl --add $targetfile/$_\'`;
#}

