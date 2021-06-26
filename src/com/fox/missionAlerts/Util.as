import com.GameInterface.AgentSystem;
import com.GameInterface.AgentSystemMission;
import com.GameInterface.DistributedValue;
import com.GameInterface.InventoryBase;
import com.GameInterface.InventoryItem;
import com.GameInterface.LoreBase;
import com.GameInterface.Tooltip.TooltipData;
import com.GameInterface.Tooltip.TooltipManager;
import com.GameInterface.UtilsBase;
import com.Utils.Colors;
import com.Utils.LDBFormat;
import com.fox.missionAlerts.data.Alert;
import flash.geom.ColorTransform;
import flash.geom.Transform;
/*
* ...
* @author fox
*/
class com.fox.missionAlerts.Util
{

	static function CreateChatFeedbackString(alert:Alert):String
	{
		if (alert.specialMissionText) return alert.specialMissionText;
		var ret:String = alert.missionTierText;
		if (alert.chainText)
		{
			ret += alert.chainText;
		}
		if (alert.customText)
		{
			ret += alert.customText;
		}
		for (var i in alert.items)
		{
			ret += CreateItemLink(alert.items[i]);
		}
		return ret;
	}

	static function CreateItemLink(itemID:Number):String
	{
		return "<a style=\"text-decoration:none\" href=\"itemref:// " +
		itemID +
		"/0/0/0/0/0/616e09b0:4dd8af57:3b929b98:cf0d4d11/b290805c:29e627ca:b290805c:29e627ca/b290805c:29e627ca:b290805c:29e627ca\">" +
		CreateColoredLink(itemID)+"</a>"
	}

	static function CreateColoredLink(itemID:Number):String
	{
		var item:InventoryItem = InventoryBase.CreateACGItemFromTemplate(itemID);
		return "<font color=\"" + Colors.ColorToHtml(Colors.GetItemRarityColor(item.m_Rarity)) + "\">[" + LDBFormat.LDBGetText(50200,itemID)+"]</font>"
	}

	static function CreateFifoFeedbackString(alert:Alert)
	{
		if (alert.specialMissionText) return alert.specialMissionText;
		var ret:String = alert.missionTierText;
		if (alert.chainText)
		{
			ret += alert.chainText;
		}
		if (alert.customText)
		{
			ret += alert.customText;
		}
		for (var i in alert.items)
		{
			ret += CreateColoredLink(alert.items[i]);
		}
		return ret;
	}

	// icon might not be loaded if this is called before topbar loads
	static function SetIcon(alerts:Array, complete:Boolean)
	{
		var container:MovieClip = _root.mainmenuwindow.m_AgentIconContainer;
		if (!container)
		{
			setTimeout(SetIcon, 500, alerts, complete);
			return
		}
		var icon:MovieClip = _root.mainmenuwindow.m_AgentIconContainer.m_AgentIcon;
		var reload;
		if (!icon.enabled)
		{
			reload = true;
		}
		else
		{
			container._alpha = 0;
			icon.enabled = false;
		}
		if (alerts.length > 0)
		{
			container._alpha = 100;
			icon.enabled = true;
			icon.gotoAndStop("urgent");
			container.onRollOver =  function()
			{
				if (this._visible && this._alpha > 0)
				{
					var tooltipData:TooltipData = new TooltipData();
					var desc:Array = [];
					for (var i in alerts)
					{
						var alert:Alert = alerts[i];
						var content = Util.CreateFifoFeedbackString(alert) + " " + Util.CalculateTimeString(AgentSystem.GetMissionRefreshTime(alert.missionID), alert.missionName)
						desc.push(content);
					}
					tooltipData.AddDescription("<font size='11'>"+desc.join("\n")+"</font>");
					tooltipData.m_Padding = 4;
					tooltipData.m_MaxWidth = 400;
					tooltipData.m_Color = 0xFF8000;
					tooltipData.m_Title = "<font size='14'><b>MissionAlerts v0.6.2</b></font>";
					var delay:Number = DistributedValue.GetDValue("HoverInfoShowDelay");
					this.m_Tooltip = TooltipManager.GetInstance().ShowTooltip( container, undefined, delay, tooltipData );
				}
			}
			container.onRollOut = function()
			{
				if (this.m_Tooltip != undefined)
				{
					this.m_Tooltip.Close();
					this.m_Tooltip = undefined;
				}
			}
		}

		if (complete)
		{
			// no alerts, just color default icon
			if (!icon.enabled)
			{
				icon.enabled = true;
				container._alpha = 100;
				icon.gotoAndStop("complete");
			}
			// create sliced copy of the original and color it white
			else if (!container.m_CopyClip)
			{
				var m_CopyClip:MovieClip = icon.duplicateMovieClip("m_CopyClip", container.getNextHighestDepth());
				m_CopyClip.gotoAndStop("complete");
				var iconTransform:Transform = new Transform(  m_CopyClip );
				var iconColorTransform:ColorTransform = new ColorTransform();
				iconTransform.colorTransform = iconColorTransform;
				m_CopyClip.setMask(null); //crashes without
				com.GameInterface.ProjectUtils.SetMovieClipMask(m_CopyClip, container, icon._height, icon._width/2);
			}
			// make sliced copy visible if it already exists
			else
			{
				container.m_CopyClip._alpha = 100;
			}
		}
		// hide sliced copy
		else
		{
			if (container.m_CopyClip)
			{
				container.m_CopyClip._alpha = 0;
			}
		}
		if (icon.enabled && reload) _root.mainmenuwindow.Layout();
	}

