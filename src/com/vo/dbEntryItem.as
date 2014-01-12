package com.vo
{
	public class dbEntryItem
	{
		private var _voc_Malay : String		= "";
		private var _voc_German : String	= "";
		private var _voc_English : String	= "";
		
		public function get voc_Malay() : String{
			return _voc_Malay;
		}
		public function set voc_Malay( value : String ) : void{
			_voc_Malay = value;
		}
		
		public function get voc_German() : String{
			return _voc_German;
		}
		public function set voc_German( value : String ) : void{
			_voc_German = value;
		}
		
		public function get voc_English() : String{
			return _voc_English;
		}
		public function set voc_English( value : String ) : void{
			_voc_English = value;
		}
	}
}