import com.GameInterface.AgentSystem;
import com.GameInterface.AgentSystemMission;
import com.GameInterface.Chat;
import com.GameInterface.DistributedValue;
import com.GameInterface.DistributedValueBase;
import com.GameInterface.Tooltip.TooltipUtils;
import com.GameInterface.UtilsBase;
import com.Utils.Archive;
import com.Utils.Colors;
import com.Utils.LDBFormat;
import mx.utils.Delegate;

class com.fox.missionAlerts.Main {
	private var dAlertVanity:DistributedValue;
	private var dAlertPurple:DistributedValue;
	private var dAlertBlue:DistributedValue;
	private var dAlertDossier:DistributedValue;
	private var dFifo:DistributedValue;
	private var dChat:DistributedValue;
	private var checkTimeout:Number;
	private var prev_alerts:Array;
	
	public static function main(swfRoot:MovieClip):Void {
		var s_app = new Main(swfRoot);
		swfRoot.onLoad = function() {s_app.Load()};
		swfRoot.onUnload = function() {s_app.Unload()};
		swfRoot.OnModuleActivated = function(config:Archive) { s_app.Activate(config); };
		swfRoot.OnModuleDeactivated = function() { return s_app.Deactivate(); };
	}

	public function Main() {
		dAlertVanity = DistributedValue.Create("MissionAlerts_Vanity");
		dAlertPurple = DistributedValue.Create("MissionAlerts_Purple");
		dAlertBlue = DistributedValue.Create("MissionAlerts_Blue");
		dAlertDossier = DistributedValue.Create("MissionAlerts_Dossier");
		dFifo = DistributedValue.Create("MissionAlerts_Chat");
		dChat = DistributedValue.Create("MissionAlerts_Fifo");
	}
	private function Load(){
		AgentSystem.SignalMissionCompleted.Connect(CheckAlertsBuffer, this);
		AgentSystem.SignalAvailableMissionsUpdated.Connect(CheckAlertsBuffer, this);
		AgentSystem.SignalActiveMissionsUpdated.Connect(CheckAlertsBuffer, this);
	}
	private function Unload(){
		AgentSystem.SignalMissionCompleted.Disconnect(CheckAlertsBuffer, this);
		AgentSystem.SignalAvailableMissionsUpdated.Disconnect(CheckAlertsBuffer, this);
		AgentSystem.SignalActiveMissionsUpdated.Disconnect(CheckAlertsBuffer, this);
	}
	// has to be ran after icon has updated
	// Hooking the icon properly is annoying since it resets OnModuleActivated
	private function CheckAlertsBuffer(){
		clearTimeout(checkTimeout);
		checkTimeout = setTimeout(Delegate.create(this, CheckAlerts), 500);
	}
	// icon might not be loaded if this is called before topbar loads
	private function SetIcon(data){
		if (!_root.mainmenuwindow.m_AgentIconContainer){
			setTimeout(Delegate.create(this, SetIcon), 500, data);
		}
		TooltipUtils.AddTextTooltip(_root.mainmenuwindow.m_AgentIconContainer,data);
		_root.mainmenuwindow.m_AgentIconContainer._alpha = 100;
		_root.mainmenuwindow.m_AgentIcon.enabled = true;
		Colors.ApplyColor(_root.mainmenuwindow.m_AgentIcon, 0xF904FF);
		_root.mainmenuwindow.Layout();
	}
	private function CheckAlerts(){
		var Alerts = new Array();
		var currentMissions = AgentSystem.GetActiveMissions();
		for (var i=1; i <= 6; i++){
			var availableMissions:Array = AgentSystem.GetMissionsByStarRating(i);
			for (var j=0; j < availableMissions.length; j++)
			{
				var mission:AgentSystemMission = availableMissions[j];
				var alert = this.CheckAlert(mission.m_Rewards, mission, mission.m_StarRating);
				if (alert && !this.isActive(currentMissions, mission.m_MissionId)){
					Alerts.push(alert);
				}
			}
		}
		if (Alerts.length > 0){
			for (var i in Alerts){
				var found;
				for (var y in prev_alerts){
					if (prev_alerts[y] == Alerts[i]) found = true;
				}
				if (!found){
					if (DistributedValueBase.GetDValue("MissionAlerts_Fifo")){
						UtilsBase.PrintChatText("<font color=\"#FF0000\">Mission Alert: </font>" + Alerts[i]);
					}
					if (DistributedValueBase.GetDValue("MissionAlerts_Chat")){
						Chat.SignalShowFIFOMessage.Emit("Mission Alert: "+Alerts[i], 0);
					}
				}
			}
			SetIcon(Alerts.join("\n"));
		}
		prev_alerts = Alerts;
	}
	private function CheckAlert(rewardarray:Array, mission:AgentSystemMission, tier:Number){
		var ret:String = "Tier" + tier + ": ";
		for (var i in rewardarray){
			if (dAlertVanity.GetValue() && rewardarray[i] == 9407816){
				return ret + "Vanity Bag"
			}
			else if (dAlertPurple.GetValue() && rewardarray[i] == 9400616){
				return ret + "Purple Bag"
			}
			else if (dAlertBlue.GetValue() && rewardarray[i] == 9400614){
				return ret + "Blue Bag"
			}
			else if (dAlertDossier.GetValue() && 
				LDBFormat.LDBGetText(50200, rewardarray[i]).toLowerCase().indexOf("dossier") >= 0)
			{
				return ret + LDBFormat.LDBGetText(50200, rewardarray[i]);
			}
		}
	}
	private function isActive(array, id){
		for (var i in array){
			if (array[i].m_MissionId == id) return true;
		}
	}
	
	public function Activate(config:Archive){
		dAlertVanity.SetValue(config.FindEntry("alert_vanity", true));
		dAlertPurple.SetValue(config.FindEntry("alert_purple", true));
		dAlertBlue.SetValue(config.FindEntry("alert_blue", true));
		dAlertDossier.SetValue(config.FindEntry("alert_dossier", true));
		dFifo.SetValue(config.FindEntry("alert_fifo", true));
		dChat.SetValue(config.FindEntry("alert_chat", true));
		CheckAlertsBuffer();
	}
	public function Deactivate(){
		var conf:Archive = new Archive();
		conf.AddEntry("alert_vanity", dAlertVanity.GetValue());
		conf.AddEntry("alert_purple", dAlertPurple.GetValue());
		conf.AddEntry("alert_blue", dAlertBlue.GetValue());
		conf.AddEntry("alert_dossier", dAlertDossier.GetValue());
		conf.AddEntry("alert_fifo", dFifo.GetValue());
		conf.AddEntry("alert_chat", dChat.GetValue());
		return conf
	}

}