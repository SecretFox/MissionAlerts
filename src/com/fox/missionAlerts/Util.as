import com.GameInterface.AgentSystem;
import com.GameInterface.DistributedValue;
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
			case 9399700:// virgil x
				return AgentSystem.HasAgent(223);
			case 9399761:// sarah x
				return AgentSystem.HasAgent(225);
			case 9399728: // ibrahim x
				return AgentSystem.HasAgent(221);
			case 9399726:// calum x
				return AgentSystem.HasAgent(212);
			case 9399752:// carlos x
				return AgentSystem.HasAgent(213);
			case 9399746:// siobhan x
				return AgentSystem.HasAgent(238);
			default:
				return false;
		}
	}
}