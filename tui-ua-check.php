<?php
function has_urls()
{
    $urls= array_keys(array_flip(array_filter(explode(",", @$_REQUEST['urls']))));
    return $urls && is_array($urls) && !empty($urls)?$urls:false;
}
function get_results($urls)
{
	
	if ($urls && is_array($urls) && !empty($urls))
	{
		ob_implicit_flush(true);
		ob_end_flush();
		foreach ($urls as $url)
		{
			$cmd = "bash tui-ua-check.sh '$url' '1'";
			$ret = exec("php tui-ua-check.php '$url' '1'");
			$descriptorspec = array(
				0 => array("pipe", "r"), // stdin is a pipe that the child will read from
				1 => array("pipe", "w"), // stdout is a pipe that the child will write to
				2 => array("pipe", "w"), // stderr is a pipe that the child will write to
			);
			flush();
			$process = proc_open($cmd, $descriptorspec, $pipes, realpath('./'), array());

			if (is_resource($process))
			{
                echo("<h6 class='text-info'><a  target='_blank' href='{$url}'>{$url}</a></h6>");
				while ($s = fgets($pipes[1]))
				{
					$s = array_filter(explode(",", $s));
					foreach ($s as $k => $v)
					{
						$s[$k] = base64_decode($v);
					}

					 echo("<table class='table'><tr><td>UserAgent</td><td class='text-success'>{$s[3]}</td></tr><td>HTTP code</td><td class='text-".(@$s[4]==200?'success':'danger')."'>{$s[4]} </td></tr><tr><td>HTML</td><td><a target='_blank' href='./".(str_replace(__DIR__,"",$s[1]))."/{$s[3]}{$s[2]}.html'>{$s[3]}{$s[4]}.html</a><td></tr></table><br/>");

					flush();
				}
 			}
		}
	}
}
?>
 

<!DOCTYPE html>
<html lang="en">

<head>
    <title>Crawl As GoogleBot</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.2.1/css/bootstrap.min.css" integrity="sha384-GJzZqFGwb1QTTN6wy59ffF1BuGJpLSa9DkKMp0DgiMDm4iYMj70gZWKYbI706tWS" crossorigin="anonymous">
    <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.6/umd/popper.min.js" integrity="sha384-wHAiFfRlMFy6i5SRaxvfOCifBUQy1xHdJ/yoi7FRNXMRBu5WHdZYu1hA6ZOblgut" crossorigin="anonymous"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.2.1/js/bootstrap.min.js" integrity="sha384-B0UglyR+jN6CkvvICOB2joaf5I4l3gm9GU6Hc1og6Ls7i6U/mkkaduKaBhlAXv9k" crossorigin="anonymous"></script>
    <style>
        .fakeimg {
    height: 200px;
    background: #aaa;
  }
  </style>
</head>

<body>
    <div class="jumbotron text-center" style="margin-bottom:0">
        <h1>Crawl As GoogleBot</h1>
        <p>Crawl url as all possible GoogleBot UserAgents</p>
    </div>
    <nav class="navbar navbar-expand-sm bg-dark navbar-dark">
    </nav>
    <div class="container" style="margin-top:30px">
        <div class="row">
            <div class="col-sm-12">
                <h2>Please enter Urls</h2>
                <h5> </h5>
                <form method="post">
                    <div class="form-group">
                        <label for="exampleFormControlTextarea1">Email address</label>
                           <textarea class="form-control" id="exampleFormControlTextarea1" name="urls" rows="10"></textarea>

                    </div>

                    <button type="submit" class="btn btn-primary">Submit</button>
                </form>
            </div>
        </div>
    
    <?php $urls=has_urls();
        if($urls)
        {
            ?>
             <div class="row">
            <div class="col-sm-12">
                
                <?php get_results($urls);?>
            </div></div>
            <?php 

        }
    ?>
    <br/>
    <div class="jumbotron text-center" style="margin-bottom:0">
    </div>
    </div>
</body>

</html>
