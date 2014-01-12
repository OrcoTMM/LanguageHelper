package com.dbClasses
{
	import com.vo.dbEntryItem;
	
	import events.DBEvent;
	
	import flash.data.SQLConnection;
	import flash.data.SQLMode;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.utils.Timer;
	
	
	/**
	 * Dispatched when the DB connect was unsuccessful.
	 */	
//	[Event(name="DB_FAILED", type="events.DBEvent")]
	/**
	 * Dispatched when the DB connect was successful but another query is currently still executing and has not compelted yet.
	 */	
//	[Event(name="DB_BUSY", type="events.DBEvent")]
	/**
	 * Dispatched when the DB connect was successful.
	 */	
//	[Event(name="DB_SUCCESS", type="events.DBEvent")]
	/**
	 * Dispatched when the DB UPDATE was successful.
	 */	
//	[Event(name="SQL_UPDATED", type="events.DBEvent")]
	/**
	 * Dispatched when the DB SELECT was successful.
	 */	
//	[Event(name="SQL_SELECTED", type="events.DBEvent")]
	/**
	 * Dispatched when the DB SELECT was successful.
	 */	
//	[Event(name="SQL_FAILED", type="events.DBEvent")]
	
	public class DBManager extends EventDispatcher
	{
		
		private var dbFile:File;
		private var conn:SQLConnection;
		private var sqlStatement:SQLStatement;
		private var sqlStatementStore:Vector.<String>	= new Vector.<String>;
		private var connActive:Boolean					= false;
		private var sqlCanProcess:Boolean				= true;
		
		public function DBManager()
		{}
		
		/*****************/
		/**INIT DB START**/
		/*****************/
		public function initialise():void{
			dbFile = File.applicationStorageDirectory.resolvePath("languageHelper.db");
			if(!connActive){
				conn = new SQLConnection();
				conn.addEventListener(SQLErrorEvent.ERROR, errorHandler);
				conn.addEventListener(SQLEvent.OPEN, openHandler);
				conn.openAsync(dbFile, SQLMode.UPDATE);
			}
		}
		protected function errorHandler(e:SQLErrorEvent):void{
			trace("Connection could not be opened");
			conn.removeEventListener(SQLErrorEvent.ERROR, errorHandler);
			conn.removeEventListener(SQLEvent.OPEN, openHandler);
			conn = null;
			dispatchEvent(new DBEvent(DBEvent.DB_FAILED));
		}
		protected function openHandler(e:SQLEvent):void{
			trace("Connection opened successfully");
			conn.removeEventListener(SQLErrorEvent.ERROR, errorHandler);
			conn.removeEventListener(SQLEvent.OPEN, openHandler);
			connActive	= true;
			dispatchEvent(new DBEvent(DBEvent.DB_SUCCESS));
		}
		
		/******************/
		/** UPDATE TO DB **/
		/******************/
		public function addEntry(val:dbEntryItem):void{
			//tmp store in case previous action is not completed
			if(sqlCanProcess){
				executeSQLUpdate("INSERT INTO VocabularyTable (voc_malay,voc_english,voc_german) VALUES (\""+val.voc_Malay+"\",\""+val.voc_English+"\",\""+val.voc_German+"\")");
			}else{
				dispatchEvent(new DBEvent(DBEvent.DB_BUSY));
			}
		}
		private function executeSQLUpdate(val:String):void{
			//SQL ADD
			sqlCanProcess				= false;
			sqlStatement				= new SQLStatement();
			sqlStatement.sqlConnection	= conn;
			sqlStatement.text			= val;
			sqlStatement.addEventListener(SQLEvent.RESULT, sqlUpdateResult); 
			sqlStatement.addEventListener(SQLErrorEvent.ERROR, sqlUpdateError); 
			sqlStatement.execute();
		}
		protected function sqlUpdateError(e:SQLErrorEvent):void{
			sqlCanProcess				= true;
			trace("sqlUpdateError");
				sqlStatement.removeEventListener(SQLEvent.RESULT, sqlUpdateResult);
				sqlStatement.removeEventListener(SQLErrorEvent.ERROR, sqlUpdateError);
			dispatchEvent(new DBEvent(DBEvent.SQL_FAILED));
		}
		protected function sqlUpdateResult(e:SQLEvent):void{
			sqlCanProcess				= true;
			trace("sqlUpdateResult");
				sqlStatement.removeEventListener(SQLEvent.RESULT, sqlUpdateResult);
				sqlStatement.removeEventListener(SQLErrorEvent.ERROR, sqlUpdateError);
				dispatchEvent(new DBEvent(DBEvent.SQL_UPDATED));
		}
		
		/********************/
		/** SELECT FROM DB **/
		/********************/
		public function selectEntry(val:dbEntryItem):void{
			//tmp store in case previous action is not completed
			if(sqlCanProcess){
				var tmpStr:String	= "";
				if(val.voc_English != ""){
					tmpStr += "\"voc_english\" LIKE \"%"+val.voc_English+"%\"";
				}
				if(val.voc_Malay != ""){
					if(tmpStr != ""){
						tmpStr += " OR ";
					}
					tmpStr += "\"voc_malay\" LIKE \"%"+val.voc_Malay+"%\"";
				}
				if(val.voc_German != ""){
					if(tmpStr != ""){
						tmpStr += " OR ";
					}
					tmpStr += "\"voc_german\" LIKE \"%"+val.voc_German+"%\"";
				}
				executeSQLSelecte("SELECT * FROM VocabularyTable WHERE "+tmpStr);
			}else{
				dispatchEvent(new DBEvent(DBEvent.DB_BUSY));
			}
		}
		private function executeSQLSelecte(val:String):void{
			//SQL ADD
			sqlCanProcess				= false;
			sqlStatement				= new SQLStatement();
			sqlStatement.sqlConnection	= conn;
			sqlStatement.text			= val;
			sqlStatement.addEventListener(SQLEvent.RESULT, sqlSelectResult); 
			sqlStatement.addEventListener(SQLErrorEvent.ERROR, sqlSelectError); 
			sqlStatement.execute();
		}
		protected function sqlSelectResult(e:SQLEvent):void{
			sqlCanProcess				= true;
				sqlStatement.removeEventListener(SQLEvent.RESULT, sqlSelectResult);
				sqlStatement.removeEventListener(SQLErrorEvent.ERROR, sqlSelectError);
			var result:SQLResult	= sqlStatement.getResult();
			if(result.data){
				var numResults:int		= result.data.length;
				var selectArray:Array	= new Array();
				for (var i:int = 0; i < numResults; i++)
				{ 
					var tmp_str:String	= "";
					var row:Object		= result.data[i];
					for( var key:String in row)
					{
						tmp_str += key+"="+row[key]+", ";
					}
					tmp_str				= tmp_str.substr(0,tmp_str.length-2);
					selectArray.push(tmp_str);
				}
				dispatchEvent(new DBEvent(DBEvent.SQL_SELECTED, {"selection":selectArray}));
			}else{
				dispatchEvent(new DBEvent(DBEvent.SQL_SELECTED));
			}
			trace("sqlSelectResult");
		}
		protected function sqlSelectError(e:SQLErrorEvent):void{
			sqlCanProcess				= true;
			trace("sqlSelectError");
			sqlStatement.removeEventListener(SQLEvent.RESULT, sqlSelectResult);
			sqlStatement.removeEventListener(SQLErrorEvent.ERROR, sqlSelectError);
			dispatchEvent(new DBEvent(DBEvent.SQL_FAILED));
		}
	}
}