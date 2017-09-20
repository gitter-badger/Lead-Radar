Function GetMapGlobalContext() Export 
	Return GetMapFromTemplate("GlobalContextJson");
EndFunction

Function GetMapSystemEnums() Export 
	Return GetMapFromTemplate("SystemEnumsJson");
EndFunction

Function GetMapTypes() Export 
	Return GetMapFromTemplate("TypesJson");
EndFunction

Function GetMapFromTemplate(CommonTemplateName);
	
	TempFileName = GetTempFileName("*.json");
	
	JSONTemplate = GetCommonTemplate(CommonTemplateName);
	JSONTemplate.Write(TempFileName);
	
	JSONReader = New JSONReader;
	JSONReader.OpenFile(TempFileName);
	Map = ReadJSON(JSONReader, True);
	
	Return Map;
	
EndFunction