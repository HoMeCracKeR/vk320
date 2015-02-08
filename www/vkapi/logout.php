<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8" />
<title>API logout</title>
</head>
<body>
<?php

	function filter_argument($argument) {
	    $argument = preg_replace('/[^.,a-zA-Z0-9]/s', '', $argument);
	    return $argument;
	}

    $aid = filter_argument($_GET["aid"]);
    $token = filter_argument($_GET["token"]);
    $scope = filter_argument($_GET["scope"]);
    $domain = filter_argument($_GET["domain"]);

	if ($aid == "" || $token == "" || $scope == "" || $domain == "") {
		echo "API logout arguments error";
	} else {
		echo "<script src=\"https://login.vk.com/?act=openapi&oauth=1&aid=$aid&location=$domain&do_logout=1&token=$token\"></script>";
    	echo "<script type=\"text/javascript\">";
    	echo "window.onload = function() {window.location.href = 'https://oauth.vk.com/authorize?client_id=$aid>&scope=$scope&redirect_uri=https://oauth.vk.com/blank.html&response_type=token&display=mobile';}";
    	echo "</script>";
	}

?>
</body>
</html>