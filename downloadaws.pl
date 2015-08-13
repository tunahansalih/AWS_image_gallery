#!/usr/bin/perl

$insinfo = "instanceproperties.txt";#File Containing Instance Information

$numOffiles= $#ARGV-1;#number of Files to download

$dirname = $ARGV[$#ARGV]; #Download Directory

pop @ARGV;
pop @ARGV;

#Gets Instance Info for use in SCP
if(open($fh, '<', $insinfo)){
	@f = <$fh>;
	}else{
		die "couldn't get PUBLIC_DNS";
	}

$public_DNS = $f[1];
if($public_DNS =~ /PUBLIC_DNS=(.*)/){
	$public_DNS = "ec2-user@" . $1;
}

#Downloads Files one by one 
foreach $a (@ARGV){
	print $a;
`scp -i MyKeyPair.pem -r $public_DNS:$a $dirname`;
}

