<?php

require_once '../../../PHP_Configs/turtle_config.php';

dbConnect($con);

function getData($con, $data){
  
  $output = (isset($_GET[$data]) ? $con->escape_string($_GET[$data]) : die('Missing '.$data));
  
  return $output;
}


$action = getData($con, 'action');

if($action === 'new'){
	$itemName 	= getData($con, 'itemName');
	$displayName = getData($con, 'displayName');
    $modName		= getData($con, 'modName');
	
	$count 			= getData($con, 'count');
	$dmg 			= getData($con, 'dmg');
	$locationID 	= getData($con, 'locationID');
	$locationPos 	= getData($con, 'locationPos');
	
    $query = "INSERT INTO WHItems (itemName, displayName, modName, count, dmg, locationID, locationPos) VALUES ('{$itemName}','{$displayName}','{$modName}','{$count}','{$dmg}','{$locationID}','{$locationPos}')";
	dbQuery($con, $query);
    echo $con->insert_id;
	
}elseif($action === 'updateLocation'){
	$itemID 		= getData($con, 'itemID');
	$locationID 	= getData($con, 'locationID');
	$locationPos 	= getData($con, 'locationPos');
		
    $query = "UPDATE WHItems SET locationID='{$locationID}', locationPos='{$locationPos}' WHERE id = {$itemID}";
	
	dbQuery($con, $query);
	echo 'success';

}elseif($action === 'updateCount'){
	$itemID 	= getData($con, 'itemID');
	$count 	= getData($con, 'count');
	
	$query = "UPDATE WHItems SET count='{$count}' WHERE id = {$itemID}";
	
	dbQuery($con, $query);
	echo 'success';
	
}elseif($action === 'remove'){
	$itemID 	= getData($con, 'itemID');
	
    $query = "DELETE FROM WHItems WHERE id = {$itemID}";
	dbQuery($con, $query);
	echo 'success';
	
}elseif($action === 'getAll'){
	$query = "SELECT * FROM WHItems";
	$result =  fetch_all_assoc(dbQuery($con, $query));
	
	if(!empty($result)){
		
		//Get Keys from $result into separate array
		$arrayKeys = array_keys($result[0]);
		
		//Add $arrayKeys to front of $result array
		array_unshift($result, $arrayKeys);
		
		foreach($result as $data){
			echo implode("#",$data);
			if($data != end($result)){
				echo "^";
			}
		}	
	}

}elseif($action === 'getItemIndex'){
	$query = "SELECT itemID,itemName FROM WHItemIndex";
	$result = fetch_all_assoc(dbQuery($con, $query));
	if(!empty($result)){
		
		//Get Keys from $result into separate array
		$arrayKeys = array_keys($result[0]);
		
		//Add $arrayKeys to front of $result array
		array_unshift($result, $arrayKeys);
		
		foreach($result as $data){
			echo implode("#",$data);
			if($data != end($result)){
				echo "^";
			}
		}	
	} else {
	  echo 'error';
	}
	
}elseif($action === 'getItemsToSpawn'){
	$query = "SELECT * FROM WHItemsToSpawn";
	$result = fetch_all_assoc(dbQuery($con, $query));
	if(!empty($result)){
		
		//Get Keys from $result into separate array
		$arrayKeys = array_keys($result[0]);
		
		//Add $arrayKeys to front of $result array
		array_unshift($result, $arrayKeys);
		
		foreach($result as $data){
			echo implode("#",$data);
			if($data != end($result)){
				echo "^";
			}
		}	
	} else {
	  echo 'error';
	}
	
}elseif($action === 'addItemToSpawn'){
	$itemID 	= getData($con, 'itemID');
	$itemName 	= getData($con, 'itemName');
	$dmg 	= getData($con, 'dmg');
	$mod 	= getData($con, 'mod');
	$maxStack 	= getData($con, 'maxStack');
	
	$query = "INSERT INTO WHItemsToSpawn (`itemID`, `itemName`, `dmg`, `mod`, `maxStack`) VALUES ('{$itemID}','{$itemName}','{$dmg}','{$mod}','{$maxStack}');";
	dbQuery($con, $query);
    echo $con->insert_id;
	
}else{
  echo 'Action Invalid';
}

dbClose($con);
exit();
?>