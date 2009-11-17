package com.collectivecolors.rpc
{
	//----------------------------------------------------------------------------
	// Imports
	
	import mx.messaging.Channel;
	import mx.messaging.ChannelSet;
	import mx.messaging.channels.AMFChannel;
	import mx.messaging.channels.SecureAMFChannel;
	import mx.rpc.remoting.RemoteObject;
	import mx.utils.URLUtil;
			
	//----------------------------------------------------------------------------
	
	public class AMFAgent extends ServiceAgent
	{
		//--------------------------------------------------------------------------
		// Properties
		
		protected var amfChannels : ChannelSet;
		
		//--------------------------------------------------------------------------
		// Constructor
		
		/**
		 * Constructor
		 * 
		 * Fault Handler Prototype
		 * -------------------------
		 * function someFunction( event : FaultEvent ) : void
		 */
		public function AMFAgent( source : String = null, 
		                          faultHandler : Function = null ) 
		{
			super( new RemoteObject( ), faultHandler );
			
			amfChannels = new ChannelSet( );
						
			RemoteObject( connection ).channelSet  = amfChannels;
			RemoteObject( connection ).destination = 'notUsed';
						
			if ( source && source.length > 0 ) 
			{
				RemoteObject( connection ).source = source;	
			}
		}		
		
		//--------------------------------------------------------------------------
		// Accessor / Modifiers
		
    /**
     * Get remote source object descriptor
     */           
    public function get source( ) : String 
    {
    	return RemoteObject( connection ).source;
    }
        
    /**
		 * Set remote source object descriptor
		 */
    public function set source( value : String ) : void 
    {
     	if ( value && value.length > 0 ) 
		  {
				RemoteObject( connection ).source = value;	
			}			
    }
    
    //--------------------------------------------------------------------------
    	
		/**
		 * Add a communication channel for the remote connection
		 */ 
		override public function addChannel( url : String ) : void
		{
			super.addChannel( url );
			
			if ( URLUtil.isHttpsURL( url ) )
			{
				amfChannels.addChannel( new SecureAMFChannel( url, url ) );		
			}
			else 
			{
				amfChannels.addChannel( new AMFChannel( url, url ) );
			}
		}
		
		/**
		 * Remove a communication channel for the remote connection
		 */ 
		override public function removeChannel( url : String ) : void
		{
			super.removeChannel( url );
			
			for each ( var channel : Channel in amfChannels.channels )
			{
				if ( channel.id == url )
				{
					amfChannels.removeChannel( channel );
					break;
				}	
			}			
		}
		
		/**
		 * Clear all communication channels for this remote connection
		 */
		override public function clearChannels( ) : void
		{
			super.clearChannels( );
			
			clearAMFChannels( );
		}
		
		/**
		 * Import communication channels from a previously instantiated service
		 */
		override public function importChannels( agent : IServiceAgent ) : void
		{
			super.importChannels( agent );
			
			clearAMFChannels( );
			
			for each ( var url : String in agent.channels )
			{
				addChannel( url );	
			}
		}
		
		//--------------------------------------------------------------------------
		// Internal utilities
		
		/**
		 * Clear all AMF channels
		 */
		protected function clearAMFChannels( ) : void
		{
		  amfChannels.channels = [ ];
		}
	}
}