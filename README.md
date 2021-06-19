[![Downloads](https://img.shields.io/github/downloads/SecretFox/MissionAlerts/total)](https://github.com/SecretFox/MissionAlerts/releases)  
# MissionAlerts
Displays alerts about available agent missions.  
Alerts are shown as chat/fifo messages(configurable).  
Also changes agent icon color and adds a tooltip to it when missions are available.  

### Options  
`/option MissionAlerts_IgnoreOutstanding true`[Default False], if enabled gear bags that require outstanding success get ignored.  
By default all of these are true, set to false to disable them.  
`/option MissionAlerts_Urgent true` Enable urgent mission alerts  
`/option MissionAlerts_Vanity true` Enable Vanity Bag alerts  
`/option MissionAlerts_Epic true` Enable Epic Agent Gear Bag alerts  
`/option MissionAlerts_Superior true` Enable Superior Agent Gear Bag alerts  
`/option MissionAlerts_Dossier true` Enable unowned dossier alerts  
`/option MissionAlerts_Chain true` Enable uncompleted mission chain alerts  
`/option MissionAlerts_Special true` Enable special mission alerts  
`/option MissionAlerts_JeronimoItems true` Enable Jerónimo item alerts  
`/option MissionAlerts_Chat true` Display alerts in chat (System chat channel)  
`/option MissionAlerts_Fifo true` Display alerts in fadein/fadeout message  

`/option MissionAlerts_AlertOnCompletion true`[default false] Sends alert when mission is completed    
`/option MissionAlerts_AlertOnCompletion true`[default false] Claims mission rewards when mission is completed
`/option MissionAlerts_Custom`, user configurable list of alerts.
Format: `/option MissionAlerts_Custom "missionId1;missionId2"` or `/option MissionAlerts_Custom "missionId1,alerttext1;missionId2,alerttext2"`, for list of mission ID's see https://github.com/SecretFox/MissionAlerts

### Install  
Download MissionAlerts.zip from the releases page and extract contents into `Secret World Legends\Data\Gui\Custom\Flash\` folder
