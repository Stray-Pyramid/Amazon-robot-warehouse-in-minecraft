<?php

require_once '../../../PHP_Configs/turtle_config.php';

dbConnect($con);

$action = (isset($_GET['action']) ? $con->escape_string($_GET['action']) : die('Missing action'));

if ($action === 'insert'){
    
	$type = (isset($_GET['type']) ? $con->escape_string($_GET['type']) : die('Missing type'));
	$x = (isset($_GET['x']) ? $con->escape_string($_GET['x']) : die('Missing X Coordinate'));
	$y = (isset($_GET['y']) ? $con->escape_string($_GET['y']) : die('Missing Y Coordinate'));
	$query = "INSERT INTO WHNodes (type, x, y) VALUES ('{$type}', '{$x}', '{$y}')";
	dbQuery($con, $query);
	echo $con->insert_id;

}elseif($action === 'edit'){
	
	$id = (isset($_GET['id']) ? $con->escape_string($_GET['id']) : die('Missing ID of Node'));
	$type = (isset($_GET['type']) ? $con->escape_string($_GET['type']) : die('Missing type'));
	$x = (isset($_GET['x']) ? $con->escape_string($_GET['x']) : die('Missing X Coordinate'));
	$y = (isset($_GET['y']) ? $con->escape_string($_GET['y']) : die('Missing Y Coordinate'));
	$query = "UPDATE WHNodes SET x='{$x}', y='{$y}', type='{$type}' WHERE id = '{$id}'";
	dbQuery($con, $query);
	echo 'success';
	
}elseif($action === 'delete'){
	
	$id = (isset($_GET['id']) ? $con->escape_string($_GET['id']) : die('Missing ID of Node'));
	$queryScaffold = "DELETE FROM WHNodes WHERE id = '%s'";
	$query = sprintf($queryScaffold, $con->escape_string($id));
	dbQuery($con, $query);
	echo 'success';
	
}elseif($action === 'getAllNodes'){
	$query = "SELECT * FROM WHNodes";
	$result = fetch_all_assoc(dbQuery($con, $query));
	
	if(!empty($result)){
		
		//Get Keys from $result
		$arrayKeys = array_keys($result[0]);
		
		//Add $arrayKeys to front of $result array
		array_unshift($result, $arrayKeys);
		
		//Echo results in single string
		foreach($result as $data){
			echo implode("|",$data);
			if($data != end($result)){
				echo "^";
			}
		}
	}
	
} elseif($action === 'getNodeCoor'){
	$nodeID = (isset($_GET['nodeID']) ? $con->escape_string($_GET['nodeID']) : die('Missing ID of Node'));
	$nodeType = (isset($_GET['nodeType']) ? $con->escape_string($_GET['nodeType']) : die('Missing type of Node'));
	
	if($nodeType == 'chest'){
		//nodeID refers to that of id in WHChests
		$query = "SELECT chestPosID,capacity,status,type,x,y FROM WHChests LEFT JOIN (WHNodes) ON (WHChests.chestPosID=WHNodes.id) WHERE WHChests.id={$nodeID}";
	} else {
		$query = "SELECT * FROM WHNodes WHERE id='{$nodeID}' and type='{$nodeType}'";
	}
	
	$result = fetch_all_assoc(dbQuery($con, $query));
	
	if (!empty($result)){
	
		//Get Keys from $result
		$arrayKeys = array_keys($result[0]);
	
		//Add $arrayKeys to front of $result array
		array_unshift($result, $arrayKeys);
	
		//Echo results in single string
		foreach($result as $data){
			echo implode("|",$data);
			if($data != end($result)){
				echo "^";
			}
		}
	}
	
} else {
	echo 'invalid action';
}
dbClose($con);
exit();

?>