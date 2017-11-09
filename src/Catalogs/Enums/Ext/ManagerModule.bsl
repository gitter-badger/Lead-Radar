﻿
Function Load(Parameters) Export
	Var Ref;
	
	Configuration = Parameters.Configuration;
	Owner = Parameters.Owner;
	Path = Parameters.Path;
	
	// precondition:
	// # (Configuration == Owner)
	// # Path is folder path
	
	This = Catalogs.Enums;
	
	Data = Meta.ReadMetadataXML(Path + ".xml").Enum;
	PropertyValues = Data.Properties;
	ChildObjects = Data.ChildObjects;
	UUID = Data.UUID; 
	
	// Properties
	
	Object = Meta.GetObject(This, UUID, Owner, Ref);  
	
	Object.UUID = UUID;
	Object.Owner = Owner;
	Object.Description = PropertyValues.Name;
	
	Abc.Fill(Object, PropertyValues, Abc.Lines(
		"ChoiceHistoryOnInput"
		"ChoiceMode"
		"Comment"
		"QuickChoice"
		"UseStandardCommands"
	));
	
	Meta.UpdateStrings(Configuration, Ref, Object, PropertyValues, Abc.Lines(
		"Explanation"
		"ExtendedListPresentation"
		"ListPresentation"
		"Synonym"
	));
	
	BeginTransaction();
	
	ChildParameters = Meta.ObjectLoadParameters();
	ChildParameters.Configuration = Configuration;
	ChildParameters.Owner = Ref;
	
	// Standard attributes
	
	If PropertyValues.StandardAttributes <> Undefined Then
		For Each StandardAttributeData In PropertyValues.StandardAttributes.StandardAttribute Do
			ChildParameters.Data = StandardAttributeData;
			StandardAttribute = Catalogs.StandardAttributes.Load(ChildParameters);
		EndDo; 
	EndIf; 
	
	// Enum values
	
	EnumValueOrder = Object.EnumValueOrder;
	EnumValueOrder.Clear();
		
	For Each EnumValueData In ChildObjects.EnumValue Do
		ChildParameters.Data = EnumValueData;
		EnumValueOrder.Add().EnumValue = Catalogs.EnumValues.Load(ChildParameters);
	EndDo;
	
	ChildParameters.Data = Undefined;
		
	// Forms
	
	Forms = New Structure;
	
	For Each FormName In ChildObjects.Form Do
		ChildParameters.Path = Abc.JoinPath(Path, "Forms\" + FormName);
		Forms.Insert(FormName, Catalogs.Forms.Load(ChildParameters));
	EndDo; 
	
	For Each PropertyName In Abc.Lines(
			"AuxiliaryChoiceForm"
			"AuxiliaryListForm"
			"DefaultChoiceForm"
			"DefaultListForm"
		) Do
		
		FormFullName = PropertyValues[PropertyName];
		FormName = Mid(FormFullName, StrFind(FormFullName, ".", SearchDirection.FromEnd) + 1);
		
		If Not IsBlankString(FormName) Then
			If Not Forms.Property(FormName, Object[PropertyName]) Then
				Raise "form not found";
			EndIf; 
		EndIf; 
		
	EndDo; 
	
	// Commands
	
	ChildParameters.Path = Path;
	
	For Each CommandData In ChildObjects.Command Do
		ChildParameters.Data = CommandData;
		Command = Catalogs.Commands.Load(ChildParameters);
	EndDo;	
	
	ChildParameters.Path = Undefined;
	ChildParameters.Data = Undefined;
	
	// Templates
	
	For Each TemplateName In ChildObjects.Template Do
		ChildParameters.Path = Abc.JoinPath(Path, "Templates\" + TemplateName);
		Template = Catalogs.Templates.Load(ChildParameters);
	EndDo;
	
	ChildParameters.Data = Undefined;
	
	// Modules
	
	ChildParameters.Insert("ModuleKind");
	ChildParameters.Insert("ModuleRef");
	
	ChildParameters.Path = Abc.JoinPath(Path, "Ext\ManagerModule.bsl");
	ChildParameters.ModuleKind = Enums.ModuleKinds.ManagerModule;
	ChildParameters.ModuleRef = Object.ManagerModule;
	Object.ManagerModule = Catalogs.Modules.Load(ChildParameters);	
		
	Object.Write();	
	
	CommitTransaction();
	
	Return Object.Ref;
	
EndFunction // Load()
