<?php

require_once '../../../PHP_Configs/turtle_config.php';

dbConnect($con);

function getData($con, $data){
  
  $output = (isset($_GET[$data]) ? $con->escape_string($_GET[$data]) : die('Missing '.$data));
  
  return $output;
}


$origin 	= getData($con, 'origin');
$category 	= getData($con, 'category');
$text 	= getData($con, 'text');
$time = date('Y-m-d H:i:s');

$query = "INSERT INTO WHErrors (origin_id, type, text, time) VALUES ('{$origin}','{$category}','{$text}','{$time}')";

dbQuery($con, $query);
echo 'success';

dbClose($con);
exit();
?>