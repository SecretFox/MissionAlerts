import com.GameInterface.AgentSystem;
import com.GameInterface.AgentSystemMission;
import com.GameInterface.Chat;
import com.GameInterface.DistributedValue;
import com.GameInterface.DistributedValueBase;
import com.GameInterface.UtilsBase;
import com.Utils.Archive;
import com.Utils.LDBFormat;
import com.fox.missionAlerts.Util;
import mx.utils.Delegate;

class com.fox.missionAlerts.Main {
	private var dAlertVanity:DistributedValue;
	private var dAlertPurple:DistributedValue;
	private var dAlertBlue:DistributedValue;
	private var dAlertDossier:DistributedValue;
	private var dAlertChain:DistributedValue;
	private var dAlertSpecial:DistributedValue;
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
		dAlertChain = DistributedValue.Create("MissionAlerts_Chain");
		dAlertSpecial = DistributedValue.Create("MissionAlerts_Special");
		dFifo = DistributedValue.Create("MissionAlerts_Fifo");
		dChat = DistributedValue.Create("MissionAlerts_Chat");
	}
	private function Load() {
		AgentSystem.SignalMissionCompleted.Connect(CheckAlertsBuffer, this);
		AgentSystem.SignalAvailableMissionsUpdated.Connect(CheckAlertsBuffer, this);
		AgentSystem.SignalActiveMissionsUpdated.Connect(CheckAlertsBuffer, this);

	}
	private function Unload() {
		AgentSystem.SignalMissionCompleted.Disconnect(CheckAlertsBuffer, this);
		AgentSystem.SignalAvailableMissionsUpdated.Disconnect(CheckAlertsBuffer, this);
		AgentSystem.SignalActiveMissionsUpdated.Disconnect(CheckAlertsBuffer, this);
	}
	public function Activate(config:Archive) {
		dAlertVanity.SetValue(config.FindEntry("alert_vanity", true));
		dAlertPurple.SetValue(config.FindEntry("alert_purple", true));
		dAlertBlue.SetValue(config.FindEntry("alert_blue", true));
		dAlertDossier.SetValue(config.FindEntry("alert_dossier", true));
		dAlertChain.SetValue(config.FindEntry("alert_chain", true));
		dAlertSpecial.SetValue(config.FindEntry("alert_special", true));
		dFifo.SetValue(config.FindEntry("alert_fifo", true));
		dChat.SetValue(config.FindEntry("alert_chat", true));
		CheckAlertsBuffer();
	}
	public function Deactivate() {
		var conf:Archive = new Archive();
		conf.AddEntry("alert_vanity", dAlertVanity.GetValue());
		conf.AddEntry("alert_purple", dAlertPurple.GetValue());
		conf.AddEntry("alert_blue", dAlertBlue.GetValue());
		conf.AddEntry("alert_dossier", dAlertDossier.GetValue());
		conf.AddEntry("alert_chain", dAlertChain.GetValue());
		conf.AddEntry("alert_special", dAlertSpecial.GetValue());
		conf.AddEntry("alert_fifo", dFifo.GetValue());
		conf.AddEntry("alert_chat", dChat.GetValue());
		return conf
	}
	// has to be ran after icon has updated
	// Hooking the icon properly is annoying since it resets OnModuleActivated
	private function CheckAlertsBuffer() {
		clearTimeout(checkTimeout);
		checkTimeout = setTimeout(Delegate.create(this, CheckAlerts), 500);
	}
	private function CheckAlerts() {
		var Alerts = new Array();
		var currentMissions = AgentSystem.GetActiveMissions();
		for (var i=1; i <= 6; i++) {
			var availableMissions:Array = AgentSystem.GetMissionsByStarRating(i);
			for (var j=0; j < availableMissions.length; j++) {
				var mission:AgentSystemMission = availableMissions[j];
				if (mission.m_MissionId){
					var alert = CheckAlert(mission.m_Rewards, mission, mission.m_StarRating);
					if (alert && !Util.isActive(currentMissions, mission.m_MissionId)) {
						Alerts.push([mission, alert]);
					}
				}
			}
		}
		if (Alerts.length > 0) {
			for (var i in Alerts) {
				var found;
				for (var y in prev_alerts) {
					if (prev_alerts[y][0].m_MissionId == Alerts[i][0].m_MissionId) {
						found = true;
					}
				}
				if (!found) {
					if (DistributedValueBase.GetDValue("MissionAlerts_Chat")) {
						UtilsBase.PrintChatText("<font color=\"#FF0000\">Mission Alert: </font>" + Alerts[i][1]);
					}
					if (DistributedValueBase.GetDValue("MissionAlerts_Fifo")) {
						Chat.SignalShowFIFOMessage.Emit("Mission Alert: "+Alerts[i][1], 0);
					}
				}
			}
			Util.SetIcon(Alerts);
		}
		prev_alerts = Alerts;
	}
	private function CheckAlert(rewardarray:Array, mission:AgentSystemMission, tier:Number) {
		if (dAlertSpecial.GetValue() && mission.m_StarRating == 6){
			return "Special Mission";
		}
		var ret:String = "Tier" + tier + ": ";
		var res:Array = [];
		var chain;
		for (var i in rewardarray) {
			if (dAlertVanity.GetValue() && rewardarray[i] == 9407816) {
				res.push("Vanity Bag");
			}
			else if (dAlertPurple.GetValue() && rewardarray[i] == 9400616) {
				res.push("Purple Bag");
			}
			else if (dAlertBlue.GetValue() && rewardarray[i] == 9400614) {
				res.push("Blue Bag");
			}
			else if (dAlertDossier.GetValue() &&
				LDBFormat.LDBGetText(50200, rewardarray[i]).toLowerCase().indexOf("dossier") >= 0 && 
				!Util.hasAgent(rewardarray[i]))
			{
				res.push(LDBFormat.LDBGetText(50200, rewardarray[i]));
			}
		}
		if (dAlertChain.GetValue()){
			chain = Util.isNewChainMission(mission.m_MissionId, mission);
		}
		if (res.length > 0 || chain){
			if (!chain){
				return ret + res.join(" + ");
			}
			else if (res.length > 0){
				return [chain,res.join(" + ")].join("+")
			}
			return chain;
		}
	}

}