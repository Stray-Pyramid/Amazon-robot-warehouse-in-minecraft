<?php

require_once '../../../PHP_Configs/turtle_config.php';


dbConnect($con);

function getData($con, $data){
  
  $output = (isset($_GET[$data]) ? $con->escape_string($_GET[$data]) : die('Missing '.$data));
  
  return $output;
}


$action = getData($con, 'action');

if($action === 'insert'){
	
	$computerID 	= getData($con, 'computerID');
	$nodeID 		= getData($con, 'nodeID');
	$mode 			= getData($con, 'mode');
	$ob1 			= getData($con, 'ob1');
	$ob2 			= getData($con, 'ob2');
	$ob3 			= getData($con, 'ob3');

    $query = "INSERT INTO WHStations (computerID, nodeID, mode, ob1, ob2, ob3) VALUES ('{$computerID}', '{$nodeID}', '{$mode}', {$ob1}, '{$ob2}', '{$ob3}');";
    dbQuery($con, $query);
	echo 'success';
	
}elseif($action === 'update'){
	
	$computerID 	= getData($con, 'computerID');
	$mode 			= getData($con, 'mode');
	
	$query = "UPDATE WHStations SET mode='{$mode}', transitionInto=NULL WHERE computerID = '{$computerID}'";
    dbQuery($con, $query);
	echo 'success';
	
}elseif($action === 'transition'){
	$computerID 	= getData($con, 'computerID');
	$newMode 	= getData($con, 'newMode');
	
	$query = "UPDATE WHStations SET, transitionInto='{$newMode}' WHERE computerID = '{$computerID}'";
    dbQuery($con, $query);
	echo 'success';
	
}elseif($action === 'delete'){
	
	$nodeID = getData($con, 'nodeID');
	
	$query = "DELETE FROM WHStations WHERE nodeID = {$nodeID}";
	dbQuery($con, $query);
	echo 'success';
	
}elseif($action === 'getAll'){
	$query = "SELECT * FROM WHStations";
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
exit();

?>