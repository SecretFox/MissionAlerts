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
import com.fox.missionAlerts.data.Alert;
import mx.utils.Delegate;

class com.fox.missionAlerts.Main
{
	private var dAlertVanity:DistributedValue;
	private var dAlertPurple:DistributedValue;
	private var dAlertBlue:DistributedValue;
	private var dAlertDossier:DistributedValue;
	private var dAlertChain:DistributedValue;
	private var dAlertSpecial:DistributedValue;
	private var dAlertJeronimo:DistributedValue;
	private var dAlertUrgent:DistributedValue;
	private var dAlertOutstanding:DistributedValue;
	private var dAlertOnCompletion:DistributedValue;
	private var dClaimOnCompletion:DistributedValue;
	private var dCustom:DistributedValue;
	private var dFifo:DistributedValue;
	private var dChat:DistributedValue;
	private var checkTimeout:Number;
	private var lastCompleted:Number;
	private var previousAlerts:Array = [];
	private var loaded:Boolean;
	private var runtimeout;

	public static function main(swfRoot:MovieClip):Void
	{
		var s_app = new Main(swfRoot);
		swfRoot.onLoad = function() {s_app.Load()};
		swfRoot.onUnload = function() {s_app.Unload()};
		swfRoot.OnModuleActivated = function(config:Archive) { s_app.Activate(config); };
		swfRoot.OnModuleDeactivated = function() { return s_app.Deactivate(); };
	}

	public function Main()
	{
		dAlertVanity = DistributedValue.Create("MissionAlerts_Vanity");
		dAlertPurple = DistributedValue.Create("MissionAlerts_Epic");
		dAlertBlue = DistributedValue.Create("MissionAlerts_Superior");
		dAlertDossier = DistributedValue.Create("MissionAlerts_Dossier");
		dAlertChain = DistributedValue.Create("MissionAlerts_Chain");
		dAlertSpecial = DistributedValue.Create("MissionAlerts_Special");
		dAlertJeronimo = DistributedValue.Create("MissionAlerts_JeronimoItems");
		dAlertOutstanding = DistributedValue.Create("MissionAlerts_IgnoreOutstanding");
		dAlertUrgent = DistributedValue.Create("MissionAlerts_Urgent");
		dCustom = DistributedValue.Create("MissionAlerts_Custom");
		dFifo = DistributedValue.Create("MissionAlerts_Fifo");
		dChat = DistributedValue.Create("MissionAlerts_Chat");
		dAlertOnCompletion = DistributedValue.Create("MissionAlerts_AlertOnCompletion");
		dClaimOnCompletion = DistributedValue.Create("MissionAlerts_ClaimOnCompletion");
	}

	public function Load()
	{
		AgentSystem.SignalMissionCompleted.Connect(RunBuffer, this);
		AgentSystem.SignalAvailableMissionsUpdated.Connect(RunBuffer, this);
		AgentSystem.SignalActiveMissionsUpdated.Connect(RunBuffer, this);
		dAlertOnCompletion.SignalChanged.Connect(SetCompletionAlert, this);
		dClaimOnCompletion.SignalChanged.Connect(SetCompletionAlert, this);
	}

	public function Unload()
	{
		AgentSystem.SignalMissionCompleted.Disconnect(RunBuffer, this);
		AgentSystem.SignalAvailableMissionsUpdated.Disconnect(RunBuffer, this);
		AgentSystem.SignalActiveMissionsUpdated.Disconnect(RunBuffer, this);
		dAlertOnCompletion.SignalChanged.Disconnect(SetCompletionAlert, this);
		dClaimOnCompletion.SignalChanged.Disconnect(SetCompletionAlert, this);
	}

