#!/usr/bin/perl

use imagga;
use Cwd 'abs_path';
use List::MoreUtils qw(uniq);

$credFile = "credentials.txt"; #File containing IMAGGA credentials
$labelfile = "images.txt"; #File containing image names and related tags
$tagfile ="tags.txt"; #File containing tags

#Gets IMAGA credentials
if(open($fh, '<' , $credFile)){
	@creds = <$fh>;
	}else{
		die "Couldn't reach Imagga Credentials";
	}

if($creds[2] =~ /IMAGGA_ACCESS_KEY=(.*)/){
	$apiKey = $1	
}
if($creds[3] =~ /IMAGGA_SECRET_KEY=(.*)/){
	$apiSecret = $1;
}

#Number of tags wanted and the directory of image
$numoftags =$ARGV[0];
$filePath = $ARGV[1];

#Connecting IMAGGA API using Basic Authentication
$imagga = new imagga($apiKey, $apiSecret);

my( $err, $hash ) = $imagga->tag_image($filePath);

if($err){
	print "Error: ".$err."\n";
}

#The results are not sorted which is why I first reversed the hash
#so that keys become values vice versa, sorted them and again reversed
%reversed = reverse %$hash; 

@sorted = sort { $b <=> $a } keys(%reversed);


#Appending new image's tag to labels.txt file
open ($fh , '>>' , $labelfile);

#Stores Image name with the absolute path
$image_name = abs_path($filePath);
$allimg = `perl gallery.pl --listimages`;
if($allimg =~ /$image_name/){
	print "Same file exists in gallery";
}else{
	print $fh "image:$image_name labels: ";
	for ($i; $i <$numoftags ; $i++)
	{
		print  $fh "$reversed{$sorted[$i]} ";
		push(@lbls, $reversed{$sorted[$i]});
	}
	#Reads and rewrites tags,
	if(open($fh2 , '+>>' ,$tagfile)){
		@file2 = <$fh2>;
		foreach(@lbls){
			push(@file2, $_);	
		}
		@unique = uniq(@file2);
		print $fh2 "@unique ";
	}else{
		die "$tagfile Couldn't find";
	}
print $fh "\n";
}


close $fh;
close $fh2;