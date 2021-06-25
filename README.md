[![Downloads](https://img.shields.io/github/downloads/SecretFox/MissionAlerts/total)](https://github.com/SecretFox/MissionAlerts/releases)  
# MissionAlerts
Displays alerts about available agent missions.  
Alerts are shown as chat/fifo messages(configurable).  
Also changes agent icon color and adds a tooltip to it when missions are available.  

### Options  
`/option MissionAlerts_IgnoreOutstanding`[Default: false], if set to true gear bags that require outstanding success get ignored.  
`/option MissionAlerts_Urgent`[true] Show urgent mission alerts  
`/option MissionAlerts_Vanity`[true]  Show Vanity Bag alerts  
`/option MissionAlerts_Epic`[true]  Show Epic Agent Gear Bag alerts  
`/option MissionAlerts_Superior`[true]  Show Superior Agent Gear Bag alerts  
`/option MissionAlerts_Dossier`[true]  Show unowned dossier alerts  
`/option MissionAlerts_Chain`[true]  Show uncompleted mission chain alerts  
`/option MissionAlerts_Special`[true]  Show special mission alerts  
`/option MissionAlerts_JeronimoItems`[true]  Show Jerónimo item alerts  
`/option MissionAlerts_Chat`[true]  Display alerts in chat (System chat channel)  
`/option MissionAlerts_Fifo`[true]  Display alerts as FiFo messages  

`/option MissionAlerts_AlertOnCompletion`[false] Sends alert when mission is completed    
`/option MissionAlerts_ClaimOnCompletion`[false] Claims mission rewards when mission is completed  
`/option MissionAlerts_Custom` user configurable list of alerts.  
Format: `/option MissionAlerts_Custom "Id1;Id2"` or `/option MissionAlerts_Custom "Id1,text1;Id2,text2"`,  
for list of mission ID's see [missionID's](https://github.com/SecretFox/MissionAlerts/blob/master/missionIds.txt)

### Install  
Download MissionAlerts.zip from the releases page and extract contents into `Secret World Legends\Data\Gui\Custom\Flash\` folder
