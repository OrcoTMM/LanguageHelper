package events
{
	import flash.events.Event;
	
	public class DBEvent extends Event
	{
		
		public static const DB_FAILED:String	= "DBFailed";
		public static const DB_BUSY:String		= "DBBusy";
		public static const DB_SUCCESS:String	= "DBSuccess";
		public static const SQL_UPDATED:String	= "SQLUpdated";
		public static const SQL_SELECTED:String = "SQLSelected";
		public static const SQL_FAILED:String	= "SQLFailed";
		
//		public static const SELECT_EVENT:String = "selectEvent";
//		public static const UPDATE_EVENT:String = "updateEvent";
		public var dataObj:Object;
		
		public function DBEvent(type:String, dataObj:Object = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.dataObj = dataObj;
			super(type, bubbles, cancelable);
		}
		override public function clone():Event
		{
			return new DBEvent(type, dataObj, bubbles, cancelable);
		}
	}
}