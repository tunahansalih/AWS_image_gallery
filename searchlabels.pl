#!/usr/bin/perl

#Usage1: searchlabels.pl [number of result expected] [word to search for]
#iThis will return the URL's of different images with the keyword "sky" using any
#search engine.

use WWW::Mechanize;
use LWP::Simple;

$credFile = "credentials.txt";  #File where Account credentials stored
$samplefile = "samples.txt"; #File where samples stored;

$mech = WWW::Mechanize->new();

if(open($fh , '<' , $credFile)){
	@cred = <$fh>; 
}else{
	die "Couldn't open $credFile";
}

if($cred[4] =~ /AZURE_PRIMARY_ACCOUNT_KEY=(.*)/){  
	$accountkey=$1;									#Azure Market Account Key
}
if($cred[5]=~ /AZURE_CUSTOMER_ID=(.*)/){
	$customerID=$1;									#Azure Market Customer ID
}

$numofresults = $ARGV[0];	#number of results to be found
$word = $ARGV[1];			#tag that will be searched for


$mech->credentials($customerID ,$accountkey); #Basic authentication with credentials

#Url for getting results
$url = "http://api.datamarket.azure.com/Bing/Search/Image?Query=\%27$word\%27&\$top=$numofresults&\$format=JSON";
$mech->get($url);
$html = $mech->content();

#Matching the URL's of pictures from the output
while ($html =~ /"MediaUrl":"([^"]*)"/g){
	push(@imagesURL, $1);
}


open($fh2, '>', $samplefile);

#Prints URL's found
print $fh2 "label:$word ";
print $fh2 "@imagesURL";
