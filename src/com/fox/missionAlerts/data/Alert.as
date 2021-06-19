/**
 * ...
 * @author SecretFox
 */
class com.fox.missionAlerts.data.Alert
{
	public var missionTierText:String; // "Tier X : ";
	public var missionName:String;
	public var missionID:Number;
	public var specialMissionText:String; // Special Mission
	public var chainText:String; // Chain: MissionName
	public var urgentText:String; // Urgent: MissionName
	public var customText:String; // Custom: MissionName
	public var items:Array = []; // list of item ID's
	public var refreshTime:Number;
}