	static function CalculateTimeString(timeLeft,name)
	{
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

	static function isActive(array, id)
	{
		for (var i in array)
		{
			if (array[i].m_MissionId == id) return true;
		}
	}

	// itemID -> agentID
	static function hasAgent(dossierID:Number)
	{
		switch (dossierID)
		{
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

	static function IsJeronimoItem(itemID:Number)
	{
		switch (itemID)
		{
			case 9455193:
			case 9455194:
			case 9455195:
				return true;
			default:
				return false;
		}
	}

	// Returns true if mission is part of uncompleted mission chain
	static function isNewChainMission(id:Number, mission:AgentSystemMission)
	{
		switch (id)
		{
			case 2781: // The Lost Conquistador
			case 2782: // The Trail of the Conquistador
			case 2783: // Chasing Jeronimo
			case 2784: // Night of the Transdimensional Fish People
			case 2785: // Courting the Conquistador
				if (LoreBase.IsLocked(11060))   // Achievement: A Man of Principle
				{
					return "Jerónimo: " + mission.m_MissionName;
				}
				return;
			case 2786: // The Hidden Expedition
			case 2787: // The Great Map Burglary
			case 2788: // Expedition Into the Triangle
			case 2789: // Attack of the Conquistador Cadavers
			case 2790: // Mysteries of the Sphere
				if (LoreBase.IsLocked(11061))
				{
					return "Jerónimo: " + mission.m_MissionName;
				}
				return;
			case 2801: // The Agartha Cartographer
			case 2793: // The Agartha Cartographer
			case 2802: // Mapping the Past
			case 2794: // Mapping the Past
			case 2795: // Into Deep Time
			case 2803: // Into Deep Time
			case 2804: // Once Again Into Agartha
			case 2796: // Once Again Into Agartha
			case 2797: // The Future is Now
			case 2805: // The Future is Now
				if (LoreBase.IsLocked(11062))   // Achievements: Exploratory Cartographer
				{
					return "Jerónimo: " + mission.m_MissionName;
				}
				return;

			case 2806: // The Fungoid Mystery
			case 2798: // The Fungoid Mystery
			case 2799: // Spores from Beyond
			case 2807: // Spores from Beyond
			case 2808: // The Horror in Fungus
			case 2800: // The Horror in Fungus
				if (LoreBase.IsLocked(11063))   // Achievements: Observing the Impossible
				{
					return "Jerónimo: " + mission.m_MissionName;
				}
				return;
			case 2809: // Into Dark Agartha
			case 2810: // The Conquistador's Secrets
			case 2811: // The Riddle of Dark Agartha
			case 2812: // The Reluctant Conquistador
			case 2813: // Again Into the Void
				if (LoreBase.IsLocked(11064))   // Achievements: Once More Unto the Void
				{
					return "Jerónimo: " + mission.m_MissionName;
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
				if (LoreBase.IsLocked(10735))
				{
					return "Dante: " + mission.m_MissionName;
				}
				return;
			case 373: // The Fountain of Youth
			case 379: // Subterranean Lost and Found
				if (LoreBase.IsLocked(10736))
				{
					return "Guatemala: " + mission.m_MissionName;
				}
				return;
			default:
				return;
		}
	}

	// returns True if reward item is only item or not last
	static function IsNotLast(slot:Number, rewards:Array, type:Number)
	{
		return type == 1 ||
			   (
				   type == 0 &&
				   (
					   (slot == 0) ||
					   (slot != rewards[type].length - 1)
				   )
			   )
	}

	static function IsCustomAlert(ID:Number, Customs:Array)
	{
		for (var i in Customs)
		{
			if (Number(Customs[i]) == ID)
			{
				return true;
			}
			var data:Array = Customs[i].split(",");
			if (data.length >= 1)
			{
				var id = data[0];
				var note = data[1];
				if (Number(id) == ID) return note;
			}
		}
	}
}
