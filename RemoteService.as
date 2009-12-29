package com.collectivecolors.rpc
{
	//----------------------------------------------------------------------------
	// Imports
	
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	//----------------------------------------------------------------------------
	
	public class RemoteService
	{
		//--------------------------------------------------------------------------
		// Properties
		
		protected var agent : IServiceAgent;
		
		private var operationHandlers : Object;
				
		//--------------------------------------------------------------------------
		// Constructor
		
		public function RemoteService( agent : IServiceAgent, urls : Array = null )
		{
			// Set service agent implementation.
			this.agent = agent;
			
			if ( urls != null )
			{
			  // Set service URLs.
			  for each ( var  url : String in urls )
			  {
			    this.agent.addChannel( url );
			  }
			}
			
			// Initialize service operations.
			operationHandlers = { };			
		}
		
		//--------------------------------------------------------------------------
		// Accessor / modifiers
		
		/**
		 * Get global fault handler
		 */
		public function set faultHandler( value : Function ) : void
		{
		  agent.faultHandler = value;
		}
		
		//--------------------------------------------------------------------------
		
		/**
		 * Get remote service agent channels
		 */
		public function get urls( ) : Array
		{
		  return agent.channels;
		}
		
		/**
		 * Add a remote service agent channel url
		 */
		public function addUrl( url : String ) : void
		{
		  agent.addChannel( url );
		}
		
		/**
		 * Remove a remote service agent channel url
		 */
		public function removeUrl( url : String ) : void
		{
		  agent.removeChannel( url );
		}
		
		/**
		 * Clear all remote service agent channeel urls
		 */
		public function clearUrls( ) : void
		{
		  agent.clearChannels( );
		}
		
		//--------------------------------------------------------------------------
		// Event handlers
		
		/**
		 * Executed when the service request fails. 
		 * | 
		 * '- If sub classes choose to use it.
		 */
		protected function serviceFaultHandler( event : FaultEvent ) : void
		{
		  var faultHandler : Function = getFaultHandler( event.token.operation );
		  
		  if ( faultHandler != null )
		  {
		    faultHandler( agent.statusMessage );
		  }
		}
		
		//--------------------------------------------------------------------------
		// Extensions
		
		/**
		 * Register service handlers
		 */
		protected function registerHandlers( op : String,
		                                     resultHandler : Function = null,
		                                     faultHandler : Function = null ) : void
		{
		  if ( ! operationHandlers.hasOwnProperty( op ) )
		  {
		    // Create new handler reference for this operation.
		    operationHandlers[ op ] = {
					"resultHandler" : resultHandler,
					"faultHandler"  : faultHandler
				};
		  }
		  else
		  {
		    // Update existing handler information.
		    operationHandlers[ op ].resultHandler = resultHandler;
		    operationHandlers[ op ].faultHandler  = faultHandler;
		  }
		}
		
		//--------------------------------------------------------------------------
		
		/**
		 * Get the fault handler for an operation or the global fault handler if
		 * no operation fault handler exists.
		 */
		protected function getFaultHandler( op : String ) : Function
		{
		  if ( ! operationHandlers.hasOwnProperty( op ) )
		  {
		    return null;
		  }
		  else if ( operationHandlers[ op ].faultHandler != null )
		  {
		    return operationHandlers[ op ].faultHandler;
		  }
		  
		  return agent.faultHandler;
		}
		
		/**
		 * Get the result handler for an operation
		 */
		protected function getResultHandler( op : String ) : Function
		{
		  if ( ! operationHandlers.hasOwnProperty( op ) )
		  {
		    return null;
		  }
		  
		  return operationHandlers[ op ].resultHandler;
		}
		
		//--------------------------------------------------------------------------
		
		/**
		 * Execute active result handler for the current operation that triggered
		 * the event.
		 * 
		 * Prototype :
		 * 
		 *  function resultParser( result : Object, parameters : Array ) : *
		 */
		protected function executeResultHandler( event : ResultEvent, 
		                                         parser : Function = null ) : void
		{
		  var resultHandler : Function = getResultHandler( event.token.operation );
		  
		  if ( resultHandler != null )
		  {
		    if ( parser != null )
		    {	    
		      resultHandler( parser( event.result, event.token.parameters ) );
		    }
		    else
		    {
		      resultHandler( event.result );
		    }
		  }
		}
	}
}