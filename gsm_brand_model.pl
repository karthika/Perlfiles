use strict;
use LWP::UserAgent;
use HTTP::Cookies;
#---------------------------------------------------Creating User Agent Object--------------------------------------------------------------------
my $ua=LWP::UserAgent->new;
$ua->agent(" Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.2) Gecko/20100115 Firefox/3.6"); 
my $req=HTTP::Request->new;
$req->header("Content-Type"=>"text/html; charset=utf-8");
my $cookie_jar = HTTP::Cookies->new(file=>$0."_cookie.txt",autosave => 1,);
$ua->cookie_jar($cookie_jar);

#----------------------------------------------------Creating Files And Declaring--------------------------------------------------------------------
my $url="http://www.gsmarena.com/makers.php3";
my $content=&get($url);
print"\n$content\n";
my $count=1;
while($content=~m/<td>\s*<a\s*href\s*\=\s*[^<]*?\s*>\s*<img[^<]*?>\s*<\/a>\s*<\/td>\s*<td>\s*<a\s*href\=\s*([^<]*?)\s*>\s*([^<]*?)\s*<\/a>/igs)
{
	my $pageurl=$1;
	my $brand=$2;
	my $pageurl1="http://www.gsmarena.com/".$pageurl;
	my $pagecontent=&get($pageurl1);
	print"\nINSIDE WHILE\n";
	start:
	print"THE COUNT IS ::::::::::::::::: $count\n";
	while($pagecontent=~m/<div\s*class\=\"makers\">([\w\W]*?)<\s*\/div>/igs)
	{
		my $urlcontent=$1;		
		print"\nINSIDE IF INSIDE WHILE\n";
		while($urlcontent=~m/<strong>\s*([^<]*?)\s*<\/strong>\s*<\/a>/igs)
		{
			my $subcont=$1;
			print"\nINSIDE IF INSIDE WHILE INNER WHILE\n";
			open(FH,">>output_gsm_value.txt");
			print FH "$brand\t$subcont\n";
			print "$subcont\n";
			close(FH);

		}
		
	}
		if($pagecontent=~m/<a\s*href\=\s*\"\s*([^<]*?)\s*\"\s*title\=\"Next\s*page\">/is)
		{
			my $nexturl=$1;
			$nexturl="http://www.gsmarena.com/".$nexturl;
			print "INSIDE NEXT PAGE\n";
			my $nextpagecontent=&get($nexturl);
			$pagecontent=$nextpagecontent;
			$count++;
			goto start;
			
		}

}


#-----------------------------------------------------------------------------------------------------------
sub get
{
	my $url = $_[0];
	my $try=0;
	home:
	$try++;
	# ------------------- Sending request and getting response------------------------
	my $req = HTTP::Request->new(GET=>$url);
	$req->header("Content-Type"=> " application/x-www-form-urlencoded");
	my $res = $ua->request($req);
	$cookie_jar->extract_cookies($res);
	$cookie_jar->save;
	$cookie_jar->add_cookie_header($req);
	my $code=$res->status_line;
	my $content;
	# -------------- If the response is 404----------------------------
	if($code =~m/40/is)
	{	
		open(Network_log,">>NetworkLog.txt");		
		print Network_log "$code : $url\n";
		close(Network_log);
		$content = $code;	
		
	}
	#------------------ If the Response is 502---------------------
	elsif($code =~m/50/is)
	{
		print "NET FAILURE - Going to sleep for 5 sec\n";
		sleep(5);
		if($try<50)
		{
			goto home;
		}
	}
		#------------------ If the Response is 302---------------------

	elsif($code=~m/30/is)
	{
		my $loc = $res->header('Location');
		$content=get($loc);
	}
		#------------------ If the Response is 200 ---------------------

	elsif($code =~m/20/is)
	{
		print"GOT CONTENT\n";
		$content = $res->content;
	}
	return ($content);
}
