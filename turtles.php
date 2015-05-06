<?php

require_once '../../../PHP_Configs/turtle_config.php';

dbConnect($con);

$action = (isset($_GET['action']) ? $con->escape_string($_GET['action']) : die('Missing action'));

if ($action === 'getStatistics'){
	
	$turtleID = (isset($_GET['turtleID']) ? $con->escape_string($_GET['turtleID']) : die('Missing turtleID'));
	$orderStats = fetch_all_assoc(dbQuery($con, "SELECT * FROM WHOrders WHERE assignTo = {$turtleID}"));
	
	$result = dbQuery($con, "SELECT * FROM WHTurtles WHERE turtleID = {$turtleID}");
	$turtleStats = $result->fetch_assoc();
	
	if ($turtleStats != null){
		$completedCount = 0;
		$totalFuelUsedForOrders = 0;
		$totalTime = 0;

		foreach($orderStats as $order){
		  //Total orders completed
		  if ($order['status'] == 'complete'){
			  $completedCount++;
			  //Total time on order
			  $totalTime += (strtotime($order['timeUsed'])-strtotime($order['assignTime']));
		  } 
		  
		  $totalFuelUsedForOrders += $order['fuelUsed']; 
			
		}
		unset($order);
		
		//1. Total orders assigned to turtle
		$totalOrders = count($orderStats);
			  
		//Average fuel per order
		$averageFuel = 0;
		if ($completedCount != 0){
		  $averageFuel = ($totalFuelUsedForOrders/$completedCount);
		}
		
		//Completion rate
		$completionRate = 0;
		if ($completedCount != 0){
		$completionRate = $completedCount/$totalOrders;
		}
		
		//Average completion time
		$averageTime = 0;
		if ($totalTime != 0){
		$averageTime = $totalTime/$totalOrders;
		}
		
		$output = array('totalOrders'=>$totalOrders, 'completedCount'=>$completedCount,'totalFuel'=>$turtleStats['fuelUsed'],'averageFuelPerOrder'=>$averageFuel, 'completionRate'=>$completionRate, 'averageTime'=>$averageTime);
		
		if (!empty($output)){
			echo implode("|",array_keys($output));
			echo '^';
			echo implode("|",$output);
		}
	
	} else{
	  echo 'Turtle has no orders!';
	}

} else {
	echo 'Action invalid';
}

?>