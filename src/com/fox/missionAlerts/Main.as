import com.GameInterface.AgentSystem;
import com.GameInterface.AgentSystemMission;
import com.GameInterface.Chat;
import com.GameInterface.DistributedValue;
import com.GameInterface.DistributedValueBase;
import com.GameInterface.InventoryBase;
import com.GameInterface.InventoryItem;
import com.GameInterface.UtilsBase;
import com.Utils.Archive;
import com.fox.missionAlerts.Util;
import mx.utils.Delegate;

class com.fox.missionAlerts.Main {
	private var dAlertVanity:DistributedValue;
	private var dAlertPurple:DistributedValue;
	private var dAlertBlue:DistributedValue;
	private var dAlertDossier:DistributedValue;
	private var dAlertChain:DistributedValue;
	private var dAlertSpecial:DistributedValue;
	private var dAlertJeronimo:DistributedValue;
	private var dAlertUrgent:DistributedValue;
	private var dAlertOutstanding:DistributedValue;
	private var dFifo:DistributedValue;
	private var dChat:DistributedValue;
	private var checkTimeout:Number;
	private var prev_alerts:Array;
	private var loaded:Boolean;
	private var runtimeout;

	public static function main(swfRoot:MovieClip):Void {
		var s_app = new Main(swfRoot);
		swfRoot.onLoad = function(){s_app.Load()};
		swfRoot.onUnload = function(){s_app.Unload()};
		swfRoot.OnModuleActivated = function(config:Archive) { s_app.Activate(config); };
		swfRoot.OnModuleDeactivated = function() { return s_app.Deactivate(); };
	}
	
	public function Main() {
		dAlertVanity = DistributedValue.Create("MissionAlerts_Vanity");
		dAlertPurple = DistributedValue.Create("MissionAlerts_Epic");
		dAlertBlue = DistributedValue.Create("MissionAlerts_Superior");
		dAlertDossier = DistributedValue.Create("MissionAlerts_Dossier");
		dAlertChain = DistributedValue.Create("MissionAlerts_Chain");
		dAlertSpecial = DistributedValue.Create("MissionAlerts_Special");
		dAlertJeronimo = DistributedValue.Create("MissionAlerts_JeronimoItems");
		dAlertOutstanding = DistributedValue.Create("MissionAlerts_IgnoreOutstanding");
		dAlertUrgent = DistributedValue.Create("MissionAlerts_Urgent");
		dFifo = DistributedValue.Create("MissionAlerts_Fifo");
		dChat = DistributedValue.Create("MissionAlerts_Chat");
	}
	
	public function Load() {
		AgentSystem.SignalMissionCompleted.Connect(RunBuffer, this);
		AgentSystem.SignalAvailableMissionsUpdated.Connect(RunBuffer, this);
		AgentSystem.SignalActiveMissionsUpdated.Connect(RunBuffer, this);
	}
	
	public function Unload() {
		AgentSystem.SignalMissionCompleted.Disconnect(RunBuffer, this);
		AgentSystem.SignalAvailableMissionsUpdated.Disconnect(RunBuffer, this);
		AgentSystem.SignalActiveMissionsUpdated.Disconnect(RunBuffer, this);
	}
	
	public function Activate(config:Archive) {
		if (!loaded){
			loaded = true;
			dAlertVanity.SetValue(config.FindEntry("alert_vanity", true));
			dAlertPurple.SetValue(config.FindEntry("alert_purple", true));
			dAlertBlue.SetValue(config.FindEntry("alert_blue", true));
			dAlertDossier.SetValue(config.FindEntry("alert_dossier", true));
			dAlertChain.SetValue(config.FindEntry("alert_chain", true));
			dAlertSpecial.SetValue(config.FindEntry("alert_special", true));
			dAlertJeronimo.SetValue(config.FindEntry("alert_jeronimo", true));
			dAlertUrgent.SetValue(config.FindEntry("alert_urgent", true));
			dAlertOutstanding.SetValue(config.FindEntry("alert_outstanding", false));
			
			dFifo.SetValue(config.FindEntry("alert_fifo", true));
			dChat.SetValue(config.FindEntry("alert_chat", true));
		}
		Hook();
	}
	public function Deactivate() {
		var conf:Archive = new Archive();
		conf.AddEntry("alert_vanity", dAlertVanity.GetValue());
		conf.AddEntry("alert_purple", dAlertPurple.GetValue());
		conf.AddEntry("alert_blue", dAlertBlue.GetValue());
		conf.AddEntry("alert_dossier", dAlertDossier.GetValue());
		conf.AddEntry("alert_chain", dAlertChain.GetValue());
		conf.AddEntry("alert_special", dAlertSpecial.GetValue());
		conf.AddEntry("alert_jeronimo", dAlertJeronimo.GetValue());
		conf.AddEntry("alert_outstanding", dAlertOutstanding.GetValue());
		conf.AddEntry("alert_urgent", dAlertUrgent.GetValue());
		conf.AddEntry("alert_fifo", dFifo.GetValue());
		conf.AddEntry("alert_chat", dChat.GetValue());
		return conf
	}
	// has to be ran after icon has updated
	// Hooking the icon properly is annoying since it resets OnModuleActivated
	private function Hook() {
		if (!_root.mainmenuwindow.UpdateAgentSystemIcon){
			setTimeout(Delegate.create(this, Hook), 500);
			return
		}
		if (_root.mainmenuwindow.AgentIconHook){
			return
		}
		_root.mainmenuwindow.UpdateAgentSystemIcon = Delegate.create(this, RunBuffer);
		AgentSystem.SignalMissionCompleted.Disconnect(_root.mainmenuwindow.UpdateAgentSystemIcon);
		AgentSystem.SignalAvailableMissionsUpdated.Disconnect(_root.mainmenuwindow.UpdateAgentSystemIcon);
		AgentSystem.SignalActiveMissionsUpdated.Disconnect(_root.mainmenuwindow.UpdateAgentSystemIcon);
		_root.mainmenuwindow.AgentIconHook = true;
		_root.mainmenuwindow.UpdateAgentSystemIcon();
	}
	