	public function Activate(config:Archive)
	{
		if (!loaded)
		{
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
			dCustom.SetValue(config.FindEntry("alert_custom", false));
			dFifo.SetValue(config.FindEntry("alert_fifo", true));
			dChat.SetValue(config.FindEntry("alert_chat", true));
			dAlertOnCompletion.SetValue(config.FindEntry("alert_completion", false));
			dClaimOnCompletion.SetValue(config.FindEntry("alert_claimOnCompletion", false));
			SetCompletionAlert();
			CheckCompletionAlerts();
		}
		Hook();
	}
	public function Deactivate()
	{
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
		conf.AddEntry("alert_custom", dCustom.GetValue());
		conf.AddEntry("alert_completion", dAlertOnCompletion.GetValue());
		conf.AddEntry("alert_claimOnCompletion", dClaimOnCompletion.GetValue());
		return conf;
	}
	// has to be ran after icon has updated
	// Hooking the icon properly is annoying since it resets OnModuleActivated
	private function Hook()
	{
		if (!_root.mainmenuwindow.UpdateAgentSystemIcon)
		{
			setTimeout(Delegate.create(this, Hook), 500);
			return
		}
		if (_root.mainmenuwindow.AgentIconHook)
		{
			return
		}
		_root.mainmenuwindow.UpdateAgentSystemIcon = Delegate.create(this, RunBuffer);
		AgentSystem.SignalMissionCompleted.Disconnect(_root.mainmenuwindow.UpdateAgentSystemIcon);
		AgentSystem.SignalAvailableMissionsUpdated.Disconnect(_root.mainmenuwindow.UpdateAgentSystemIcon);
		AgentSystem.SignalActiveMissionsUpdated.Disconnect(_root.mainmenuwindow.UpdateAgentSystemIcon);
		_root.mainmenuwindow.AgentIconHook = true;
		_root.mainmenuwindow.UpdateAgentSystemIcon();
	}

	private function SetCompletionAlert(dv:DistributedValue)
	{
		if (dAlertOnCompletion.GetValue() || dClaimOnCompletion.GetValue())
		{
			if (!AgentSystem.SignalMissionCompleted.IsSlotConnected(GenerateCompletionAlertBuffer))
			{
				AgentSystem.SignalMissionCompleted.Connect(GenerateCompletionAlertBuffer, this);
			}
		}
		else
		{
			AgentSystem.SignalMissionCompleted.Disconnect(GenerateCompletionAlertBuffer, this);
		}
	}

	private function CheckCompletionAlerts()
	{
		var currentMissions = AgentSystem.GetActiveMissions();
		for (var i in currentMissions)
		{
			if (AgentSystem.IsMissionComplete(AgentSystemMission(currentMissions[i]).m_MissionId))
			{
				GenerateCompletionAlert(AgentSystemMission(currentMissions[i]).m_MissionId);
			}
		}
	}

	// Prevents mission completed spam if the signal gets sent multiple times
	private function GenerateCompletionAlertBuffer(missionID)
	{
		if (lastCompleted != missionID)
		{
			lastCompleted = missionID;
			setTimeout(Delegate.create(this, GenerateCompletionAlert), 1000, missionID);
		}
	}

	private function GenerateCompletionAlert(missionID:Number)
	{
		if (dAlertOnCompletion.GetValue())
		{
			var currentMissions = AgentSystem.GetActiveMissions();
			for (var i in currentMissions)
			{
				if (AgentSystemMission(currentMissions[i]).m_MissionId == missionID)
				{
					if (DistributedValueBase.GetDValue("MissionAlerts_Chat"))
					{
						UtilsBase.PrintChatText("<font color=\"#00ff16\">Mission Completed: </font>" + AgentSystemMission(currentMissions[i]).m_MissionName);
					}
					if (DistributedValueBase.GetDValue("MissionAlerts_Fifo"))
					{
						Chat.SignalShowFIFOMessage.Emit("<font color=\"#00ff16\">Mission Completed: </font>" + AgentSystemMission(currentMissions[i]).m_MissionName, 0);
					}
					break;
				}
			}
		}
		if (dClaimOnCompletion.GetValue())
		{
			AgentSystem.AcceptMissionReward(missionID);
			if (_global.com.fox.dd.Main.UpdateCalled)
			{
				_global.com.fox.dd.Main.UpdateCalled.Emit();
			}
		}
	}

	private function RunBuffer()
	{
		clearTimeout(runtimeout);
		runtimeout = setTimeout(Delegate.create(this, CheckAlerts), 500);
	}

