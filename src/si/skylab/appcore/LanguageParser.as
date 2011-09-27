/**
 * class parses language xml and returnes its values sorted in lang variable to be used on app UI controls
 * @author benjamin.povirk@gmail.com, 18.3.09
 **/
package si.skylab.appcore
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.System;
	import flash.utils.Dictionary;
	import flash.xml.XMLDocument;

	public final class LanguageParser extends EventDispatcher
	{
		private var lang:Object;
		private var xmlString:URLRequest;
		private var xmlLoader:URLLoader;
		
		public function LanguageParser(language:String="en")
		{
			//store curr lang to configvars
			AppVars.CurrentLanguageId = language;
			xmlString = new URLRequest("language/"+language.toLowerCase()+"/language.xml");
			xmlLoader = new URLLoader();
			xmlLoader.addEventListener(Event.COMPLETE, _populate);
			xmlLoader.addEventListener(IOErrorEvent.IO_ERROR, _error);
			xmlLoader.load(xmlString);
		}
		/**
		 * method populates public var lang
		 **/
		private function _populate(evt:Event):void
		{
			var languageXML:XML;
			try {
				languageXML = XML(evt.target.data);
			} catch (e:Error) {
				//if (AppVars.Debug) AppMaster.LogToFile("System: ERROR = Language file malformed");
			}
			//AppFunctions.Log(languageXML);
			var language:XMLDocument = new XMLDocument();
			language.ignoreWhite = true;
			language.parseXML(languageXML.toXMLString());
			//store XML values in public lang
			lang = new Object();
			lang.language = languageXML.attribute("name");
			AppVars.CurrentLanguageName = lang.language; 

			var o:XML; //xml object
			var oo:XML;

			//parse XML - nativeMenu
			lang.nativeMenu = new Dictionary();
			for each (o in languageXML.nativeMenu.menu) {
				lang.nativeMenu[o.attribute("id")+""] = o.text.text();
				lang.nativeMenu[o.attribute("id")+".text"] = o.text.text();
			}

			//parse XML - main Menu
			lang.mainMenu = new Dictionary();
			for each (o in languageXML.mainMenu.menu) {
				lang.mainMenu[o.attribute("id")+""] = o.text.text();
			}

			//parse XML - document types
			lang.documentTypes = new Dictionary();
			for each (o in languageXML.documentTypes.document_type) {
				lang.documentTypes[o.attribute("id")+""] = o.text.text();
			}
			
			//parse XML - statuses
			lang.status = new Dictionary();
			for each (o in languageXML.statuses.status) {
				lang.status[o.attribute("id")+""] = o.text.text();
			}
			
			//parse XML - months
			lang.months = new Dictionary();
			for each (o in languageXML.months.month) {
				lang.months[o.attribute("id")+""] = o.text.text();
			}
			
			//parse XML - days
			lang.days = new Dictionary();
			for each (o in languageXML.days.day) {
				lang.days[o.attribute("id")+""] = o.text.text();
				lang.days[o.attribute("id")+".label"] = o.label.text();
			}
			
			//parse XML - titles
			lang.titles = new Dictionary();
			for each (o in languageXML.titles.title) {
				lang.titles[o.attribute("id")+""] = o.text.text();
			}
			
			//parse XML - buttons
			lang.buttons = new Dictionary();
			for each (o in languageXML.buttons.button) {
				lang.buttons[o.attribute("id")+".label"] = o.label.text();
				lang.buttons[o.attribute("id")+".toolTip"] = o.toolTip.text();
				lang.buttons[o.attribute("id")+".localHelp"] = o.localHelp.text();
			}

			//parse XML - textBoxes
			lang.textBoxes = new Dictionary();
			for each (o in languageXML.textBoxes.textbox) {
				lang.textBoxes[o.attribute("id")+""] = o.text.text();
				lang.textBoxes[o.attribute("id")+".text"] = o.text.text();
			}
			
			//parse XML - labels (custom text)
			lang.labels = new Dictionary();
			for each (o in languageXML.labels.label) {
				lang.labels[o.attribute("id")+""] = o.text.text();
			}
			
			//parse XML - comboBoxes
			lang.comboBoxes = new Dictionary();
			for each (o in languageXML.comboBoxes.combo) {
				lang.comboBoxes[o.attribute("id")+".label"] = o.label.text();
				lang.comboBoxes[o.attribute("id")+".localHelp"] = o.localHelp.text();
				lang.comboBoxes[o.attribute("id")+".toolTip"] = o.toolTip.text();
			}
			
			//parse XML - inputBoxes
			lang.inputBoxes = new Dictionary();
			for each (o in languageXML.inputBoxes.input) {
				lang.inputBoxes[o.attribute("id")+""] = o.text.text();
				lang.inputBoxes[o.attribute("id")+".text"] = o.text.text();
			}
			
			//parse XML - checkBoxes
			lang.checkBoxes = new Dictionary();
			for each (o in languageXML.checkBoxes.checkbox) {
				lang.checkBoxes[o.attribute("id")+""] = o.label.text();
				lang.checkBoxes[o.attribute("id")+".label"] = o.label.text();
				lang.checkBoxes[o.attribute("id")+".toolTip"] = o.toolTip.text();
			}
			
			//parse XML - radioButtons
			lang.radioButtons = new Dictionary();
			for each (o in languageXML.radioButtons.radiobutton) {
				lang.radioButtons[o.attribute("id")+""] = o.label.text();
				lang.radioButtons[o.attribute("id")+".label"] = o.label.text();
			}
			
			//parse XML - popups
			lang.popups = new Dictionary();
			
			for each (o in languageXML.popups.popup) {
				lang.popups[o.attribute("id")+".title"] = o.title.text();
			}

			//parse XML - alerts
			lang.alerts = new Dictionary();
			for each (o in languageXML.alerts.alert) {
				lang.alerts[o.attribute("id")+".title"] = o.title.text();
				lang.alerts[o.attribute("id")+".text"] = o.text.text();
				lang.alerts[o.attribute("id")+".okLabel"] = o.okLabel.text();
				lang.alerts[o.attribute("id")+".cancelLabel"] = o.cancelLabel.text();
			}

			//parse XML - image icons
			lang.icons = new Dictionary();
			for each (o in languageXML.icons.icon) {
				lang.icons[o.attribute("id")+""] = o.toolTip.text();
				lang.icons[o.attribute("id")+".toolTip"] = o.toolTip.text();
				lang.icons[o.attribute("id")+".localHelp"] = o.localHelp.text();
			}

			//parse XML - permissions
			lang.permissions = new Dictionary();
			for each (o in languageXML.permissions.permission) {
				lang.permissions[o.attribute("id")+".name"] = o.attribute("name");
				lang.permissions[o.attribute("id")+".description"] = o.description.text();
			}

			//parse XML - dataGrid headers and settings (in array)
			lang.dataGrids = new Dictionary();
			for each (o in languageXML.dataGrids.dataGrid) {
				lang.dataGrids[o.attribute("id")+""] 				= new Vector.<String>();
				lang.dataGrids[o.attribute("id")+"_default"] 		= new Vector.<String>();
				lang.dataGrids[o.attribute("id")+"_show"] 			= new Vector.<String>();
				lang.dataGrids[o.attribute("id")+"_id"] 			= new Vector.<String>();
				lang.dataGrids[o.attribute("id")+"_editable"] 		= new Vector.<String>();
				lang.dataGrids[o.attribute("id")+"_tip"] 			= new Vector.<String>();
				lang.dataGrids[o.attribute("id")+"_headerRenderer"] = new Vector.<String>();
				lang.dataGrids[o.attribute("id")+"_color"] 			= new Vector.<String>();
				lang.dataGrids[o.attribute("id")+"_print"] 			= new Vector.<String>();
				lang.dataGrids[o.attribute("id")+"_align"] 			= new Vector.<String>();
				lang.dataGrids[o.attribute("id")+"_visible"]		= new Vector.<String>();
				for each (oo in o.column) { 
					lang.dataGrids[o.attribute("id")+""].push(String(oo.text()+"")); //add "" so string object functions will work
					lang.dataGrids[o.attribute("id")+"_default"].push(String(oo.attribute("default")).toLowerCase()+"");
					lang.dataGrids[o.attribute("id")+"_show"].push(String(oo.attribute("show")).toLowerCase()+"");
					lang.dataGrids[o.attribute("id")+"_id"].push(String(oo.attribute("id"))+"");
					lang.dataGrids[o.attribute("id")+"_editable"].push(String(oo.attribute("editable")).toLowerCase()+"");
					lang.dataGrids[o.attribute("id")+"_tip"].push(String(oo.attribute("tip")).toLowerCase()+"");
					lang.dataGrids[o.attribute("id")+"_headerRenderer"].push(String(oo.attribute("headerRenderer")).toLowerCase()+"");
					lang.dataGrids[o.attribute("id")+"_color"].push(String(oo.attribute("color")).toLowerCase()+"");
					lang.dataGrids[o.attribute("id")+"_print"].push(String(oo.attribute("print")).toLowerCase()+"");
					lang.dataGrids[o.attribute("id")+"_align"].push(String(oo.attribute("align")).toLowerCase()+"");
					lang.dataGrids[o.attribute("id")+"_visible"].push(String(oo.attribute("visible")).toLowerCase()+"");
				}
				
			}
			//parse XML - miscs
			lang.misc = new Dictionary();
			for each (o in languageXML.miscs.misc) {
				lang.misc[o.attribute("id")+""] = o.text();
			}
			
			//parse XML - weather
			lang.weather = new Dictionary();
			for each (o in languageXML.weathers.weather) {
				lang.weather[o.attribute("id")+""] = o.text();
			}
			
			o = oo = null;
			flash.system.System.disposeXML(languageXML);
			
			xmlLoader.removeEventListener(Event.COMPLETE, _populate);
			xmlLoader.removeEventListener(IOErrorEvent.IO_ERROR, _error);
			AppFunctions.Log("System: language setup finished");
			AppVars.CurrentLanguage = lang;
			dispatchEvent(new Event("Language.Parsed"));
		}
		/**
		 * method tries to handle error
		 **/
		private function _error(evt:Event):void
		{
			//if (AppVars.Debug) AppMaster.LogToFile("System: ERROR = Language file not readable");
			AppFunctions.Log("System: language XML error!");
			throw new Error("language error");
		}
	}
}