<?php

require_once '../../../PHP_Configs/turtle_config.php';

dbConnect($con);

$action = (isset($_GET['action']) ? $con->escape_string($_GET['action']) : die('Missing action'));

if($action === 'new'){
	$x = (isset($_GET['x']) ? $con->escape_string($_GET['x']) : die('Missing chest x'));
	$y = (isset($_GET['y']) ? $con->escape_string($_GET['y']) : die('Missing chest y'));
	$capacity = (isset($_GET['capacity']) ? $con->escape_string($_GET['capacity']) : die('Missing chest capacity'));
	$status = (isset($_GET['status']) ? $con->escape_string($_GET['status']) : die('Missing chest status'));
	
	$query = "INSERT INTO WHChests (x, y, capacity, status) VALUES ('{$x}','{$y}','{$capacity}','{$status}')";
	dbQuery($con, $query);
	echo $con->insert_id;
	
} elseif($action === 'update') {
	$chestID = (isset($_GET['chestID']) ? $con->escape_string($_GET['chestID']) : die('Missing chest ID'));
	$status = (isset($_GET['status']) ? $con->escape_string($_GET['status']) : die('Missing chest status'));
	
	$query = "UPDATE WHChests SET status='{$status}' WHERE id = {$chestID}";
	dbQuery($con, $query);
	echo 'success';
	
} elseif($action === 'remove') {
	$chestID = (isset($_GET['chestID']) ? $con->escape_string($_GET['chestID']) : die('Missing chest ID'));

	$query = "DELETE FROM WHChests WHERE id = {$chestID}";
	dbQuery($con, $query);
    echo 'success';
	
} elseif($action === 'getAll'){
	$query = "SELECT * FROM WHChests";
	$result =  fetch_all_assoc(dbQuery($con, $query));

	if(!empty($result)){

		//Get Keys from $result
		$arrayKeys = array_keys($result[0]);

		//Add $arrayKeys to front of $result array
		array_unshift($result, $arrayKeys);

		//Echo array as single string
		foreach($result as $data){
			echo implode("|",$data);
			if($data != end($result)){
				echo "^";
			}
		}
	}
	
} else {
	die("option invalid");
	
}

dbClose($con);
exit()
?>