	private function CheckAlerts()
	{
		var activeAlerts:Array = [];
		var hasCompletedMission:Boolean;
		var currentMissions = AgentSystem.GetActiveMissions();
		var custom = dCustom.GetValue();
		var custom_data = custom.split(";");
		for (var tier = 1; tier <= 6; tier++)
		{
			var availableMissions:Array = AgentSystem.GetMissionsByStarRating(tier);
			for (var slot = 0; slot < availableMissions.length; slot++)
			{
				var mission:AgentSystemMission = availableMissions[slot];
				if (mission.m_MissionId)
				{
					if (!Util.isActive(currentMissions, mission.m_MissionId))
					{
						var alert:Alert = CheckAlert(mission, custom, custom_data);
						if
						(	alert.items.length > 0 ||
								alert.specialMissionText ||
								alert.chainText ||
								alert.customText
						)
						{
							activeAlerts.push(alert);
						}
					}
				}
			}
		}
		var activeMissions:Array = AgentSystem.GetActiveMissions();
		for (var i = 0; i < activeMissions.length; i++)
		{
			if (AgentSystem.IsMissionComplete(activeMissions[i].m_MissionId))
			{
				hasCompletedMission = true;
				break;
			}
		}
		if (activeAlerts.length > 0)
		{
			for (var i in activeAlerts)
			{
				var found = false;
				for (var y in previousAlerts)
				{
					if (
						Alert(previousAlerts[y]).missionID == Alert(activeAlerts[i]).missionID &&
						Alert(previousAlerts[y]).refreshTime == Alert(activeAlerts[i]).refreshTime
					)
					{
						found = true;
						break;
					}
				}
				if (!found)
				{
					if (DistributedValueBase.GetDValue("MissionAlerts_Chat"))
					{
						UtilsBase.PrintChatText("<font color=\"#FF0000\">Mission Alert: </font>" + Util.CreateChatFeedbackString(activeAlerts[i]));
					}
					if (DistributedValueBase.GetDValue("MissionAlerts_Fifo"))
					{
						Chat.SignalShowFIFOMessage.Emit("<font color=\"#FF0000\">Mission Alert: </font>" + Util.CreateFifoFeedbackString(activeAlerts[i]), 0);
					}
				}
			}
		}
		Util.SetIcon(activeAlerts, hasCompletedMission);
		previousAlerts = activeAlerts.concat();
	}

	private function CheckAlert(mission:AgentSystemMission, custom, custom_data):Alert
	{
		var alertData:Alert = new Alert();
		alertData.missionID = mission.m_MissionId;
		alertData.missionName = mission.m_MissionName;
		alertData.missionTierText = "Tier" + mission.m_StarRating + ": ";
		alertData.refreshTime = AgentSystem.GetMissionRefreshTime(mission.m_MissionId);

		if (dAlertSpecial.GetValue() && mission.m_StarRating == 6)
		{
			alertData.specialMissionText = "Special Mission " + mission.m_MissionName;
		}
		alertData.items = [];
		var rewards:Array = [mission.m_Rewards, mission.m_BonusRewards];
		for (var type = 0; type < rewards.length; type++)
		{
			for (var rewardSlot = 0; rewardSlot < rewards[type].length; rewardSlot++)
			{
				var itemID = rewards[type][rewardSlot];
				var item:InventoryItem = InventoryBase.CreateACGItemFromTemplate(itemID);
				// Vanity
				if (dAlertVanity.GetValue() && itemID == 9407816)
				{
					alertData.items.push(itemID);
				}
				// Purple
				else if (dAlertPurple.GetValue() && itemID == 9400616 &&
						 (!dAlertOutstanding.GetValue() || Util.IsNotLast(rewardSlot,rewards,type)))
				{
					alertData.items.push(itemID);
				}
				// Blue
				else if (dAlertBlue.GetValue() && itemID == 9400614 &&
						 (!dAlertOutstanding.GetValue() || Util.IsNotLast(rewardSlot,rewards,type)))
				{
					alertData.items.push(itemID);
				}
				// Dossier
				else if (dAlertDossier.GetValue() &&
						 item.m_Name.toLowerCase().indexOf("dossier") >= 0 &&
						 !Util.hasAgent(itemID))
				{
					alertData.items.push(itemID);
				}
				// Jeronimo
				else if ( dAlertJeronimo.GetValue() &&
						  Util.IsJeronimoItem(itemID))
				{
					alertData.items.push(itemID);
				}
			}
		}
		// Urgent
		if (dAlertUrgent.GetValue() && mission.m_Rarity == 170)
		{
			alertData.urgentText = "Urgent";
			if (alertData.items.length == 0)
			{
				alertData.urgentText += ": " + mission.m_MissionName;
			}
			else
			{
				alertData.urgentText += " + "
			}
		}
		// MissionChain
		if (dAlertChain.GetValue())
		{
			var chain = Util.isNewChainMission(mission.m_MissionId, mission);
			if (chain)
			{
				alertData.chainText = chain;
				if (alertData.items.length == 0)
				{
					alertData.chainText += ": " + mission.m_MissionName;
				}
				else
				{
					alertData.chainText += " + "
				}
			}
		}

		if (custom)
		{
			var note = Util.IsCustomAlert(mission.m_MissionId, custom_data);
			if (note)
			{
				alertData.customText = "Custom";
				if (note != true) alertData.customText = note;
				if (alertData.items.length == 0)
				{
					alertData.customText += ": " + mission.m_MissionName;
				}
				else
				{
					alertData.customText += " + "
				}
			}
		}
		return alertData;
	}

}