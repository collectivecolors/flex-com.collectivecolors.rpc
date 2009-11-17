package com.collectivecolors.rpc
{
	//----------------------------------------------------------------------------
	// Imports
	
	import com.collectivecolors.errors.InvalidInputError;
	import com.collectivecolors.validators.URLValidator;
	
	import flash.events.IEventDispatcher;
	
	import mx.events.ValidationResultEvent;
	import mx.rpc.events.FaultEvent;
	import mx.utils.StringUtil;
					
	//----------------------------------------------------------------------------
	
	public class RemoteAgent
	{
		//--------------------------------------------------------------------------
		// Properties
		
    private var _faultHandler : Function; // get | set
        
    protected var message : String; // get
        
    protected var validator : URLValidator;
                               		
		//--------------------------------------------------------------------------
		// Constructor
		
		/**
		 * Constructor
		 * 
		 * Fault Handler Prototype
		 * -------------------------
		 * function someFunction( event : FaultEvent ) : void
		 */
		public function RemoteAgent( connection : IEventDispatcher,
									               faultHandler : Function = null ) 
		{
			// Initialize fault handler.			
			if ( faultHandler != null )
			{
				this.faultHandler = faultHandler;
			}
			
			connection.addEventListener( FaultEvent.FAULT, connectionFaultHandler );
			
			// Initialize status messages.
			message = '';
			
			// Initialize URL validator.
			validator = new URLValidator( );
      
      validator.triggerEvent     = '';
			validator.required         = true;
			validator.allowedProtocols = [ 'http', 'https' ];
		}		
		
		//--------------------------------------------------------------------------
		// Accessor / Modifiers
		
		/**
		 * Get remote fault handler function
		 */
		public function get faultHandler( ) : Function
		{
			return _faultHandler;
		}
		
		/**
		 * Set remote fault handler function 
		 * 
		 * Fault Handler Prototype
		 * -------------------------
		 * function someFunction( event : FaultEvent ) : void
		 */				
		public function set faultHandler( value : Function ) : void 
		{
			if ( value == null )
			{
				throw new InvalidInputError( 
				  "Remote fault handler function not specified"
				);
			}
			
			_faultHandler = value;
		}
		
		//--------------------------------------------------------------------------
		
		/**
		 * Get status message for last operation
		 * 
		 * This message MAY be set only if an error occured during the last 
		 * operation.
		 */
		public function get statusMessage( ) : String 
		{
			return message;
		}
		
		//--------------------------------------------------------------------------
		// Event Handlers
		
		/**
		 * Global remote fault handler called after recieving an error on any 
		 * remote operation
		 * 
		 * If a remote fault handler function has been specified this function sets 
		 * the operation status properties and then calls the specified remote 
		 * fault handler function with the given fault event.
		 */
		protected function connectionFaultHandler( event : FaultEvent ) : void 
		{
			message = event.fault.faultString;
			
			if ( faultHandler != null ) 
			{
				faultHandler( event );
			}			
		}
		
		//--------------------------------------------------------------------------
		// Internal Utilities
		
		/**
		 * Check a given URL for validity
		 */
		protected function validateUrl( url : String, faultMessage : String ) : void
		{
			if ( ! url || url.length == 0 )
			{
				throw new InvalidInputError( faultMessage );
			}
			
			// Clean url
			url = StringUtil.trim( url );
			
			// Validate url
			var urlError : ValidationResultEvent = validator.validate( url, true );
			
			if ( urlError.type == ValidationResultEvent.INVALID )
			{			
				// Bad url input.
				throw new InvalidInputError( faultMessage );
			}		
		}						
	}
}