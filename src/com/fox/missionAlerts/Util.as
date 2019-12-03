import com.GameInterface.AgentSystem;
import com.GameInterface.AgentSystemMission;
import com.GameInterface.DistributedValue;
import com.GameInterface.LoreBase;
import com.GameInterface.Tooltip.TooltipData;
import com.GameInterface.Tooltip.TooltipManager;
/*
 * ...
 * @author fox
 */
class com.fox.missionAlerts.Util{
	
// icon might not be loaded if this is called before topbar loads
	static function SetIcon(data) {
		if (!_root.mainmenuwindow.m_AgentIconContainer) {
			setTimeout(SetIcon, 500, data);
			return
		}
		_root.mainmenuwindow.m_AgentIconContainer._alpha = 100;
		_root.mainmenuwindow.m_AgentIcon.enabled = true;
		_root.mainmenuwindow.m_AgentIcon.gotoAndStop("urgent");
		_root.mainmenuwindow.m_AgentIconContainer.onRollOver =  function(){
			if (this._visible && this._alpha > 0)
			{
				var tooltipData:TooltipData = new TooltipData();
				var desc:Array = []
				for (var i in data){
					desc.push(data[i][1] + " " + Util.CalculateTimeString(AgentSystem.GetMissionRefreshTime(data[i][0].m_MissionId),data[i][0].m_MissionName));
				}
				tooltipData.AddDescription("<font size='11'>"+desc.join("\n")+"</font>");
				tooltipData.m_Padding = 4;
				tooltipData.m_MaxWidth = 200;
				tooltipData.m_Color = 0xFF8000;
				tooltipData.m_Title = "<font size='14'><b>Alerts</b></font>";
				
				var delay:Number = DistributedValue.GetDValue("HoverInfoShowDelay");
			  
				this.m_Tooltip = TooltipManager.GetInstance().ShowTooltip( _root.mainmenuwindow.m_AgentIconContainer, undefined, delay, tooltipData );
			}
		}
		
		_root.mainmenuwindow.m_AgentIconContainer.onRollOut = _root.mainmenuwindow.m_AgentIconContainer.onDragOut = function(){
			if (this.m_Tooltip != undefined)
			{
				this.m_Tooltip.Close();
				this.m_Tooltip = undefined;
			}
		}
		_root.mainmenuwindow.Layout();
	}
	static function CalculateTimeString(timeLeft,name){
		var time:Number = com.GameInterface.Utils.GetServerSyncedTime();
		timeLeft = timeLeft - time;
		var totalMinutes = timeLeft/60;
		var hours = totalMinutes/60;
		var hoursString = String(Math.floor(hours));
		if (hoursString.length == 1) { hoursString = "0" + hoursString; }
		var seconds = timeLeft%60;
		var secondsString = String(Math.floor(seconds));
		if (secondsString.length == 1) { secondsString = "0" + secondsString; }
		var minutes = totalMinutes%60;
		var minutesString = String(Math.floor(minutes));
		if (minutesString.length == 1) { minutesString = "0" + minutesString; }
		return hoursString + ":" + minutesString + ":" + secondsString;
	}
	static function isActive(array, id) {
		for (var i in array) {
			if (array[i].m_MissionId == id) return true;
		}
	}

	// itemID -> agentID
	static function hasAgent(dossierID:Number) {
		switch (dossierID) {
			case 9399700:// virgil
				return AgentSystem.HasAgent(223);
			case 9399761:// sarah
				return AgentSystem.HasAgent(225);
			case 9399728: // ibrahim
				return AgentSystem.HasAgent(221);
			case 9399726:// calum
				return AgentSystem.HasAgent(212);
			case 9399752:// carlos
				return AgentSystem.HasAgent(213);
			case 9399746:// siobhan
				return AgentSystem.HasAgent(238);
			default:
				return false;
		}
	}

	// Returns true if mission is part of uncompleted mission chain
	static function isNewChainMission(id:Number, mission:AgentSystemMission) {
		switch(id){
			case 2781: // The Lost Conquistador
			case 2782: // The Trail of the Conquistador
			case 2783: // Chasing Jeronimo
			case 2784: // Night of the Transdimensional Fish People
			case 2785: // Courting the Conquistador
				if (LoreBase.IsLocked(11060)) { // Achievement: A Man of Principle
					return "Jerónimo: "+mission.m_MissionName
				}
				return;
			case 2786: // The Hidden Expedition
			case 2787: // The Great Map Burglary
			case 2788: // The Expedition into Triangle
			case 2789: // Attack of the Conquistador Cadavers
			case 2790: // Mysteries of the Sphere
				if (LoreBase.IsLocked(11061)) {
					return "Jerónimo2: "+mission.m_MissionName
				}
				return;
			case 2801: // The Agartha Cartographer
			case 2802: // Mapping the Past 
			case 2795: // Into Deep Time
			case 2804: // Once Again Into Agartha
			case 2797: // The Future is Now
				if (LoreBase.IsLocked(11062)) { // Achievements: Exploratory Cartographer
					return "Jerónimo3: "+mission.m_MissionName
				}
				return;
		
			case 2806: // The Fungoid Mystery
			case 2799: // Spores from Beyond
			case 2808: // The Horror in Fungus
				if (LoreBase.IsLocked(11063)) { // Achievements: Observing the Impossible
					return "Jerónimo4: "+mission.m_MissionName
				}
				return;
			case 2809: // Into Dark Agartha
			case 2810: // The Conquistador's Secrets
			case 2811: // The Riddle of Dark Agartha
			case 2812: // The Reluctant Conquistador
			case 2813: // Again Into the Void
				if (LoreBase.IsLocked(11064)) { // Achievements: Once More Unto the Void
					return "Jerónimo5: "+mission.m_MissionName
				}
				return;
			case 344: // Dante's 1-9 circle
			case 345:
			case 346:
			case 347:
			case 348:
			case 349:
			case 350:
			case 351:
			case 352:
			case 353: // Dante's Devil
				if (LoreBase.IsLocked(10735)){
					return "Dante: " + mission.m_MissionName
				}
				return;
			case 373: // The Fountain of Youth
			case 379: // Subterranean Lost and Found
				if (LoreBase.IsLocked(10736)){
					return "Guatemala: " + mission.m_MissionName
				}
				return;
			default:
				return false;
		}
		
	}
}