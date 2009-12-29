package com.collectivecolors.rpc
{
	//----------------------------------------------------------------------------
	// Imports
	
	import com.collectivecolors.data.URLSet;
	import com.collectivecolors.errors.IllegalAccessError;
	import com.collectivecolors.errors.InvalidInputError;
	
	import mx.rpc.AbstractOperation;
	import mx.rpc.AbstractService;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
					
	//----------------------------------------------------------------------------
	
	public class ServiceAgent extends RemoteAgent implements IServiceAgent
	{
		//--------------------------------------------------------------------------
		// Properties
		
		protected var connection : AbstractService;
		        		        
		protected var operations : Object;
    
    private var _endpoints : URLSet; 
                               		
		//--------------------------------------------------------------------------
		// Constructor
		
		/**
		 * Constructor
		 * 
		 * Fault Handler Prototype
		 * -------------------------
		 * function someFunction( event : FaultEvent ) : void
		 */
		public function ServiceAgent( connection : AbstractService,
									                faultHandler : Function = null ) 
		{
			super( connection, faultHandler );
			
			this.connection = connection;
			
			operations = new Object( );
			
			_endpoints = new URLSet( );
		}
		
		//--------------------------------------------------------------------------
		// Accessor / modifiers
		
		/**
		 * Get endpoint URL collection
		 */ 
		protected function get endpoint( ) : URLSet
		{
		  return _endpoints;
		}
		
		/**
		 * Get a list of all URL channels available for this service.
		 */
		public function get channels( ) : Array
		{
		  return endpoint.urls;
		}
		
		/**
		 * Remove all channel URL's to this service
		 */
		public function clearChannels( ) : void
		{
		  endpoint.urls = new Array( );
		}
		
		/**
		 * Add a new channel URL to this service
		 */
		public function addChannel( url : String ) : void
		{
		  endpoint.addUrl( url );
		}
		
		/**
		 * Remove an existing channel URL for this service
		 */
		public function removeChannel( url : String ) : void
		{
		  endpoint.removeUrl( url );
		}
		 
		/**
		 * Import existing channel URL's from another IServiceAgent object
		 */ 
		public function importChannels( agent  : IServiceAgent ) : void
		{
		  if ( agent == null )
			{
			  throw new InvalidInputError( 
			    "Instantiated IServiceAgent not specified"
			  );
			}
		   
		  endpoint.urls = agent.channels;
		}				
		
		//--------------------------------------------------------------------------
		// Extensions
		
		/**
		 * Registers a remote operation that can be executed and sent to a remote 
		 * destination
		 */
		public function register( operation : String, 
								              resultHandler : Function = null, 
								              faultHandler : Function  = null ) : void
		{
			if ( operations.hasOwnProperty( operation ) )
			{
				operations[ operation ].resultHandler = resultHandler;
				operations[ operation ].faultHandler  = faultHandler;
			}
			else
			{
				var proc : AbstractOperation = connection.getOperation( operation );
			
				proc.addEventListener( ResultEvent.RESULT, operationResultHandler );
				proc.addEventListener( FaultEvent.FAULT, operationFaultHandler );
				
				operations[ operation ] = {
					"resultHandler" : resultHandler,
					"faultHandler"  : faultHandler,
					"operation"     : proc
				};
			}
		}
		
		/**
		 * Execute a registered remote operation
		 */
		public function execute( operation : String, ... parameters ) : void 
		{
			if ( ! operations.hasOwnProperty( operation ) )
			{			
				throw new IllegalAccessError( 
				  'Illegal access attempt of non existent operation [ ' 
				    + operation + ' ] during execution'
				);		
			}
			
			var proc : AbstractOperation = operations[ operation ].operation 
			                                as AbstractOperation;			
			
			initOperation( proc, parameters );
			
			var call : AsyncToken = proc.send( );
			
			call.operation  = operation;
			call.parameters = parameters;			
		}		
		
		//--------------------------------------------------------------------------
		// Event Handlers
		
		/**
		 * Remote result handler called after recieving intended results from a 
		 * registered operation
		 * 
		 * This function sets the operation statusMessage property then calls the 
		 * specified remote result handler function with the given result event.
		 */
		protected function operationResultHandler( event : ResultEvent ) : void
		{
			var operation : String = event.token.operation;
						
			message = 'Operation [ ' + operation + ' ] completed successfully';			
			try
			{
				var opResultHandler : Function = operations[ operation ].resultHandler;
			}
			catch ( error : Error )
			{
				throw new IllegalAccessError( 
				  'Illegal access attempt in  [ ' + operation + ' ] result handler' 
				);	
			}
			
			opResultHandler( event );				
		}
		
		/**
		 * Remote fault handler called after recieving an error from a registered 
		 * operation
		 * 
		 * If a remote fault handler function has been specified this function sets 
		 * the operation statusMessage property and then calls the specified remote 
		 * fault handler function with the given fault event.
		 */
		protected function operationFaultHandler( event : FaultEvent ) : void
		{
			var operation : String = event.token.operation;
			
			message = 'Operation [ ' + operation + ' ] failed with : ' 
			         + event.fault.faultString;			
			try
			{
				var opFaultHandler : Function = operations[operation].faultHandler;
			}
			catch ( error : Error )
			{
				throw new IllegalAccessError( 
				  'Illegal access attempt in [ ' + operation + ' ] fault handler' 
				);	
			}
			
			if ( opFaultHandler != null ) 
			{
				opFaultHandler( event );
			}
			else if ( faultHandler != null ) 
			{
				faultHandler( event );
			}	
		}
		
		//--------------------------------------------------------------------------
		// Internal helper functions
		
		/**
		 * Initialize the operation object returned from the connection for this 
		 * operation
		 */
		protected function initOperation( operation : AbstractOperation, 
										                  parameters : Array ) : void
		{
			operation.arguments = parameters;
		}						
	}
}