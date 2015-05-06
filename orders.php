<?php

require_once '../../../PHP_Configs/turtle_config.php';

dbConnect($con);

function getData($con, $data){
  
  $output = (isset($_GET[$data]) ? $con->escape_string($_GET[$data]) : die('Missing '.$data));
  
  return $output;

}

$action = getData($con, 'action');


$action = (isset($_GET['action']) ? $con->escape_string($_GET['action']) : die('Missing action'));

if($action === 'new'){

	$status 		= getData($con, 'status');
	$orderType = getData($con, 'orderType');
	$itemID 	= getData($con, 'itemID');
	
	$reqCount 			= getData($con, 'reqCount');
	$creationTime 	= date('Y-m-d H:i:s');
    $createdBy 		= getData($con, 'createdBy');

	$query = "INSERT INTO WHOrders (status, orderType, itemID, reqCount, creationTime, createdBy) VALUES ('{$status}', '{$orderType}','{$itemID}','{$reqCount}','{$creationTime}','{$createdBy}')";

}elseif($action === 'assign'){
	
	$orderID 		= getData($con, 'orderID');
	
	$assignTo 		= getData($con, 'assignTo');
	$assignTime = date('Y-m-d H:i:s');
	
	$destinationID 		= getData($con, 'destinationID');
	$destinationPos 		= getData($con, 'destinationPos');
	
	$query = "UPDATE WHOrders SET assignTo='{$assignTo}', assignTime='{$assignTime}', destinationID='{$destinationID}', destinationPos='{$destinationPos}' WHERE id = {$orderID}";
	
}elseif($action === 'updateStatus'){

	$orderID = (isset($_GET['orderID']) ? $con->escape_string($_GET['orderID']) : die('Missing order ID'));
	$status = (isset($_GET['status']) ? $con->escape_string($_GET['status']) : die('Missing new status'));

	$query = "UPDATE WHOrders SET status = '{$status}' WHERE id = {$orderID}";
	
}elseif($action === 'getWaitingOrders'){
	
	$query = "SELECT * FROM WHOrders WHERE status = 'new' or status = 'active' or status = 'hold'";
	
} else {
	
	die('Action invalid');

}

$result = dbQuery($con, $query);

if ($action === 'getWaitingOrders'){
	
	$result = fetch_all_assoc($result);

	if(!empty($result)){
		
		//Get Keys from $result
		$arrayKeys = array_keys($result[0]);
		
		//Add $arrayKeys to front of $result array
		array_unshift($result, $arrayKeys);
		
		foreach($result as $data){
			echo implode("|",$data);
			if($data != end($result)){
				echo "^";
			}
		}
	}

} else {

	echo ($con->insert_id != 0 ? $con->insert_id : 'success');
	
}

dbClose($con);
exit();
?>