	private function RunBuffer(){
		clearTimeout(runtimeout);
		runtimeout = setTimeout(Delegate.create(this, CheckAlerts), 500);
	}
	
	private function CheckAlerts() {
		var Alerts = new Array();
		var hasComplete:Boolean;
		var currentMissions = AgentSystem.GetActiveMissions();
		for (var i=1; i <= 6; i++) {
			var availableMissions:Array = AgentSystem.GetMissionsByStarRating(i);
			for (var j=0; j < availableMissions.length; j++) {
				var mission:AgentSystemMission = availableMissions[j];
				if (mission.m_MissionId){
					var alert:Array = CheckAlert(mission);
					if ((alert[1].length > 0 || alert[2] || alert[3]) && !Util.isActive(currentMissions, mission.m_MissionId)) {
						Alerts.push([mission, alert]);
					}
				}
			}
		}
		var activeMissions:Array = AgentSystem.GetActiveMissions();
		for (var i=0; i < activeMissions.length; i++){
			if (AgentSystem.IsMissionComplete(activeMissions[i].m_MissionId)){
				hasComplete = true;
				break;
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
						UtilsBase.PrintChatText("<font color=\"#FF0000\">Mission Alert: </font>" + Util.CreateChatFeedbackString(Alerts[i][1]));
					}
					if (DistributedValueBase.GetDValue("MissionAlerts_Fifo")) {
						Chat.SignalShowFIFOMessage.Emit("<font color=\"#FF0000\">Mission Alert: </font>" + Util.CreateFifoFeedbackString(Alerts[i][1]), 0);
					}
				}
			}
		}
		Util.SetIcon(Alerts, hasComplete);
		prev_alerts = Alerts;
	}
	
	private function CheckAlert(mission:AgentSystemMission) {
		if (dAlertSpecial.GetValue() && mission.m_StarRating == 6){
			return [[],[],"Special Mission"];
		}
		var ret:String = "Tier" + mission.m_StarRating + ": ";
		var items:Array = [];
		var chain;
		var urgent;
		var rewards:Array = [mission.m_Rewards, mission.m_BonusRewards];
		for (var type = 0; type < rewards.length;type++){
			for (var rewardSlot = 0; rewardSlot < rewards[type].length;rewardSlot++) {
				var itemID = rewards[type][rewardSlot];
				var item:InventoryItem = InventoryBase.CreateACGItemFromTemplate(itemID);
				if (dAlertVanity.GetValue() && itemID == 9407816 && 
					(!dAlertOutstanding.GetValue() || Util.IsNotLast(rewardSlot,rewards,type)))
				{
					items.push(itemID);
				}
				else if (dAlertPurple.GetValue() && itemID == 9400616 && 
					(!dAlertOutstanding.GetValue() || Util.IsNotLast(rewardSlot,rewards,type)))
				{
					items.push(itemID);
				}
				else if (dAlertBlue.GetValue() && itemID == 9400614 && 
					(!dAlertOutstanding.GetValue() || Util.IsNotLast(rewardSlot,rewards,type)))
				{
					items.push(itemID);
				}
				else if (dAlertDossier.GetValue() &&
					item.m_Name.toLowerCase().indexOf("dossier") >= 0 && 
					!Util.hasAgent(itemID))
				{
					items.push(itemID);
				}
				else if ( dAlertJeronimo.GetValue() &&
					Util.IsJeronimoItem(itemID))
				{
					items.push(itemID);
				}
			}
		}
		if (dAlertUrgent.GetValue() && mission.m_Rarity == 170){
			urgent = "Urgent";
			if (items.length == 0){
				urgent += ": "+mission.m_MissionName;
			}else{
				urgent += " + "
			}
		}
		if (dAlertChain.GetValue()){
			chain = Util.isNewChainMission(mission.m_MissionId, mission);
		}
		return[ret, items, chain, urgent];
	}

}