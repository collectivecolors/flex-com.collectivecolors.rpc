package com.collectivecolors.rpc
{
	//----------------------------------------------------------------------------
	
	public interface IServiceAgent
	{
		//---------------
		// Service urls  |
		//---------------
		
		function get channels( ) : Array;
		
		function clearChannels( ) : void;
		
		function addChannel( url : String ) : void;
		function removeChannel( url : String ) : void;
		
		function importChannels( service : IServiceAgent ) : void;
		
		//---------------------
		// Status information  |
		//---------------------
		
		function get statusMessage( ) : String;
		
		//-----------------------
		// Global fault handler  |
		//-----------------------
		
		function get faultHandler( ) : Function;
		function set faultHandler( value : Function ) : void;
		
		//-------------------
		// Service handlers  |
		//-------------------
		
		function register( operation : String, 
		        				   resultHandler : Function = null, 
						           faultHandler : Function  = null ) : void;
		
		//--------------------
		// Service execution  |
		//--------------------
		
		function execute( operation : String, ... parameters ) : void; 
	}
}