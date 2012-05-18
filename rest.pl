 use REST::Client;
 my $client = REST::Client->new();

$client->POST('http://192.168.0.84:8080/category','{"name":"Test category" }','{"displayName":"Test category"}','{"parentId":null}',{ "Content-type" => 'application/json'});
 print $client->responseContent();


