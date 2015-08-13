#!/usr/bin/perl

#A script that enables the user to control the gallery. It can get various different types of options.
#The list image options should list the full paths of the images.
#a) Name: gallery.pl
#b) Usage 1: gallery.pl --listlabels
#	i) This will return all the unique labels that your current image gallery contains.
#c) Usage 2: gallery.pl --listimages
#	i) This will list every image currently within your gallery.
#d) Usage 3: gallery.pl --listimages "labelname"
#	i) This will list every image tagged with the label "labelname" currently within your gallery.
#e) Usage 4: gallery.pl --listimages --similar image_name
#	i) This will list every image tagged with the same label(s) that the image with
#"image_name" is tagged.
#f) Usage 5: gallery.pl --listsamples "labelname"
#	i) 	List all the sample images with the label "labelname" that the user has downloaded.
#g) Usage 6: gallery.pl --add "dirname"
#	i) Adds the files in "dirname" to the gallery.

use Getopt::Long qw(GetOptions);
use List::MoreUtils qw(uniq);
use Cwd 'abs_path';


$imageFile = "images.txt"; #The text file containing image names and related labels
$sampleFile = "samples.txt"; #The file containing sample URL's
#Command line options
$listimages = 'not used';
GetOptions(
	'listlabels' => \$listlabels,
	'listimages=s{0,1}' => \$listimages,
	'similar=s' => \$similarimage,
	'listsamples=s' => \$labelname,
	'add=s' => \$dirname ) or die "Error in argument";

#Gets image names and related tags
open($fh, '<' , $imageFile);
@file = <$fh>;
foreach $line (@file){
	if($line =~ /image:(\S*)/){
		push(@images, $1);		
	}
	if($line =~ /labels:(.*)/){
		$tagsof{$images[$i++]} = $1;
	}
}

#Listlabels option
if($listlabels){	

		@labels;
		while(my ($key, $value) = each(%tagsof)){
			
			push(@labels, split(' ', $value));
		}
		@alltags = uniq(@labels);
		print "@alltags";
}

#listimages options
if($listimages ne 'not used'){
	#listimages with parameter
	if($listimages ne ''){
		while(my ($key, $value) = each(%tagsof)){
			if($tagsof{$key} =~ /$listimages/){
				print $key. " ";
			}
		}
	#listimages with similarimage option
	}elsif($similarimage){
		@tagstofind = split(' ' , $tagsof{$similarimage});
		while(my ($key, $value) = each(%tagsof)){
			foreach $t (@tagstofind){
				if(($tagsof{$key} =~ /$t/) && ($key ne $similarimage)){
					push(@similars ,$key);
				}
			}
		}
		@allsimilars = uniq(@similars);
		print "@allsimilars";
	}
	#listimages without parameter
	else{
		@imgs = keys(%tagsof);
		print "@imgs";
	}
}


#listsamples option
if($labelname){
	open($fhsample , '<' , $sampleFile);
	@smpl = <$fhsample>;
	foreach(@smpl){
		if(/label:$labelname (.*)/){
			$urls = $1;
		}
	}
	print $urls;
}

#add option
if($dirname){
	print $dirname;
	opendir(DIR, $dirname) or die $!;

	while(my $file = readdir(DIR)){
		next unless( -f "$dirname/$file");

		$abspath = abs_path("$dirname/$file");
		print $abspath;
		`perl labelimage.pl 10 $abspath`;
	}

}